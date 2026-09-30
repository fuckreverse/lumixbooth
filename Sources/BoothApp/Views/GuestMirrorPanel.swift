import SwiftUI
import BoothCore
import BoothUI

// ============================================================
// 宾客镜像面板（操作台右侧常驻）
//  - 与 iPad 宾客屏同源：同一个 GuestViewModel 状态流 + LiveView 帧流
//    （纯视图复用，Mac 切操作员页/看队列不影响此画面与拍照流程）
//  - 兼作 iPad 在线监测：iPad 断线/掉线时镜像与 iPad 内容差异一目了然
//  - 画面按 1280×800 设计画布等比缩放，保证小面板内布局与大屏完全一致
// ============================================================

struct GuestMirrorPanel: View {
    @Environment(\.boothTheme) private var theme
    @ObservedObject var composition: AppComposition
    @ObservedObject var vm: GuestViewModel

    /// iPad WS 在线数（3s 轮询；nil = 尚未取到）
    @State private var iPadCount: Int?

    /// 镜像画布设计尺寸（GuestScreen 按大屏排版设计，等比缩放进面板）
    private let designSize = CGSize(width: 1280, height: 800)

    var body: some View {
        VStack(spacing: 10) {
            header
            mirrorBody
            footer
        }
        .padding(14)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(theme.backgroundSecondaryColor.ignoresSafeArea())
        .task { await pollClients() }
    }

    // MARK: - 头部：标题 + 状态/在线胶囊 + 放大按钮

    private var header: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                BoothIcon(emoji: "🪞", size: 22)
                Text("宾客画面")
                    .font(theme.bodyFont(17, weight: .bold))
                    .foregroundStyle(theme.textColor)
                Spacer()
                BoothSecondaryButton("全屏", emoji: "⤢") {
                    composition.showingOperator = false
                    Log.ui.info("镜像面板：切换宾客画面全屏")
                }
            }
            HStack(spacing: 8) {
                BoothStatusPill(emoji: stateEmoji, text: stateLabel, tint: stateTint)
                BoothStatusPill(emoji: "📱", text: iPadStatusText,
                                tint: (iPadCount ?? 0) > 0 ? theme.successColor : theme.warningColor)
                Spacer()
            }
        }
    }

    // MARK: - 镜像主体：等比缩放的 GuestScreen

    private var mirrorBody: some View {
        GeometryReader { geo in
            let scale = min(geo.size.width / designSize.width,
                            geo.size.height / designSize.height)
            GuestScreen(composition: composition, vm: vm)
                .frame(width: designSize.width, height: designSize.height)
                .scaleEffect(scale)
                .frame(width: geo.size.width, height: geo.size.height)
                .background(theme.backgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadiusSmall, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: theme.cornerRadiusSmall, style: .continuous)
                        .stroke(theme.accentSecondaryColor, lineWidth: 1.5)
                )
                .shadow(color: theme.textColor.opacity(0.08), radius: 8, y: 3)
        }
    }

    private var footer: some View {
        Text("与 iPad 宾客屏实时同步，可直接点击操作")
            .font(theme.bodyFont(12))
            .foregroundStyle(theme.textSecondaryColor)
    }

    // MARK: - iPad 在线数轮询

    private func pollClients() async {
        while !Task.isCancelled {
            iPadCount = await composition.server.clientCount()
            try? await Task.sleep(nanoseconds: 3_000_000_000)
        }
    }

    private var iPadStatusText: String {
        guard composition.serverRunning else { return "服务未启动" }
        guard let n = iPadCount else { return "检测中…" }
        return n > 0 ? "iPad 已连接 ×\(n)" : "iPad 未连接"
    }

    // MARK: - 状态胶囊文案

    private var stateLabel: String {
        switch vm.state {
        case .idle: return "待机"
        case .armed: return "已就绪"
        case .gestureWait: return "等待手势"
        case .countdown: return "倒计时"
        case .capturing(let shot, let of): return "拍摄中 \(shot)/\(of)"
        case .select: return "选片中"
        case .processing: return "修图中"
        case .review: return "确认成片"
        case .printing(let copies): return "打印中 ×\(copies)"
        case .failure: return "故障"
        }
    }

    private var stateEmoji: String {
        switch vm.state {
        case .idle: return "💤"
        case .armed: return "🧍"
        case .gestureWait: return "✌️"
        case .countdown: return "⏱️"
        case .capturing: return "📷"
        case .select: return "🖼️"
        case .processing: return "✨"
        case .review: return "💖"
        case .printing: return "🖨️"
        case .failure: return "⚠️"
        }
    }

    private var stateTint: Color {
        switch vm.state {
        case .failure: return theme.warningColor
        case .idle: return theme.textSecondaryColor
        default: return theme.successColor
        }
    }
}
