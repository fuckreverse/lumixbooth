import SwiftUI
import BoothCore

// ============================================================
// 设计系统 —— 全 App 唯一风格来源（收口）
// 所有颜色/圆角/字号/动效从 BoothTheme 取，UI 组件禁止硬编码风格值。
// 主题可定制：~/Library/Application Support/Booth/themes/<名>/theme.json
// ============================================================

public struct BoothTheme: Codable, Equatable, Sendable {
    // 色板（hex，默认奶油糖果风）
    public var accent = "#FF8FAB"          // 主色：蜜桃粉
    public var accentSecondary = "#FFC2D4" // 次主色：浅粉
    public var background = "#FFF7F0"      // 背景：奶油
    public var backgroundSecondary = "#FFFFFF"
    public var text = "#4A3434"            // 主文字：暖棕
    public var textSecondary = "#A08C8C"
    public var textOnAccent = "#FFFFFF"
    public var success = "#7DC98F"
    public var warning = "#FFB55C"
    public var danger = "#F07070"
    // 形状与排版
    public var cornerRadius: Double = 24
    public var cornerRadiusSmall: Double = 14
    public var fontName = ""               // 空 = 系统圆体 .rounded
    // 点缀
    public var mascotEmoji = "📸"
    public var idleEmojis: [String] = ["📸", "🎉", "💖", "✨", "🥳"]
    // 动效
    public var bounceDuration: Double = 0.35

    public init() {}
}

// MARK: - 颜色解析

extension Color {
    public init(hex: String, fallback: Color = .gray) {
        var s = hex.trimmingCharacters(in: .whitespaces).uppercased()
        if s.hasPrefix("#") { s.removeFirst() }
        guard s.count == 6 || s.count == 8, let v = UInt64(s, radix: 16) else { self = fallback; return }
        let r, g, b, a: Double
        if s.count == 6 {
            r = Double((v >> 16) & 0xFF) / 255; g = Double((v >> 8) & 0xFF) / 255
            b = Double(v & 0xFF) / 255; a = 1
        } else {
            r = Double((v >> 24) & 0xFF) / 255; g = Double((v >> 16) & 0xFF) / 255
            b = Double((v >> 8) & 0xFF) / 255; a = Double(v & 0xFF) / 255
        }
        self = Color(.sRGB, red: r, green: g, blue: b, opacity: a)
    }
}

// MARK: - 主题提供器（App 全局注入）

@MainActor
public final class ThemeProvider: ObservableObject {
    @Published public private(set) var theme: BoothTheme

    public init(theme: BoothTheme = BoothTheme()) {
        self.theme = theme
    }

    /// 从主题目录加载 theme.json（找不到/损坏 → 保留默认并记日志）
    public func load(name: String) {
        let url = BoothPaths.themesDir.appendingPathComponent("\(name)/theme.json")
        guard let data = try? Data(contentsOf: url) else {
            Log.ui.info("主题 \(name) 无 theme.json，用默认主题")
            return
        }
        do {
            theme = try JSONDecoder().decode(BoothTheme.self, from: data)
            Log.ui.info("主题已切换: \(name)")
        } catch {
            Log.ui.error("主题 \(name) 解析失败: \(error.localizedDescription)，用默认主题")
        }
    }
}

// MARK: - 环境注入

private struct ThemeKey: EnvironmentKey {
    static let defaultValue = BoothTheme()
}

public extension EnvironmentValues {
    var boothTheme: BoothTheme {
        get { self[ThemeKey.self] }
        set { self[ThemeKey.self] = newValue }
    }
}

// MARK: - 便捷访问（组件内统一入口）

public extension BoothTheme {
    var accentColor: Color { Color(hex: accent) }
    var accentSecondaryColor: Color { Color(hex: accentSecondary) }
    var backgroundColor: Color { Color(hex: background) }
    var backgroundSecondaryColor: Color { Color(hex: backgroundSecondary) }
    var textColor: Color { Color(hex: text) }
    var textSecondaryColor: Color { Color(hex: textSecondary) }
    var textOnAccentColor: Color { Color(hex: textOnAccent) }
    var successColor: Color { Color(hex: success) }
    var warningColor: Color { Color(hex: warning) }
    var dangerColor: Color { Color(hex: danger) }

    func titleFont(_ size: CGFloat = 56) -> Font {
        fontName.isEmpty ? .system(size: size, weight: .heavy, design: .rounded) : .custom(fontName, size: size)
    }
    func bodyFont(_ size: CGFloat = 24, weight: Font.Weight = .semibold) -> Font {
        fontName.isEmpty ? .system(size: size, weight: weight, design: .rounded) : .custom(fontName, size: size)
    }
    var bounce: Animation { .spring(response: bounceDuration, dampingFraction: 0.65) }
}
