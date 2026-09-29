import SwiftUI
import AppKit
import BoothCore

// ============================================================
// BoothIcon —— 主题化图标组件。
// 有主题图（themes/<名>/icons/<key>.png）就显示精致插画，
// 没有就回退显示原 emoji 文本。尺寸与原 emoji 字号对齐，调用方无感替换。
// ============================================================

public struct BoothIcon: View {
    private let emoji: String?
    private let key: String?
    private let size: CGFloat

    /// 从 emoji 出发（自动查映射；无映射纯回退）
    public init(emoji: String, size: CGFloat) {
        self.emoji = emoji
        self.key = ThemeIcons.key(forEmoji: emoji)
        self.size = size
    }

    /// 直接指定语义 key（可选 emoji 兜底）
    public init(key: String, size: CGFloat, fallback: String? = nil) {
        self.emoji = fallback
        self.key = key
        self.size = size
    }

    public var body: some View {
        if let key, let img = IconCache.image(key) {
            Image(nsImage: img)
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
        } else if let emoji {
            Text(emoji).font(.system(size: size))
        } else {
            Color.clear.frame(width: size, height: size)
        }
    }
}

/// NSImage 缓存（主题切换由 ThemeProvider 重新激活目录时清空）
@MainActor
enum IconCache {
    private static var cache: [String: NSImage] = [:]

    static func image(_ key: String) -> NSImage? {
        if let img = cache[key] { return img }
        guard let url = ThemeIcons.url(for: key), let img = NSImage(contentsOf: url) else { return nil }
        cache[key] = img
        return img
    }

    static func clear() { cache = [:] }
}
