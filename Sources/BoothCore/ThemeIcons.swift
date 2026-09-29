import Foundation

// ============================================================
// 主题图标系统 —— 主题包 icons/ 目录下的 PNG 覆盖内置 emoji。
//   主题目录结构：themes/<名>/theme.json + themes/<名>/icons/<key>.png
//   App 侧（BoothUI.BoothIcon）与 iPad 网页侧（/theme/icon/<key>.png 路由）共用。
//   无主题图时一律回退显示原 emoji（零素材也能跑）。
// ============================================================

public enum ThemeIcons {

    private static let lock = NSLock()
    private static let state = Store()

    /// 共享状态（NSLock 保护，绕过 Swift 6 全局可变状态检查）
    private final class Store: @unchecked Sendable {
        var dir: URL?
    }

    /// 激活主题目录（主题加载时调用；子目录 icons/ 存在才生效，否则回退 emoji）
    public static func activate(themeDir: URL?) {
        lock.lock(); defer { lock.unlock() }
        guard let themeDir else { state.dir = nil; return }
        let icons = themeDir.appendingPathComponent("icons", isDirectory: true)
        state.dir = FileManager.default.fileExists(atPath: icons.path) ? themeDir : nil
    }

    /// 当前主题目录（无激活主题为 nil）
    public static var themeDir: URL? {
        lock.lock(); defer { lock.unlock() }
        return state.dir
    }

    /// key → 图标文件 URL（文件存在才返回）
    public static func url(for key: String) -> URL? {
        guard let dir = themeDir else { return nil }
        let u = dir.appendingPathComponent("icons", isDirectory: true)
            .appendingPathComponent("\(key).png")
        return FileManager.default.fileExists(atPath: u.path) ? u : nil
    }

    /// key → 图标字节（iPad 网页路由用）
    public static func data(for key: String) -> Data? {
        guard let url = url(for: key) else { return nil }
        return try? Data(contentsOf: url)
    }

    /// emoji → 语义 key 映射（key 即 icons/ 下的文件名，不含 .png）
    /// 查找时统一去掉 FE0F 变体选择符，映射表里存不含 FE0F 的形态。
    public static let emojiToKey: [String: String] = [
        // 宾客大屏主流程
        "📸": "camera", "📷": "camera",
        "✌": "peace",
        "🧍‍♀️": "stand", "🧍‍♀": "stand", "🧍": "stand",
        "👋": "wave",
        "💖": "heart", "❤": "heart",
        "🎀": "bow",
        "👀": "eyes",
        "🌟": "star",
        "🎞": "film",
        "✨": "sparkle",
        "🖼": "frame",
        "🖨": "printer",
        "🎉": "confetti", "🥳": "confetti",
        "🔄": "retake",
        "😵": "dizzy",
        "📱": "phone-qr",
        // 操作员后台
        "🔐": "lock-key",
        "✏": "pencil",
        "🙈": "hide",
        "🛠": "toolbox",
        "📦": "box-export",
        "📥": "tray-import",
        "🧪": "test-tube",
        "🔙": "back", "↩": "back",
        "🛑": "stop",
        "🔒": "padlock",
        // 状态指示
        "✅": "check",
        "⚠": "warning",
        "❌": "cross",
        "🚫": "banned",
        "🕐": "clock",
        "🟢": "dot-green",
        "🟡": "dot-yellow",
        "🟠": "dot-orange",
        "🔴": "dot-red",
        "😊": "smile",
        "🔌": "plug",
        "🔍": "magnifier",
        "😴": "sleepy",
        // 滤镜与网页杂项
        "🌈": "rainbow",
        "🌅": "sunrise",
        "❄": "snow",
        "⚫": "ink", "⚫️": "ink",
        "📻": "radio",
        "📖": "album",
        "📭": "mailbox",
    ]

    /// emoji → 语义 key（自动容忍 FE0F 变体；无映射返回 nil=保持 emoji 原样）
    public static func key(forEmoji emoji: String) -> String? {
        if let k = emojiToKey[emoji] { return k }
        let bare = emoji.replacingOccurrences(of: "\u{FE0F}", with: "")
        return emojiToKey[bare]
    }
}
