import Foundation
import OSLog

// ============================================================
// 日志系统（调试期第一公民）
//  - 双写：OSLog（Console.app 可查）+ 纯文本文件（~/Library/Logs/Booth/，tail -f 友好）
//  - 按天滚动 booth-yyyy-MM-dd.log，启动时清理 14 天前旧日志
//  - 内存环形缓冲（最近 2000 条），供 App 内日志查看器
//  用法：Log.camera.info("已连接 \(uuid)")，自动带 file:line
// ============================================================

public enum LogLevel: Int, Sendable, Comparable, Codable {
    case debug = 0, info, notice, warning, error, fault
    public static func < (l: LogLevel, r: LogLevel) -> Bool { l.rawValue < r.rawValue }
    var label: String {
        switch self {
        case .debug: return "DEBUG"
        case .info: return "INFO"
        case .notice: return "NOTICE"
        case .warning: return "WARN"
        case .error: return "ERROR"
        case .fault: return "FAULT"
        }
    }
    var osType: OSLogType {
        switch self {
        case .debug: return .debug
        case .info: return .info
        case .notice: return .default
        case .warning: return .error
        case .error, .fault: return .fault
        }
    }
}

public struct LogEntry: Sendable, Equatable, Identifiable {
    public let id = UUID()
    public let time: Date
    public let level: LogLevel
    public let category: String
    public let message: String
    public let location: String   // File.swift:42
    public static func == (l: LogEntry, r: LogEntry) -> Bool { l.id == r.id }
}

public final class LogStore: @unchecked Sendable {
    public static let shared = LogStore()

    /// 文件日志最低级别（调试期可调成 .debug）
    public var fileLevel: LogLevel = .debug
    /// 内存缓冲 / UI 展示最低级别
    public var bufferLevel: LogLevel = .debug

    private let lock = NSLock()
    private var handle: FileHandle?
    private var currentDay = ""
    private let queue = DispatchQueue(label: "booth.logstore", qos: .utility)

    /// 环形缓冲（App 日志查看器数据源）
    private(set) var recent: [LogEntry] = []
    private let recentCap = 2000
    /// 缓冲变化回调（UI 订阅；在 utility 队列回调，锁外调用）
    public var onAppend: (@Sendable (LogEntry) -> Void)?

    /// 线程安全的缓冲快照（UI 初始化拉取用；直接读 `recent` 属无锁并发访问）
    public func recentSnapshot(maxCount: Int) -> [LogEntry] {
        lock.lock()
        defer { lock.unlock() }
        return Array(recent.suffix(maxCount))
    }

    private init() {
        rollFileIfNeeded()
        cleanOldLogs(keepDays: 14)
    }

    private func rollFileIfNeeded() {
        let day = DateFormatter.boothDay.string(from: Date())
        guard day != currentDay || handle == nil else { return }
        handle?.closeFile()
        currentDay = day
        let url = BoothPaths.logsDir.appendingPathComponent("booth-\(day).log")
        if !FileManager.default.fileExists(atPath: url.path) {
            FileManager.default.createFile(atPath: url.path, contents: nil)
        }
        handle = try? FileHandle(forWritingTo: url)
        handle?.seekToEndOfFile()
    }

    private func cleanOldLogs(keepDays: Int) {
        let fm = FileManager.default
        guard let files = try? fm.contentsOfDirectory(atPath: BoothPaths.logsDir.path) else { return }
        let cutoff = Date().addingTimeInterval(-TimeInterval(keepDays) * 86400)
        for f in files where f.hasPrefix("booth-") && f.hasSuffix(".log") {
            let dayStr = String(f.dropFirst("booth-".count).dropLast(".log".count))
            if let day = DateFormatter.boothDay.date(from: dayStr), day < cutoff {
                try? fm.removeItem(at: BoothPaths.logsDir.appendingPathComponent(f))
            }
        }
    }

    func write(_ level: LogLevel, _ category: String, _ message: String, file: String, line: Int) {
        let loc = "\(URL(fileURLWithPath: file).lastPathComponent):\(line)"
        let entry = LogEntry(time: Date(), level: level, category: category, message: message, location: loc)
        queue.async { [self] in
            var appended = false
            lock.lock()
            rollFileIfNeeded()
            if level >= fileLevel {
                let line = "\(DateFormatter.boothLogTime.string(from: entry.time)) [\(category.padding(toLength: 8, withPad: " ", startingAt: 0))] [\(level.label.padding(toLength: 6, withPad: " ", startingAt: 0))] \(message) (\(loc))\n"
                if let data = line.data(using: .utf8) {
                    handle?.write(data)
                }
            }
            if level >= bufferLevel {
                recent.append(entry)
                if recent.count > recentCap { recent.removeFirst(recent.count - recentCap) }
                appended = true
            }
            lock.unlock()
            // 回调放锁外：避免订阅方在回调里再做同步等待造成死锁
            if appended { onAppend?(entry) }
        }
    }

    /// 当前日志文件路径（方便 tail）
    public var currentLogFile: URL {
        BoothPaths.logsDir.appendingPathComponent("booth-\(DateFormatter.boothDay.string(from: Date())).log")
    }
}

/// 分类日志门面
public struct BoothLogger: Sendable {
    public let category: String
    private let oslog: Logger

    public init(_ category: String) {
        self.category = category
        self.oslog = Logger(subsystem: "com.booth.app", category: category)
    }

    public func log(_ level: LogLevel, _ message: @autoclosure () -> String,
                    file: String = #fileID, function: String = #function, line: Int = #line) {
        let msg = message()
        LogStore.shared.write(level, category, msg, file: file, line: line)
        oslog.log(level: level.osType, "\(msg)")
    }

    public func debug(_ m: @autoclosure () -> String, file: String = #fileID, line: Int = #line) { log(.debug, m(), file: file, line: line) }
    public func info(_ m: @autoclosure () -> String, file: String = #fileID, line: Int = #line) { log(.info, m(), file: file, line: line) }
    public func notice(_ m: @autoclosure () -> String, file: String = #fileID, line: Int = #line) { log(.notice, m(), file: file, line: line) }
    public func warn(_ m: @autoclosure () -> String, file: String = #fileID, line: Int = #line) { log(.warning, m(), file: file, line: line) }
    public func error(_ m: @autoclosure () -> String, file: String = #fileID, line: Int = #line) { log(.error, m(), file: file, line: line) }
    public func fault(_ m: @autoclosure () -> String, file: String = #fileID, line: Int = #line) { log(.fault, m(), file: file, line: line) }
}

/// 全模块统一日志入口
public enum Log {
    public static let camera  = BoothLogger("camera")
    public static let vision  = BoothLogger("vision")
    public static let session = BoothLogger("session")
    public static let imaging = BoothLogger("imaging")
    public static let print   = BoothLogger("print")
    public static let server  = BoothLogger("server")
    public static let ui      = BoothLogger("ui")
    public static let core    = BoothLogger("core")
}
