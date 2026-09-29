import Foundation
import BoothCore

// ============================================================
// PrintService — 全局串行打印队列（SPEC §7）
//  - submit 入队 queued → 队列消费者逐个 printing → done/failed
//  - 队列每次变化：queue 流推送全量快照 + EventBus 发 .printQueueChanged
//  - 防连点去重：同一 imagePath 在 dedupeWindowSec 秒内重复 submit 返回已有 job
//  - copies 夹取到 [minCopies, maxCopies]
//  - retry：failed → 重新排队尾；remove：printing 中不可移除
//  - v1 不做队列持久化（重启即清空）
// ============================================================

public actor PrintService: PrintServing {

    /// 打印后端（模块内部协议；生产 LPPrintBackend，测试 MockPrintBackend）
    private let backend: any PrintBackend

    /// 打印配置快照（默认从 ConfigStore 加载，支持热更新）
    private var config: BoothConfig.PrintConf

    /// 任务列表（数组序即队列序；done/failed 保留在列表里等操作员清除）
    private var jobsStore: [PrintJob] = []

    /// 消费循环存活标志（保证全局只有一个消费者 → 串行）
    private var consumerRunning = false

    /// queue 流的注册中心。
    /// PrintServing.queue 是 nonisolated 同步属性，actor 隔离存储满足不了，
    /// 用一把锁的小类挂在 nonisolated let 上对外发流。
    private nonisolated let streamHub = QueueStreamHub()

    // MARK: - 初始化

    /// 生产入口：默认 CUPS lp 后端 + ConfigStore 配置
    public init() {
        self.backend = LPPrintBackend()
        self.config = BoothConfig.PrintConf()
        // 异步拉取真实配置（Actor init 不能 await；短暂用默认值，拉到后自动生效）
        Task { await self.reloadConfigFromStore() }
    }

    /// 测试/注入入口（internal：PrintBackend 是模块内部协议，不对外暴露）
    init(backend: any PrintBackend, config: BoothConfig.PrintConf) {
        self.backend = backend
        self.config = config
    }

    private func reloadConfigFromStore() async {
        config = await ConfigStore.shared.config.printing
        Log.print.info("已从 ConfigStore 加载打印配置: printer=\(config.printerName.isEmpty ? "(系统默认)" : config.printerName) 默认份数=\(config.defaultCopies) 无边距=\(config.borderless)")
    }

    /// 配置热更新（操作员设置页改打印参数后调用）
    public func applyConfig(_ newConfig: BoothConfig.PrintConf) {
        config = newConfig
        Log.print.info("打印配置已热更新: printer=\(newConfig.printerName.isEmpty ? "(系统默认)" : newConfig.printerName) 无边距=\(newConfig.borderless) 去重窗口=\(newConfig.dedupeWindowSec)s")
    }

    // MARK: - PrintServing 契约

    /// 队列快照流（每次变化推送全量）
    public nonisolated var queue: AsyncStream<[PrintJob]> { streamHub.makeStream() }

    /// 当前任务快照（队列深度、操作员页展示用）
    public var jobs: [PrintJob] { jobsStore }

    /// 提交打印：去重 → 夹取份数 → 入队。绝不抛错，失败经 job.status/lastError 呈现。
    @discardableResult
    public func submit(image: URL, copies: Int) async -> PrintJob {
        let path = image.standardizedFileURL.path

        // 防连点去重：同一成片窗口内重复提交直接返回已存在的任务
        if let existing = jobsStore.first(where: {
            $0.imagePath == path
                && $0.status != .cancelled
                && Date().timeIntervalSince($0.createdAt) <= Double(config.dedupeWindowSec)
        }) {
            Log.print.warn("去重命中: \(path) 在 \(config.dedupeWindowSec)s 窗口内重复提交，返回已有任务 id=\(existing.id) 状态=\(existing.status)")
            return existing
        }

        // 份数夹取到 [minCopies, maxCopies]
        let clamped = min(max(copies, config.minCopies), config.maxCopies)
        if clamped != copies {
            Log.print.warn("份数夹取: 请求 \(copies) → \(clamped)（允许范围 \(config.minCopies)...\(config.maxCopies)）")
        }

        let job = PrintJob(imagePath: path, copies: clamped, status: .queued)
        jobsStore.append(job)
        Log.print.info("任务入队: id=\(job.id) copies=\(job.copies) 路径=\(path) 队列深度=\(jobsStore.count)")
        publishQueue()
        kickConsumer()
        return job
    }

    /// 重试：仅 failed 可重试，重置为 queued 并排到队尾
    public func retry(jobID: UUID) async {
        guard let index = jobsStore.firstIndex(where: { $0.id == jobID }) else {
            Log.print.warn("重试失败: 找不到任务 id=\(jobID)")
            return
        }
        guard jobsStore[index].status == .failed else {
            Log.print.warn("重试失败: 任务 id=\(jobID) 状态为 \(jobsStore[index].status)，仅 failed 可重试")
            return
        }
        jobsStore[index].status = .queued
        jobsStore[index].lastError = nil
        jobsStore[index].finishedAt = nil
        let job = jobsStore.remove(at: index)
        jobsStore.append(job)
        Log.print.info("任务重试: id=\(job.id) 重新入队，队列深度=\(jobsStore.count)")
        publishQueue()
        kickConsumer()
    }

    /// 移除任务：printing 中不可移除（打印头已经在动），其余状态可移除
    public func remove(jobID: UUID) async {
        guard let index = jobsStore.firstIndex(where: { $0.id == jobID }) else {
            Log.print.warn("移除失败: 找不到任务 id=\(jobID)")
            return
        }
        guard jobsStore[index].status != .printing else {
            Log.print.warn("移除失败: 任务 id=\(jobID) 正在打印中，不允许移除")
            return
        }
        let job = jobsStore.remove(at: index)
        Log.print.info("任务移除: id=\(job.id) 原状态=\(job.status)，剩余队列深度=\(jobsStore.count)")
        publishQueue()
    }

    // MARK: - 队列消费者（全局唯一 → 串行）

    private func kickConsumer() {
        guard !consumerRunning else { return }
        consumerRunning = true
        Task { await consumeLoop() }
    }

    private func consumeLoop() async {
        defer { consumerRunning = false }   // 循环退出（队列空）时允许下次唤醒
        while true {
            // 取队首第一个 queued 任务（FIFO；retry 的任务已排到队尾）
            guard let index = jobsStore.firstIndex(where: { $0.status == .queued }) else { return }
            let jobID = jobsStore[index].id
            jobsStore[index].status = .printing
            let job = jobsStore[index]
            Log.print.info("开始打印: id=\(job.id) copies=\(job.copies) 路径=\(job.imagePath)")
            publishQueue()

            do {
                try await backend.print(imagePath: job.imagePath, copies: job.copies, config: config)
                // await 期间数组可能被动过（remove/retry），按 id 重新定位
                if let i = jobsStore.firstIndex(where: { $0.id == jobID }) {
                    jobsStore[i].status = .done
                    jobsStore[i].finishedAt = Date()
                    jobsStore[i].lastError = nil
                }
                Log.print.info("打印完成: id=\(job.id)")
            } catch {
                if let i = jobsStore.firstIndex(where: { $0.id == jobID }) {
                    jobsStore[i].status = .failed
                    jobsStore[i].finishedAt = Date()
                    jobsStore[i].lastError = "\(error)"
                }
                Log.print.error("打印失败: id=\(job.id) 错误=\(error)")
            }
            publishQueue()
        }
    }

    // MARK: - 队列变化广播

    /// queue 流全量快照 + EventBus.printQueueChanged
    private func publishQueue() {
        let snapshot = jobsStore
        streamHub.yield(snapshot)
        Task { await EventBus.shared.publish(.printQueueChanged(snapshot)) }
    }
}

// MARK: - 队列流注册中心（nonisolated 发流用）

/// PrintServing.queue 要求 nonisolated 同步取流，actor 隔离状态不能直接满足，
/// 用锁保护的 continuation 注册中心，挂在 actor 的 nonisolated let 上。
final class QueueStreamHub: @unchecked Sendable {
    private let lock = NSLock()
    private var continuations: [UUID: AsyncStream<[PrintJob]>.Continuation] = [:]

    func makeStream() -> AsyncStream<[PrintJob]> {
        let id = UUID()
        return AsyncStream(bufferingPolicy: .bufferingNewest(256)) { continuation in
            self.lock.lock()
            self.continuations[id] = continuation
            self.lock.unlock()
            continuation.onTermination = { _ in
                self.remove(id)
            }
        }
    }

    private func remove(_ id: UUID) {
        lock.lock()
        continuations.removeValue(forKey: id)
        lock.unlock()
    }

    func yield(_ jobs: [PrintJob]) {
        lock.lock()
        let targets = Array(continuations.values)
        lock.unlock()
        for continuation in targets { continuation.yield(jobs) }
    }
}
