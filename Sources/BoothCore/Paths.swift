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

    public static let logsDir: URL = {
        let base = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)[0]
        let dir = base.appendingPathComponent("Logs/Booth", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }()

    public static let configFile: URL = appSupport.appendingPathComponent("config.json")

    /// 演示 dry-run 打印的 PDF 输出目录（PreviewPrintBackend 默认落盘点）
    public static let printPreviewDir: URL = {
        let dir = appSupport.appendingPathComponent("print-preview", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }()

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
