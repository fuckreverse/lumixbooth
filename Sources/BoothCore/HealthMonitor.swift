import Foundation

// ============================================================
// 健康监控（借鉴 photobooth-oss 健康面板）：
// 汇总 相机 / 打印机(CUPS) / 磁盘 / 当前状态 / 邮箱采集数，
//   - 周期刷新快照并落盘 health.json（进程崩溃后仍可查最后一次）
//   - /api/health 直接返回最新快照（远程 iPad / 手机查看）
//   - 操作员页健康卡片展示同一份数据
// 打印机探测走 /usr/bin/lpstat（与 LPPrintBackend 同源逻辑，测试可注入）。
// ============================================================

/// 一次健康检查的完整快照（JSON 编码给 /api/health 与 health.json）
public struct HealthStatus: Codable, Sendable, Equatable {
    public var checkedAt: Date
    public var uptimeSec: TimeInterval
    public var state: String           // 当前流程状态描述（idle/review/...）
    public var camera: String          // liveView / disconnected / ...
    public var printer: String         // idle / printing / disabled / unknown
    public var printerDetail: String?  // 原始 lpstat 摘要
    public var diskFreeMB: Int
    public var emailsCollected: Int
    /// 整体是否健康：相机在取景 + 打印机非异常 + 磁盘余量足
    public var ok: Bool

    public init(checkedAt: Date, uptimeSec: TimeInterval, state: String, camera: String,
                printer: String, printerDetail: String?, diskFreeMB: Int,
                emailsCollected: Int, ok: Bool) {
        self.checkedAt = checkedAt; self.uptimeSec = uptimeSec; self.state = state
        self.camera = camera; self.printer = printer; self.printerDetail = printerDetail
        self.diskFreeMB = diskFreeMB; self.emailsCollected = emailsCollected; self.ok = ok
    }
}

/// 健康监控 actor：周期采样 + 快照缓存 + 落盘
public actor HealthMonitor {
    public static let shared = HealthMonitor()

    private let cameraStateText: @Sendable () async -> String
    private let stateText: @Sendable () async -> String
    private let printerProbe: @Sendable () async -> (state: String, detail: String?)
    private let emailsCount: @Sendable () async -> Int
    private let startedAt = Date()
    private var latest: HealthStatus?
    private var task: Task<Void, Never>?
    private var running = false

    /// 默认组装：无相机依赖（返回 unknown）；BoothApp 用 live(camera:stateProvider:) 组真实实例
    public init() {
        self.init(cameraStateText: { "unknown" },
                  stateText: { "unknown" },
                  printerProbe: Self.lpstatProbe,
                  emailsCount: { await EmailStore.shared.count })
    }

    /// 依赖注入版（测试用 Mock 探测函数）
    public init(cameraStateText: @escaping @Sendable () async -> String,
                stateText: @escaping @Sendable () async -> String,
                printerProbe: @escaping @Sendable () async -> (state: String, detail: String?),
                emailsCount: @escaping @Sendable () async -> Int) {
        self.cameraStateText = cameraStateText
        self.stateText = stateText
        self.printerProbe = printerProbe
        self.emailsCount = emailsCount
    }

    /// 周期刷新（默认 30s 一次；写盘 health.json）
    public func start(every interval: TimeInterval = 30) {
        guard !running else { return }
        running = true
        task = Task {
            while !Task.isCancelled {
                _ = await checkNow()
                try? await Task.sleep(nanoseconds: UInt64(max(5, interval) * 1_000_000_000))
            }
        }
    }

    public func stop() {
        task?.cancel(); task = nil
        running = false
    }

    /// 最近一次快照（尚未检查过时立即做一次）
    public func snapshot() async -> HealthStatus {
        if let latest { return latest }
        return await checkNow()
    }

    /// 立刻采样一次并缓存/落盘
    @discardableResult
    public func checkNow() async -> HealthStatus {
        let camera = await cameraStateText()
        let printer = await printerProbe()
        let disk = Self.diskFreeMB()
        let emails = await emailsCount()
        let state = await stateText()
        let diskWarn = disk >= 0 && disk < 2048   // <2GB 告警（-1 = 查询失败）
        let printerBad = printer.state == "disabled" || printer.state == "error"
        let ok = camera == "liveView" && !printerBad && !diskWarn
        let status = HealthStatus(
            checkedAt: Date(),
            uptimeSec: Date().timeIntervalSince(startedAt),
            state: state,
            camera: camera,
            printer: printer.state,
            printerDetail: printer.detail,
            diskFreeMB: disk,
            emailsCollected: emails,
            ok: ok)
        latest = status
        // 落盘（失败不影响运行）
        if let data = try? JSONEncoder.booth.encode(status) {
            try? data.write(to: BoothPaths.healthStatusFile, options: .atomic)
        }
        Log.core.info("健康检查: camera=\(camera) printer=\(printer.state) 磁盘余=\(disk)MB ok=\(ok)")
        return status
    }

    // MARK: - 探测实现

    /// CUPS 打印机探测：优先查询打印配置选中的队列（超时 3s）。
    ///   "printer Foo is idle.  enabled since ..."  → idle
    ///   "printer Foo now printing Foo-123."        → printing
    ///   "printer Foo disabled since ..."          → disabled
    ///   无输出                                       → unknown
    public static func lpstatProbe() async -> (state: String, detail: String?) {
        let printerName = await ConfigStore.shared.config.printing.printerName
        let args = printerName.isEmpty ? ["-p"] : ["-p", printerName]
        let out = await runCommand("/usr/bin/lpstat", arguments: args, timeout: 3)
        guard let out, !out.isEmpty else { return ("unknown", nil) }
        let first = out.split(separator: "\n", maxSplits: 1)[0]
        return parsePrinterStatus(String(first))
    }

    public static func parsePrinterStatus(_ line: String) -> (state: String, detail: String?) {
        let first = line.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !first.isEmpty else { return ("unknown", nil) }
        let lower = first.lowercased()
        if lower.contains("disabled") || lower.contains("not ready") || first.contains("停用") {
            return ("disabled", first)
        }
        if lower.contains("now printing") || first.contains("正在打印") { return ("printing", first) }
        if lower.contains("is idle") || first.contains("闲置") { return ("idle", first) }
        return ("error", first)
    }

    /// 应用支持卷剩余空间（MB）；-1 = 查询失败
    public static func diskFreeMB() -> Int {
        let url = BoothPaths.appSupport
        guard let attrs = try? FileManager.default.attributesOfFileSystem(forPath: url.path),
              let free = attrs[.systemFreeSize] as? NSNumber else { return -1 }
        return free.intValue / (1024 * 1024)
    }

    /// 同步子进程执行（超时杀掉；返回 stdout 或 nil）
    nonisolated static func runCommand(_ path: String, arguments: [String], timeout: TimeInterval) async -> String? {
        let proc = Process()
        proc.executableURL = URL(fileURLWithPath: path)
        proc.arguments = arguments
        let pipe = Pipe()
        proc.standardOutput = pipe
        proc.standardError = Pipe()   // 丢弃 stderr
        do { try proc.run() } catch { return nil }
        // 超时守护
        let killer = Task {
            try? await Task.sleep(nanoseconds: UInt64(timeout * 1_000_000_000))
            if proc.isRunning { proc.terminate() }
        }
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        killer.cancel()
        proc.waitUntilExit()
        guard proc.terminationStatus == 0 || !data.isEmpty else { return nil }
        return String(data: data, encoding: .utf8)
    }
}

// MARK: - 专用实例工厂（BoothApp 组装用）：接真实相机与状态机
extension HealthMonitor {
    public static func live(camera: any CameraServicing,
                            stateProvider: @escaping @Sendable () async -> String) -> HealthMonitor {
        HealthMonitor(
            cameraStateText: {
                switch await camera.connectionState {
                case .liveView: return "liveView"
                case .connected: return "connected"
                case .connecting, .searching, .reconnecting: return "reconnecting"
                case .disconnected: return "disconnected"
                }
            },
            stateText: stateProvider,
            printerProbe: Self.lpstatProbe,
            emailsCount: { await EmailStore.shared.count })
    }
}
