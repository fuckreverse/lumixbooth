import Foundation

/// 统一目录管理（SPEC §10）：
///   ~/Library/Application Support/Booth/{config.json, sessions/, themes/}
///   ~/Library/Logs/Booth/
public enum BoothPaths {
    public static let appSupport: URL = {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        let dir = base.appendingPathComponent("Booth", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }()

    public static let sessionsDir: URL = {
        let dir = appSupport.appendingPathComponent("sessions", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }()

    public static let themesDir: URL = {
        let dir = appSupport.appendingPathComponent("themes", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }()

    /// 搞怪装饰模板目录：decorations/<模板名>/template.json + 贴纸 PNG
    public static let decorationsDir: URL = {
        let dir = appSupport.appendingPathComponent("decorations", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }()

    public static let logsDir: URL = {
        let base = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)[0]
        let dir = base.appendingPathComponent("Logs/Booth", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }()

    public static let configFile: URL = appSupport.appendingPathComponent("config.json")

    /// 操作员 PIN 哈希（独立于 config.json：一键重置配置不会把密码冲掉）
    public static let guardFile: URL = appSupport.appendingPathComponent("guard.json")

    /// 配置自动备份目录（ConfigStore 每次写盘前备份，保留最近 10 份）
    public static let configBackupsDir: URL = {
        let dir = appSupport.appendingPathComponent("config-backups", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }()

    /// 演示 dry-run 打印的 PDF 输出目录（PreviewPrintBackend 默认落盘点）
    public static let printPreviewDir: URL = {
        let dir = appSupport.appendingPathComponent("print-preview", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }()

    /// 邮箱采集落盘文件（emails.json：增量追加去重；操作员可导出 CSV）
    public static let emailsFile: URL = appSupport.appendingPathComponent("emails.json")

    /// 操作员导出邮箱 CSV 的默认目录（可从 Finder 直接拷走）
    public static let emailsExportDir: URL = {
        let dir = appSupport.appendingPathComponent("emails-export", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }()

    /// 视频留言簿录制文件目录：guestbook/<yyyy-MM-dd>.mp4（按日归档）
    public static let guestbookDir: URL = {
        let dir = appSupport.appendingPathComponent("guestbook", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }()

    /// /api/health 状态快照落盘（进程崩溃后仍可查最后一次状态）
    public static let healthStatusFile: URL = appSupport.appendingPathComponent("health.json")

    /// 新建一次拍照会话目录：sessions/<yyyy-MM-dd>/<HHmmss-短id>/
    public static func newSessionDir(now: Date = Date()) -> URL {
        let day = DateFormatter.boothDay.string(from: now)
        let stamp = DateFormatter.boothTime.string(from: now)
        let dir = sessionsDir.appendingPathComponent(day, isDirectory: true)
            .appendingPathComponent("\(stamp)-\(UUID().uuidString.prefix(6).lowercased())", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }
}

extension DateFormatter {
    static let boothDay: DateFormatter = {
        let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"; return f
    }()
    static let boothTime: DateFormatter = {
        let f = DateFormatter(); f.dateFormat = "HHmmss"; return f
    }()
    public static let boothLogTime: DateFormatter = {
        let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"; return f
    }()
}
