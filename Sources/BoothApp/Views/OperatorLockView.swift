import SwiftUI
import BoothCore
import BoothUI

// ============================================================
// OperatorLockView — 操作员门禁锁屏（进入操作员页先验证）
//  - 验证：4-6 位数字 PIN（触屏数字键盘 + 物理键盘均可输入）
//  - 物理键盘：视图自身 focusable + onKeyPress 承接数字/退格/回车
//  - 首次引导：无 PIN 时进入「设置 PIN / 暂不设置」双路流程
//  - 防爆破反馈：剩余尝试次数、锁定倒计时
//  - pendingQuit：退出保护拦截后，验证通过即退出；Esc 取消
//  - Esc 任意时刻返回宾客大屏（宾客按 Esc 看到的只是这堵墙）
// ============================================================

struct OperatorLockView: View {
    @Environment(\.boothTheme) private var theme
    @ObservedObject var gate: OperatorGate

    /// 引导子阶段（仅 hasPIN == false 时出现）
    enum SetupPhase { case enter, confirm }
    @State private var setupPhase: SetupPhase = .enter
    @State private var firstPIN = ""

    @State private var entered = ""
    @State private var feedback: String?
    @State private var shakeTrigger = 0
    @State private var showSkipConfirm = false
    /// 物理键盘接收焦点（点键盘/点圆点后也要回焦，否则敲键无响应）
    @FocusState private var keyboardFocused: Bool

    private let pinRange = 4...6

    var body: some View {
        VStack(spacing: 28) {
            header

            if gate.hasPIN {
                verifyPad
            } else {
                setupPad
            }

            if gate.hasPIN, !gate.protectionOptOut {
                Text("按 Esc 返回宾客大屏")
                    .font(theme.bodyFont(16, weight: .regular))
                    .foregroundStyle(theme.textSecondaryColor)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(theme.backgroundColor.ignoresSafeArea())
        .onAppear { keyboardFocused = true }
        // 锁定倒计时结束/进行中，让界面自己动起来刷新剩余秒数文本
        .background(TimelineView(.periodic(from: .now, by: 0.5)) { _ in Color.clear })
        // 物理键盘：数字 / 退格 / 回车（其余键忽略，Esc 继续冒泡给 RootView）
        .focusable()
        .focused($keyboardFocused)
        .focusEffectDisabled()
        .onKeyPress { press in
            guard press.modifiers.isEmpty else { return .ignored }
            switch press.key {
            case KeyEquivalent.delete:
                if !entered.isEmpty { entered.removeLast(); feedback = nil }
                return .handled
            case KeyEquivalent.return:
                submitCurrent()
                return .handled
            default:
                guard let c = press.characters.first, c.isASCII, c.isNumber,
                      entered.count < 6 else { return .ignored }
                entered.append(c)
                feedback = nil
                return .handled
            }
        }
    }

    // MARK: - 头部

    private var header: some View {
        VStack(spacing: 10) {
            BoothIcon(emoji: gate.pendingQuit ? "🛑" : "🔒", size: 68)
            Text(titleText)
                .font(theme.titleFont(34))
                .foregroundStyle(theme.textColor)
            Text(subtitleText)
                .font(theme.bodyFont(17, weight: .regular))
                .foregroundStyle(theme.textSecondaryColor)
        }
        .padding(.top, 60)
    }

    private var titleText: String {
        if gate.pendingQuit { return "输入 PIN 以退出 Booth" }
        return gate.hasPIN ? "操作员验证" : "首次使用，请设置 PIN"
    }

    private var subtitleText: String {
        if gate.pendingQuit { return "验证通过后将退出应用；按 Esc 可取消" }
        if gate.hasPIN { return "输入 4-6 位数字 PIN（物理键盘 / 点按均可）进入操作员后台" }
        return "保护无人值守时的配置；也可以选择暂不设置"
    }

    // MARK: - PIN 屏显圆点（点按可把焦点拿回键盘输入）

    private var dots: some View {
        HStack(spacing: 16) {
            ForEach(0..<6, id: \.self) { i in
                Circle()
                    .fill(i < entered.count ? theme.accentColor : theme.backgroundSecondaryColor)
                    .overlay(Circle().stroke(theme.accentSecondaryColor, lineWidth: 2))
                    .frame(width: 22, height: 22)
            }
        }
        .modifier(ShakeEffect(travel: 10, shakes: 4, animatableData: CGFloat(shakeTrigger)))
        .onTapGesture { keyboardFocused = true }
    }

    // MARK: - 验证流程（已有 PIN）

    private var verifyPad: some View {
        VStack(spacing: 22) {
            dots
            feedbackText

            if gate.lockoutRemainingSec > 0 {
                TimelineView(.periodic(from: .now, by: 1)) { context in
                    let remaining = Int(gate.lockoutRemainingSec)
                    Text("尝试次数过多，已锁定\n请 \(max(remaining, 0)) 秒后再试")
                        .font(theme.bodyFont(18))
                        .foregroundStyle(theme.dangerColor)
                        .multilineTextAlignment(.center)
                }
            } else {
                keypad(enabled: true)
            }
        }
    }

    // MARK: - 首次设置流程（无 PIN）

    private var setupPad: some View {
        VStack(spacing: 22) {
            Text(setupPhase == .enter ? "第一步：输入新的 PIN（4-6 位数字）" : "第二步：再输入一次确认")
                .font(theme.bodyFont(19))
                .foregroundStyle(theme.textColor)
            dots
            feedbackText

            // 触屏 kiosk 也要能完成首次引导（与验证页同一套键盘）
            keypad(enabled: true)

            HStack(spacing: 30) {
                BoothSecondaryButton(setupPhase == .enter ? "继续" : "确认设置", emoji: "✅") {
                    submitCurrent()
                }
                .disabled(!pinRange.contains(entered.count))

                BoothSecondaryButton("上一步", emoji: "↩️") {
                    guard setupPhase == .confirm else { return }
                    setupPhase = .enter
                    firstPIN = ""
                    entered = ""
                    feedback = nil
                }
                .disabled(setupPhase == .enter)
            }

            BoothSecondaryButton("暂不设置保护（不推荐）", emoji: "🙈") {
                showSkipConfirm = true
            }
            .confirmationDialog("不设置 PIN，宾客将可直接进入操作员页修改配置。\n确定继续吗？",
                                isPresented: $showSkipConfirm, titleVisibility: .visible) {
                Button("暂不设置", role: .destructive) { Task { await gate.skipSetup() } }
                Button("取消", role: .cancel) {}
            }
        }
    }

    @ViewBuilder
    private var feedbackText: some View {
        if let feedback {
            Text(feedback)
                .font(theme.bodyFont(17))
                .foregroundStyle(theme.dangerColor)
                .multilineTextAlignment(.center)
        }
    }

    // MARK: - 数字键盘

    private func keypad(enabled: Bool) -> some View {
        VStack(spacing: 12) {
            ForEach([["1", "2", "3"], ["4", "5", "6"], ["7", "8", "9"]], id: \.self) { row in
                HStack(spacing: 18) {
                    ForEach(row, id: \.self) { key in
                        keypadButton(key)
                    }
                }
            }
            HStack(spacing: 18) {
                keypadButton("删除", systemImage: "delete.left")
                keypadButton("0")
                keypadButton("确定", systemImage: "checkmark.circle.fill")
            }
        }
        .opacity(enabled ? 1 : 0.4)
        .environment(\.isEnabled, enabled)
    }

    private func keypadButton(_ label: String, systemImage: String? = nil) -> some View {
        Button {
            tapKey(label)
        } label: {
            Group {
                if let systemImage {
                    Image(systemName: systemImage).font(.system(size: 26))
                } else {
                    Text(label).font(theme.titleFont(30))
                }
            }
            .frame(width: 88, height: 70)
            .background(theme.backgroundSecondaryColor)
            .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadiusSmall))
            .overlay(
                RoundedRectangle(cornerRadius: theme.cornerRadiusSmall)
                    .stroke(theme.accentSecondaryColor, lineWidth: 2)
            )
        }
        .buttonStyle(BoothBounceStyle())
        .foregroundStyle(theme.textColor)
    }

    private func tapKey(_ key: String) {
        keyboardFocused = true   // 点按后把焦点拿回，物理键盘继续可用
        switch key {
        case "删除":
            if !entered.isEmpty { entered.removeLast() }
            feedback = nil
        case "确定":
            submitCurrent()
        default:
            if entered.count < 6 { entered.append(key) }
        }
    }

    // MARK: - 提交

    private func submitCurrent() {
        keyboardFocused = true
        guard pinRange.contains(entered.count) else {
            feedback = "PIN 需为 4-6 位数字"
            shake()
            return
        }
        if gate.hasPIN {
            Task {
                let ok = await gate.submitPIN(entered)
                if !ok {
                    entered = ""
                    if gate.lockoutRemainingSec > 0 {
                        feedback = nil
                    } else {
                        let left = gate.maxWrongAttempts - gate.wrongAttempts
                        feedback = "PIN 不正确，还可尝试 \(left) 次"
                    }
                    shake()
                }
            }
        } else {
            Task {
                switch setupPhase {
                case .enter:
                    firstPIN = entered
                    entered = ""
                    feedback = nil
                    setupPhase = .confirm
                case .confirm:
                    guard entered == firstPIN else {
                        feedback = "两次输入不一致，请重新设置"
                        entered = ""
                        firstPIN = ""
                        setupPhase = .enter
                        shake()
                        return
                    }
                    _ = await gate.completeSetup(pin: entered)
                }
            }
        }
    }

    private func shake() {
        withAnimation(theme.bounce) { shakeTrigger += 1 }
    }
}

// MARK: - 抖动效果

struct ShakeEffect: GeometryEffect {
    var travel: CGFloat
    var shakes: CGFloat
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX:
            travel * sin(animatableData * .pi * shakes * 2), y: 0))
    }
}
