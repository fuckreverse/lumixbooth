import SwiftUI
import BoothCore

// ============================================================
// 可复用组件（可爱风、全部走 BoothTheme，页面拼装用）
// ============================================================

/// 主按钮：大圆角胶囊 + 弹性按压
public struct BoothPrimaryButton: View {
    @Environment(\.boothTheme) private var theme
    let title: String
    let emoji: String?
    let action: () -> Void

    public init(_ title: String, emoji: String? = nil, action: @escaping () -> Void) {
        self.title = title; self.emoji = emoji; self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                if let emoji { Text(emoji).font(.system(size: 28)) }
                Text(title).font(theme.bodyFont(26, weight: .bold))
            }
            .foregroundStyle(theme.textOnAccentColor)
            .padding(.horizontal, 36).padding(.vertical, 18)
            .background(theme.accentColor, in: Capsule())
            .shadow(color: theme.accentColor.opacity(0.35), radius: 12, y: 6)
        }
        .buttonStyle(BoothBounceStyle())
    }
}

/// 次按钮：描边胶囊
public struct BoothSecondaryButton: View {
    @Environment(\.boothTheme) private var theme
    let title: String
    let emoji: String?
    let action: () -> Void

    public init(_ title: String, emoji: String? = nil, action: @escaping () -> Void) {
        self.title = title; self.emoji = emoji; self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let emoji { Text(emoji).font(.system(size: 22)) }
                Text(title).font(theme.bodyFont(22))
            }
            .foregroundStyle(theme.accentColor)
            .padding(.horizontal, 28).padding(.vertical, 14)
            .background(theme.backgroundSecondaryColor, in: Capsule())
            .overlay(Capsule().stroke(theme.accentColor, lineWidth: 2.5))
        }
        .buttonStyle(BoothBounceStyle())
    }
}

/// 弹性按压效果（全 App 统一手感）
public struct BoothBounceStyle: ButtonStyle {
    public init() {}
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1)
            .animation(.spring(response: 0.25, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

/// 圆角卡片容器
public struct BoothCard<Content: View>: View {
    @Environment(\.boothTheme) private var theme
    @ViewBuilder let content: Content

    public init(@ViewBuilder content: () -> Content) { self.content = content() }

    public var body: some View {
        content
            .padding(24)
            .background(theme.backgroundSecondaryColor, in: RoundedRectangle(cornerRadius: theme.cornerRadius, style: .continuous))
            .shadow(color: theme.textColor.opacity(0.08), radius: 16, y: 6)
    }
}

/// 状态胶囊（相机连接、打印队列等）
public struct BoothStatusPill: View {
    @Environment(\.boothTheme) private var theme
    let emoji: String
    let text: String
    let tint: Color

    public init(emoji: String, text: String, tint: Color) {
        self.emoji = emoji; self.text = text; self.tint = tint
    }

    public var body: some View {
        HStack(spacing: 6) {
            Text(emoji).font(.system(size: 16))
            Text(text).font(theme.bodyFont(16, weight: .bold))
        }
        .foregroundStyle(tint)
        .padding(.horizontal, 16).padding(.vertical, 8)
        .background(tint.opacity(0.14), in: Capsule())
    }

    public static func camera(_ state: CameraConnectionState, theme: BoothTheme) -> BoothStatusPill {
        switch state {
        case .liveView: return .init(emoji: "🟢", text: "相机就绪", tint: theme.successColor)
        case .connected: return .init(emoji: "🟡", text: "相机已连接", tint: theme.warningColor)
        case .searching, .connecting: return .init(emoji: "🟡", text: "连接相机中…", tint: theme.warningColor)
        case .reconnecting: return .init(emoji: "🟠", text: "重连中…", tint: theme.warningColor)
        case .disconnected: return .init(emoji: "🔴", text: "相机未连接", tint: theme.dangerColor)
        }
    }
}

/// 待机页漂浮 emoji 背景（吸引页氛围）
public struct FloatingEmojis: View {
    @Environment(\.boothTheme) private var theme
    @State private var animate = false

    public init() {}

    public var body: some View {
        GeometryReader { geo in
            ForEach(Array(theme.idleEmojis.enumerated()), id: \.offset) { i, emoji in
                Text(emoji)
                    .font(.system(size: 44))
                    .opacity(0.25)
                    .position(
                        x: geo.size.width * CGFloat(0.12 + 0.19 * Double(i % 5)),
                        y: animate
                            ? geo.size.height * CGFloat(0.15 + 0.2 * Double((i + 2) % 4))
                            : geo.size.height * CGFloat(0.25 + 0.2 * Double(i % 4))
                    )
                    .animation(
                        .easeInOut(duration: 2.4 + 0.4 * Double(i)).repeatForever(autoreverses: true),
                        value: animate
                    )
            }
        }
        .onAppear { animate = true }
        .allowsHitTesting(false)
    }
}

/// 倒计时大数字（弹性缩放切换）
public struct CountdownNumber: View {
    @Environment(\.boothTheme) private var theme
    let value: Int

    public init(_ value: Int) { self.value = value }

    public var body: some View {
        Text("\(value)")
            .font(theme.titleFont(220))
            .foregroundStyle(theme.accentColor)
            .shadow(color: theme.accentColor.opacity(0.3), radius: 20)
            .id(value)   // 值变即重建，触发转场
            .transition(.scale(scale: 0.3).combined(with: .opacity))
    }
}

// MARK: - 预览

#Preview("组件") {
    let theme = BoothTheme()
    VStack(spacing: 20) {
        BoothPrimaryButton("开始拍照", emoji: "📸") {}
        BoothSecondaryButton("重拍", emoji: "🔄") {}
        BoothStatusPill.camera(.liveView, theme: theme)
        BoothCard { Text("卡片内容") }
        CountdownNumber(3)
    }
    .padding()
    .environment(\.boothTheme, theme)
}
