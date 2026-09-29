import XCTest
import BoothCore
@testable import PrintKit

// ============================================================
// PrintKit 单测 —— 全部走 MockPrintBackend，绝不触发真实打印。
// 不实例化 LPPrintBackend 的 print（lpArguments 纯函数除外，不执行子进程）。
// ============================================================

final class PrintKitTests: XCTestCase {

    // MARK: - 工具

    /// 线程安全的流收集器（Task 闭包里跨并发域捕获局部变量会被 Swift 6 拒绝）
    private final class Recorder<T>: @unchecked Sendable {
        private let lock = NSLock()
        private var items: [T] = []
        func append(_ item: T) {
            lock.lock(); items.append(item); lock.unlock()
        }
        var all: [T] {
            lock.lock(); defer { lock.unlock() }
            return items
        }
    }

    /// 轮询等待条件成立（默认 5s 超时），避免竞态下用固定 sleep
    @discardableResult
    private func waitUntil(
        timeout: TimeInterval = 5,
        _ condition: @escaping () async -> Bool
    ) async -> Bool {
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            if await condition() { return true }
            try? await Task.sleep(nanoseconds: 20_000_000)   // 20ms
        }
        return await condition()
    }

    private func makeConfig() -> BoothConfig.PrintConf {
        // 默认: minCopies=1 maxCopies=4 dedupeWindowSec=5 borderless=true
        BoothConfig.PrintConf()
    }

    private func makeService(mock: MockPrintBackend, config: BoothConfig.PrintConf? = nil) -> PrintService {
        PrintService(backend: mock, config: config ?? makeConfig())
    }

    // MARK: - 1. submit → done 全流程状态迁移

    func testSubmitToDoneStatusTransitions() async {
        let mock = MockPrintBackend()
        await mock.reset(delay: .milliseconds(50))
        let service = makeService(mock: mock)

        // 订阅队列流，按首个任务的状态记轨迹
        let trail = Recorder<PrintJobStatus>()
        let collector = Task {
            for await jobs in service.queue {
                if let status = jobs.first?.status { trail.append(status) }
            }
        }
        defer { collector.cancel() }

        let job = await service.submit(image: URL(fileURLWithPath: "/tmp/booth-test-a.jpg"), copies: 2)
        XCTAssertEqual(job.status, .queued, "submit 返回时应为 queued")
        XCTAssertEqual(job.copies, 2)

        let done = await waitUntil { (await service.jobs).first?.status == .done }
        XCTAssertTrue(done, "应迁移到 done")
        let finalStatus = (await service.jobs).first?.status
        XCTAssertEqual(finalStatus, .done)

        // 状态轨迹必须按 queued → printing → done 顺序出现
        let statusTrail = trail.all
        let firstQueued = statusTrail.firstIndex(of: .queued)
        let firstPrinting = statusTrail.firstIndex(of: .printing)
        let firstDone = statusTrail.firstIndex(of: .done)
        XCTAssertNotNil(firstQueued)
        XCTAssertNotNil(firstPrinting)
        XCTAssertNotNil(firstDone)
        XCTAssertLessThan(firstQueued!, firstPrinting!)
        XCTAssertLessThan(firstPrinting!, firstDone!)

        let records = await mock.records
        XCTAssertEqual(records.count, 1)
        XCTAssertEqual(records.first?.imagePath, "/tmp/booth-test-a.jpg")
        XCTAssertEqual(records.first?.copies, 2)
    }

    // MARK: - 2. 串行性：3 个任务按提交顺序消费，且后一个在前一个 printing 时保持 queued

    func testSerialOrdering() async {
        let mock = MockPrintBackend()
        await mock.reset(delay: .milliseconds(100))
        let service = makeService(mock: mock)

        // 捕获快照，验证"打印第 1 个时第 2 个还在排队"的串行证据
        let snapshots = Recorder<[PrintJob]>()
        let collector = Task {
            for await jobs in service.queue { snapshots.append(jobs) }
        }
        defer { collector.cancel() }

        let paths = (0..<3).map { "/tmp/booth-test-ser-\($0).jpg" }
        for path in paths {
            await service.submit(image: URL(fileURLWithPath: path), copies: 1)
            // 逐个提交且留间隔，保证队列形成后再开打
            try? await Task.sleep(nanoseconds: 30_000_000)
        }

        let allDone = await waitUntil {
            let jobs = await service.jobs
            return jobs.count == 3 && jobs.allSatisfy { $0.status == .done }
        }
        XCTAssertTrue(allDone, "3 个任务应全部完成")

        // backend 收到顺序 == 提交顺序（串行 FIFO）
        let records = await mock.records
        XCTAssertEqual(records.map(\.imagePath), paths, "消费顺序必须与提交顺序一致")

        // 必须存在某快照：任务0 printing 且 任务1 仍 queued（证明没有并行打印）
        let serialEvidence = snapshots.all.contains { jobs in
            jobs.count >= 2 && jobs[0].status == .printing && jobs[1].status == .queued
        }
        XCTAssertTrue(serialEvidence, "应观察到串行执行快照（前一个 printing 时后一个仍 queued）")
    }

    // MARK: - 3. 去重窗口内重复提交返回同一 job

    func testDedupeWithinWindow() async {
        let mock = MockPrintBackend()
        await mock.reset(delay: .milliseconds(80))
        let service = makeService(mock: mock)

        let url = URL(fileURLWithPath: "/tmp/booth-test-dup.jpg")
        let first = await service.submit(image: url, copies: 2)
        let second = await service.submit(image: url, copies: 2)   // 5s 窗口内连点

        XCTAssertEqual(first.id, second.id, "窗口内重复提交应返回同一任务")
        let jobCount = await service.jobs.count
        XCTAssertEqual(jobCount, 1, "队列里只应有一个任务")

        let done = await waitUntil { (await service.jobs).first?.status == .done }
        XCTAssertTrue(done)

        let records = await mock.records
        XCTAssertEqual(records.count, 1, "后端只应收到一次打印请求")
    }

    // MARK: - 4. 失败 → retry → done

    func testFailThenRetrySucceeds() async {
        let mock = MockPrintBackend()
        await mock.reset(delay: .zero, failCount: 1)   // 第一次打印失败
        let service = makeService(mock: mock)

        let url = URL(fileURLWithPath: "/tmp/booth-test-retry.jpg")
        let job = await service.submit(image: url, copies: 2)

        let failed = await waitUntil { (await service.jobs).first?.status == .failed }
        XCTAssertTrue(failed, "第一次应失败")
        let failedJob = (await service.jobs).first
        XCTAssertNotNil(failedJob?.lastError, "失败原因应写入 lastError")

        await service.retry(jobID: job.id)

        let done = await waitUntil { (await service.jobs).first?.status == .done }
        XCTAssertTrue(done, "重试后应成功")

        let finalJob = (await service.jobs).first
        XCTAssertEqual(finalJob?.status, .done)
        XCTAssertNil(finalJob?.lastError, "重试成功后应清空 lastError")

        let records = await mock.records
        XCTAssertEqual(records.count, 2, "后端应收到两次请求（失败一次 + 重试一次）")
        XCTAssertEqual(records.map(\.imagePath), ["/tmp/booth-test-retry.jpg", "/tmp/booth-test-retry.jpg"])
    }

    // MARK: - 5. copies 夹取到 [minCopies, maxCopies]

    func testCopiesClamping() async {
        let mock = MockPrintBackend()
        await mock.reset(delay: .zero)
        let service = makeService(mock: mock)

        let tooFew = await service.submit(image: URL(fileURLWithPath: "/tmp/booth-test-c0.jpg"), copies: 0)
        XCTAssertEqual(tooFew.copies, 1, "低于下限应夹取到 minCopies=1")

        let tooMany = await service.submit(image: URL(fileURLWithPath: "/tmp/booth-test-c99.jpg"), copies: 99)
        XCTAssertEqual(tooMany.copies, 4, "高于上限应夹取到 maxCopies=4")

        let justRight = await service.submit(image: URL(fileURLWithPath: "/tmp/booth-test-c3.jpg"), copies: 3)
        XCTAssertEqual(justRight.copies, 3, "合法份数原样通过")

        // 自定义边界也生效
        var config = makeConfig()
        config.minCopies = 2
        config.maxCopies = 3
        let service2 = makeService(mock: mock, config: config)
        let clampedLow = await service2.submit(image: URL(fileURLWithPath: "/tmp/booth-test-x.jpg"), copies: 1)
        XCTAssertEqual(clampedLow.copies, 2)
        let clampedHigh = await service2.submit(image: URL(fileURLWithPath: "/tmp/booth-test-y.jpg"), copies: 8)
        XCTAssertEqual(clampedHigh.copies, 3)
    }

    // MARK: - 6. remove：printing 中不可移除，其余状态可移除

    func testRemoveRules() async {
        let mock = MockPrintBackend()
        await mock.reset(delay: .milliseconds(300))
        let service = makeService(mock: mock)

        let printingJob = await service.submit(image: URL(fileURLWithPath: "/tmp/booth-test-rm1.jpg"), copies: 1)
        let queuedJob = await service.submit(image: URL(fileURLWithPath: "/tmp/booth-test-rm2.jpg"), copies: 1)

        // 等第一个进入 printing
        let started = await waitUntil {
            (await service.jobs).first?.status == .printing
        }
        XCTAssertTrue(started)

        // printing 中移除 → 拒绝，任务仍在
        await service.remove(jobID: printingJob.id)
        var jobs = await service.jobs
        XCTAssertEqual(jobs.count, 2, "printing 中的任务不可移除")
        XCTAssertEqual(jobs.first?.status, .printing)

        // queued 的第二个任务可以移除
        await service.remove(jobID: queuedJob.id)
        jobs = await service.jobs
        XCTAssertEqual(jobs.count, 1)

        // 打完后再移除 done 的任务
        let done = await waitUntil { (await service.jobs).first?.status == .done }
        XCTAssertTrue(done)
        await service.remove(jobID: printingJob.id)
        jobs = await service.jobs
        XCTAssertEqual(jobs.count, 0, "done 任务可移除")
    }

    // MARK: - 7. lp 参数组装（纯函数，不执行任何子进程）

    func testLPArgumentsAssembly() async {
        var config = BoothConfig.PrintConf()
        config.printerName = "EPSON_L805"
        config.borderless = true

        let withPrinter = LPPrintBackend.lpArguments(imagePath: "/tmp/x.jpg", copies: 2, config: config)
        XCTAssertEqual(withPrinter, [
            "-d", "EPSON_L805",
            "-n", "2",
            "-o", "media=4x6.Borderless",
            "-o", "fit-to-page",
            "/tmp/x.jpg",
        ], "无边距 + 指定打印机")

        config.printerName = ""      // 空 → 省略 -d 用系统默认
        config.borderless = false    // 有边距降级
        let defaultPrinter = LPPrintBackend.lpArguments(imagePath: "/tmp/x.jpg", copies: 4, config: config)
        XCTAssertEqual(defaultPrinter, [
            "-n", "4",
            "-o", "media=4x6",
            "-o", "fit-to-page",
            "/tmp/x.jpg",
        ], "有边距 + 系统默认打印机（省略 -d）")
    }

    // MARK: - 8. 打印机不可用 → 任务失败而非崩溃

    func testPrinterUnavailableFailsJob() async {
        let mock = MockPrintBackend()
        await mock.reset(delay: .zero, unavailableMessage: "模拟: lpstat -p 无此打印机")
        let service = makeService(mock: mock)

        let job = await service.submit(image: URL(fileURLWithPath: "/tmp/booth-test-unavail.jpg"), copies: 2)

        let failed = await waitUntil { (await service.jobs).first?.status == .failed }
        XCTAssertTrue(failed, "打印机不可用应导致任务 failed")
        let failedJob = (await service.jobs).first
        XCTAssertTrue(failedJob?.lastError?.contains("printerUnavailable") == true
                      || failedJob?.lastError?.contains("模拟") == true,
                      "lastError 应含不可用信息: \(failedJob?.lastError as Any)")
        XCTAssertEqual(job.id, failedJob?.id)

        // 恢复可用后 retry 能走通
        await mock.reset(delay: .zero, unavailableMessage: nil)
        await service.retry(jobID: job.id)
        let done = await waitUntil { (await service.jobs).first?.status == .done }
        XCTAssertTrue(done, "打印机恢复后重试应成功")
    }
}
