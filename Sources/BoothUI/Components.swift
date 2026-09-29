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
                if let emoji { BoothIcon(emoji: emoji, size: 30) }
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
                if let emoji { BoothIcon(emoji: emoji, size: 24) }
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
            BoothIcon(emoji: emoji, size: 17)
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
                BoothIcon(emoji: emoji, size: 48)
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

// MARK: - 操作员页控件（替代系统原生样式的主题化组件）

/// 迷你胶囊按钮（页内联操作：刷新 / 重试 / 移除 / Finder 直达）
public struct BoothMiniButton: View {
    @Environment(\.boothTheme) private var theme
    let title: String
    let tint: Color
    let action: () -> Void

    public init(_ title: String, tint: Color? = nil, action: @escaping () -> Void) {
        self.title = title
        self.tint = tint ?? .clear   // nil 时在 body 里回退主题色
        self.action = action
        self.useThemeTint = tint == nil
    }

    private let useThemeTint: Bool

    public var body: some View {
        let color = useThemeTint ? theme.accentColor : tint
        return Button(action: action) {
            Text(title)
                .font(theme.bodyFont(15, weight: .bold))
                .padding(.horizontal, 14).padding(.vertical, 7)
        }
        .foregroundStyle(color)
        .background(color.opacity(0.12), in: Capsule())
        .buttonStyle(BoothBounceStyle())
    }
}

/// 主题化分段选择器（替代系统 .segmented Picker）
public struct BoothSegmented<T: Hashable>: View {
    @Environment(\.boothTheme) private var theme
    public struct Option {
        public let value: T
        public let title: String
        public init(_ value: T, _ title: String) { self.value = value; self.title = title }
    }
    let options: [Option]
    @Binding var selection: T

    public init(_ options: [Option], selection: Binding<T>) {
        self.options = options
        self._selection = selection
    }

    public var body: some View {
        HStack(spacing: 4) {
            ForEach(options, id: \.value) { opt in
                let selected = opt.value == selection
                Button {
                    withAnimation(theme.bounce) { selection = opt.value }
                } label: {
                    Text(opt.title)
                        .font(theme.bodyFont(15, weight: .bold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .padding(.horizontal, 12).padding(.vertical, 8)
                        .background(selected ? theme.accentColor : Color.clear, in: Capsule())
                }
                .foregroundStyle(selected ? theme.textOnAccentColor : theme.textColor)
                .buttonStyle(BoothBounceStyle())
            }
        }
        .padding(4)
        .background(theme.backgroundSecondaryColor, in: Capsule())
        .overlay(Capsule().stroke(theme.accentSecondaryColor, lineWidth: 1.5))
    }
}

/// 主题化开关（替代系统 Toggle：整行可点 + 自绘胶囊滑块）
public struct BoothToggle: View {
    @Environment(\.boothTheme) private var theme
    let title: String
    @Binding var isOn: Bool

    public init(_ title: String, isOn: Binding<Bool>) {
        self.title = title
        self._isOn = isOn
    }

    public var body: some View {
        Button {
            withAnimation(theme.bounce) { isOn.toggle() }
        } label: {
            HStack(spacing: 12) {
                Text(title)
                    .font(theme.bodyFont(17))
                    .foregroundStyle(theme.textColor)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                track
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private var track: some View {
        ZStack {
            Capsule().fill(isOn ? theme.accentColor : theme.backgroundSecondaryColor)
            Circle()
                .fill(Color.white)
                .shadow(color: .black.opacity(0.2), radius: 2, y: 1)
                .frame(width: 22, height: 22)
                .offset(x: isOn ? 12 : -12)
        }
        .frame(width: 52, height: 30)
        .overlay(Capsule().stroke(theme.accentSecondaryColor, lineWidth: 1.5))
    }
}

/// 主题化步进器（替代系统 Stepper：− 值 +）
public struct BoothStepper: View {
    @Environment(\.boothTheme) private var theme
    @Binding var value: Int
    let range: ClosedRange<Int>
    let step: Int
    let format: (Int) -> String

    public init(value: Binding<Int>, in range: ClosedRange<Int>,
                step: Int = 1, format: @escaping (Int) -> String = { "\($0)" }) {
        self._value = value
        self.range = range
        self.step = step
        self.format = format
    }

    public var body: some View {
        HStack(spacing: 0) {
            stepButton("−") { value = max(range.lowerBound, value - step) }
                .opacity(value <= range.lowerBound ? 0.35 : 1)
            Rectangle().fill(theme.accentSecondaryColor).frame(width: 1, height: 24)
            Text(format(value))
                .font(theme.bodyFont(16, weight: .bold))
                .foregroundStyle(theme.textColor)
                .monospacedDigit()
                .frame(minWidth: 110)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Rectangle().fill(theme.accentSecondaryColor).frame(width: 1, height: 24)
            stepButton("+") { value = min(range.upperBound, value + step) }
                .opacity(value >= range.upperBound ? 0.35 : 1)
        }
        .background(theme.backgroundSecondaryColor,
                    in: RoundedRectangle(cornerRadius: theme.cornerRadiusSmall, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: theme.cornerRadiusSmall, style: .continuous)
            .stroke(theme.accentSecondaryColor, lineWidth: 1.5))
    }

    private func stepButton(_ symbol: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(symbol)
                .font(theme.bodyFont(18, weight: .bold))
                .foregroundStyle(theme.accentColor)
                .frame(width: 38, height: 36)
                .contentShape(Rectangle())
        }
        .buttonStyle(BoothBounceStyle())
    }
}

/// 主题化输入框（替代 .roundedBorder 原生文本框；聚焦描主色边）
public struct BoothTextField: View {
    @Environment(\.boothTheme) private var theme
    let placeholder: String
    @Binding var text: String
    let secure: Bool
    let onSubmit: (() -> Void)?
    @FocusState private var focused: Bool

    public init(_ placeholder: String, text: Binding<String>,
                secure: Bool = false, onSubmit: (() -> Void)? = nil) {
        self.placeholder = placeholder
        self._text = text
        self.secure = secure
        self.onSubmit = onSubmit
    }

    public var body: some View {
        Group {
            if secure {
                SecureField(placeholder, text: $text)
            } else {
                TextField(placeholder, text: $text)
            }
        }
        .focused($focused)
        .font(theme.bodyFont(16))
        .foregroundStyle(theme.textColor)
        .onSubmit { onSubmit?() }
        .padding(.horizontal, 14).padding(.vertical, 9)
        .background(theme.backgroundSecondaryColor,
                    in: RoundedRectangle(cornerRadius: theme.cornerRadiusSmall, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: theme.cornerRadiusSmall, style: .continuous)
            .stroke(focused ? theme.accentColor : theme.accentSecondaryColor,
                    lineWidth: focused ? 2 : 1.5))
    }
}

/// 主题化滑杆（替代系统 Slider：胶囊轨道 + 可拖圆钮）
public struct BoothSlider: View {
    @Environment(\.boothTheme) private var theme
    @Binding var value: Double
    let range: ClosedRange<Double>

    public init(value: Binding<Double>, in range: ClosedRange<Double>) {
        self._value = value
        self.range = range
    }

    private var fraction: CGFloat {
        let span = range.upperBound - range.lowerBound
        return span <= 0 ? 0 : CGFloat((value - range.lowerBound) / span)
    }

    public var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            ZStack(alignment: .leading) {
                Capsule().fill(theme.backgroundSecondaryColor)
                Capsule().fill(theme.accentColor).frame(width: max(18, w * fraction))
                Circle()
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.2), radius: 2, y: 1)
                    .frame(width: 22, height: 22)
                    .offset(x: min(max(0, w * fraction - 11), max(0, w - 22)))
            }
            .frame(height: geo.size.height)
            .contentShape(Rectangle())
            .gesture(DragGesture(minimumDistance: 0).onChanged { g in
                let f = min(max(0, g.location.x / max(w, 1)), 1)
                value = range.lowerBound + (range.upperBound - range.lowerBound) * Double(f)
            })
        }
        .frame(height: 30)
        .overlay(Capsule().stroke(theme.accentSecondaryColor, lineWidth: 1.5))
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
