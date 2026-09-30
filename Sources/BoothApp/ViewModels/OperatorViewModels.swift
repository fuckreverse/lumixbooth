import AppKit
import BoothCore
import PrintKit

// ============================================================
// 操作员页各页签视图模型（状态 / 设置 / 历史 / 日志）
// ============================================================

// MARK: - 状态页

/// 相机连接状态 + 打印队列
@MainActor
final class OpStatusViewModel: ObservableObject {
    @Published private(set) var cameraState: CameraConnectionState = .disconnected
    @Published private(set) var jobs: [PrintJob] = []

    private let camera: any CameraServicing
    private let printer: any PrintServing
    private var tasks: [Task<Void, Never>] = []
    private var started = false

    init(camera: any CameraServicing, printer: any PrintServing) {
        self.camera = camera
        self.printer = printer
    }
    func start() {
        guard !started else { return }
        started = true
        // 相机状态轮询（1s）
        tasks.append(Task { [weak self] in
            while !Task.isCancelled {
                guard let self else { return }
                let s = await self.camera.connectionState
                if s != self.cameraState { self.cameraState = s }
                try? await Task.sleep(nanoseconds: 1_000_000_000)
            }
        })
        // 打印队列快照流
        tasks.append(Task { [weak self] in
            guard let self else { return }
            for await snapshot in self.printer.queue {
                self.jobs = snapshot
            }
        })
    }

    func retry(jobID: UUID) { Task { await printer.retry(jobID: jobID) } }
    func remove(jobID: UUID) { Task { await printer.remove(jobID: jobID) } }
}

// MARK: - 健康面板（操作员卡片：CUPS / 磁盘 / 采集数 + 手动刷新）

@MainActor
final class OpHealthViewModel: ObservableObject {
    @Published private(set) var status: HealthStatus?
    @Published private(set) var refreshing = false
    /// 邮箱 CSV 导出结果提示（3s 自动清除）
    @Published var exportNotice: String?

    private let health: HealthMonitor
    private var task: Task<Void, Never>?
    private var started = false

    init(health: HealthMonitor, printer: any PrintServing) {
        self.health = health
    }

    func start() {
        guard !started else { return }
        started = true
        refresh()
        task = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 30_000_000_000)  // 30s 同步一次
                self?.refresh()
            }
        }
    }

    func refresh() {
        guard !refreshing else { return }
        refreshing = true
        Task { [weak self] in
            guard let self else { return }
            self.status = await self.health.checkNow()
            self.refreshing = false
        }
    }

    /// 邮箱 CSV 导出（落 emails-export/ 目录并在 Finder 显示）
    func exportEmailsCSV() {
        Task { [weak self] in
            do {
                let url = try await EmailStore.shared.exportCSV()
                self?.exportNotice = "已导出 → \(url.lastPathComponent)"
                NSWorkspace.shared.open(url.deletingLastPathComponent())
                try? await Task.sleep(nanoseconds: 3_000_000_000)
                self?.exportNotice = nil
            } catch {
                self?.exportNotice = "导出失败：\(error.localizedDescription)"
            }
        }
    }
}

// MARK: - 设置页

/// 读写 ConfigStore（改动即存即生效）+ 配置备份管理（防呆：坏改动可反悔）
/// + 系统打印机枚举（打印设置页「指定打印机」数据源）
@MainActor
final class OpSettingsViewModel: ObservableObject {
    @Published private(set) var config = BoothConfig()
    /// 配置备份列表（新→旧；每次改动自动备份，保留 10 份）
    @Published private(set) var backups: [ConfigBackup] = []
    /// 系统打印机列表（lpstat 枚举；空 = 未检测到）
    @Published private(set) var printers: [PrinterLister.Printer] = []
    @Published private(set) var printersRefreshing = false
    private var task: Task<Void, Never>?
    private var started = false

    func start() {
        guard !started else { return }
        started = true
        task = Task { [weak self] in
            guard let self else { return }
            for await cfg in await ConfigStore.shared.stream() {
                self.config = cfg
            }
        }
        reloadBackups()
        refreshPrinters()
    }

    /// 枚举系统打印机（lpstat，后台线程；设置页出现/手动刷新时调用）
    func refreshPrinters() {
        guard !printersRefreshing else { return }
        printersRefreshing = true
        Task { [weak self] in
            let list = await PrinterLister.listAsync()
            guard let self else { return }
            self.printers = list
            self.printersRefreshing = false
        }
    }

    /// 统一写入口（ConfigStore 改即存盘 + 广播热更新）
    func update(_ mutate: @escaping @Sendable (inout BoothConfig) -> Void) {
        Task { await ConfigStore.shared.update(mutate) }
    }

    // MARK: - 防呆：备份 / 重置 / 导入导出

    func reloadBackups() {
        Task { [weak self] in
            guard let self else { return }
            self.backups = await ConfigStore.shared.listBackups()
        }
    }

    /// 一键重置（长按 3 秒触发）：重置前 ConfigStore 自动备份当前配置
    func resetToDefaults() {
        Task {
            await ConfigStore.shared.resetToDefaults()
            reloadBackups()
        }
    }

    func restoreBackup(_ name: String) {
        Task {
            await ConfigStore.shared.restoreBackup(named: name)
            reloadBackups()
        }
    }

    func exportConfig(to url: URL) {
        Task {
            do { try await ConfigStore.shared.exportConfig(to: url) }
            catch { Log.ui.error("配置导出失败: \(error.localizedDescription)") }
        }
    }

    func importConfig(from url: URL) {
        Task {
            do { try await ConfigStore.shared.importConfig(from: url) }
            catch { Log.ui.error("配置导入失败: \(error.localizedDescription)") }
            reloadBackups()
        }
    }
}

// MARK: - 历史页

/// 一条历史会话（sessions/<日期>/<会话>/）
struct SessionItem: Identifiable, Sendable {
    let id: String            // 会话目录路径
    let day: String           // 日期目录名
    let name: String          // 会话目录名（HHmmss-短id）
    let printURL: URL         // print.jpg
    let thumbURL: URL         // display.jpg 优先，否则 print.jpg
}

@MainActor
final class OpHistoryViewModel: ObservableObject {
    @Published private(set) var sessions: [SessionItem] = []
    @Published private(set) var loading = false

    private let printer: any PrintServing

    init(printer: any PrintServing) {
        self.printer = printer
    }

    /// 扫描 sessions 目录（后台线程，按日期倒序）
    func reload() {
        loading = true
        Task.detached(priority: .utility) { [weak self] in
            let items = Self.scanSessions()
            await self?.applyScanResult(items)
        }
    }

    /// 回主线程写结果
    private func applyScanResult(_ items: [SessionItem]) {
        sessions = items
        loading = false
    }

    /// 重打该会话成片（份数走当前配置默认值）
    func reprint(_ item: SessionItem) {
        Task {
            let copies = await ConfigStore.shared.config.printing.defaultCopies
            let job = await printer.submit(image: item.printURL, copies: copies)
            Log.ui.info("历史重打：\(item.name) 已入队 job=\(job.id.uuidString.prefix(8)) copies=\(job.copies)")
        }
    }

    /// 在 Finder 显示 sessions 目录
    func revealInFinder() {
        NSWorkspace.shared.open(BoothPaths.sessionsDir)
    }

    private nonisolated static func scanSessions() -> [SessionItem] {
        let fm = FileManager.default
        guard let days = try? fm.contentsOfDirectory(atPath: BoothPaths.sessionsDir.path) else { return [] }
        var items: [SessionItem] = []
        for day in days where !day.hasPrefix(".") {
            let dayDir = BoothPaths.sessionsDir.appendingPathComponent(day, isDirectory: true)
            guard let sessions = try? fm.contentsOfDirectory(atPath: dayDir.path) else { continue }
            for name in sessions where !name.hasPrefix(".") {
                let dir = dayDir.appendingPathComponent(name, isDirectory: true)
                let printURL = dir.appendingPathComponent("print.jpg")
                guard fm.fileExists(atPath: printURL.path) else { continue }
                let displayURL = dir.appendingPathComponent("display.jpg")
                let thumb = fm.fileExists(atPath: displayURL.path) ? displayURL : printURL
                items.append(SessionItem(id: dir.path, day: day, name: name,
                                         printURL: printURL, thumbURL: thumb))
            }
        }
        // 日期倒序 + 同日内会话名（HHmmss 开头）倒序
        return items.sorted { ($0.day, $0.name) > ($1.day, $1.name) }
    }
}

// MARK: - 日志页

/// LogStore 内存环形缓冲的 UI 镜像（分类过滤 + 自动滚底）
@MainActor
final class OpLogsViewModel: ObservableObject {
    @Published private(set) var entries: [LogEntry] = []
    @Published var categoryFilter: String? = nil   // nil = 全部

    /// 展示上限（防长列表卡顿）
    private let displayCap = 500
    /// 待合并的增量缓冲 + 定时刷新任务
    private var pending: [LogEntry] = []
    private var flushTask: Task<Void, Never>?

    static let categories = ["camera", "vision", "session", "imaging", "print", "server", "ui", "core"]

    func start() {
        entries = LogStore.shared.recentSnapshot(maxCount: displayCap)
        // 订阅增量（onAppend 在 utility 队列锁外回调，跳回主线程攒批）
        LogStore.shared.onAppend = { [weak self] entry in
            Task { @MainActor in self?.enqueue(entry) }
        }
    }

    /// 离开操作员页时退订（继续留着只会白攒批）
    func stop() {
        LogStore.shared.onAppend = nil
        flushTask?.cancel()
        flushTask = nil
        pending.removeAll()
    }

    /// 增量先攒进 pending，每 0.5s 合并刷一次 —— Mock 相机逐帧打 debug
    /// 日志（30+ 条/秒），逐条刷 @Published 会把主线程打成渲染洪水
    private func enqueue(_ entry: LogEntry) {
        pending.append(entry)
        guard flushTask == nil else { return }
        flushTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 500_000_000)
            guard let self else { return }
            self.flushTask = nil
            self.flush()
        }
    }

    private func flush() {
        guard !pending.isEmpty else { return }
        entries.append(contentsOf: pending)
        pending.removeAll()
        if entries.count > displayCap {
            entries.removeFirst(entries.count - displayCap)
        }
    }

    var filtered: [LogEntry] {
        guard let f = categoryFilter else { return entries }
        return entries.filter { $0.category == f }
    }

    /// 在 Finder 显示日志目录
    func revealInFinder() {
        NSWorkspace.shared.open(BoothPaths.logsDir)
    }
}
