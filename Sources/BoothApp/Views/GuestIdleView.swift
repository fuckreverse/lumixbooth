import SwiftUI
import BoothCore
import BoothUI

/// 待机吸引页：漂浮 emoji + 大标题 + 模式选择 + 相机状态胶囊 + iPad 二维码
struct GuestIdleView: View {
    @Environment(\.boothTheme) private var theme
    @ObservedObject var composition: AppComposition
    @ObservedObject var vm: GuestViewModel

    var body: some View {
        ZStack {
            theme.backgroundColor.ignoresSafeArea()
            FloatingEmojis()

            VStack(spacing: 30) {
                Spacer()
                Text(theme.mascotEmoji).font(.system(size: 84))
                Text("LUMIX 拍照亭")
                    .font(theme.titleFont(56))
                    .foregroundStyle(theme.textColor)
                Text("靠近一点，我们开始吧 💖")
                    .font(theme.bodyFont(26))
                    .foregroundStyle(theme.textSecondaryColor)

                // 拍摄模式选择（两个大卡片，选中高亮）
                HStack(spacing: 28) {
                    ModeCard(title: "单张美照", subtitle: "1 张直出 6 寸", emoji: "🌟",
                             selected: vm.mode.kind == .single) {
                        vm.selectMode(.single)
                    }
                    ModeCard(title: "四连拍拼版", subtitle: "4 张拼大头贴条", emoji: "🎞️",
                             selected: vm.mode.kind == .collage) {
                        vm.selectMode(.collage(4))
                    }
                }

                // 触摸兜底（手势失效也能玩）
                BoothPrimaryButton("点我开始拍照", emoji: "📸") { vm.triggerStart() }
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // 左上角：操作员入口
            VStack {
                HStack {
                    BoothSecondaryButton("操作员", emoji: "⚙️") {
                        composition.showingOperator = true
                        Log.ui.info("齿轮按钮进入操作员页")
                    }
                    .padding(24)
                    Spacer()
                }
                Spacer()
            }

            // 右上角：相机状态胶囊
            VStack {
                HStack {
                    Spacer()
                    BoothStatusPill.camera(vm.cameraState, theme: theme)
                        .padding(24)
                }
                Spacer()
            }

            // 右下角：iPad 连接二维码
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    qrBlock
                        .padding(24)
                }
            }
        }
    }

    /// iPad 确认屏二维码（服务未启动时显示提示）
    @ViewBuilder
    private var qrBlock: some View {
        VStack(spacing: 8) {
            if let urlString = composition.iPadURL,
               let qr = QRCodeMaker.image(for: urlString, pixels: 240) {
                Image(nsImage: qr)
                    .resizable()
                    .interpolation(.none)   // 关闭插值，保像素边缘
                    .frame(width: 120, height: 120)
                    .padding(10)
                    .background(theme.backgroundSecondaryColor,
                                in: RoundedRectangle(cornerRadius: theme.cornerRadiusSmall, style: .continuous))
                Text("iPad 扫码当确认屏")
                    .font(theme.bodyFont(15, weight: .bold))
                    .foregroundStyle(theme.textSecondaryColor)
            } else {
                Text("📱")
                    .font(.system(size: 40))
                Text(composition.serverRunning ? "正在获取地址…" : "iPad 服务未启动")
                    .font(theme.bodyFont(15, weight: .bold))
                    .foregroundStyle(theme.textSecondaryColor)
            }
        }
    }
}

/// 模式选择大卡片（选中高亮描边 + 弹性按压）
private struct ModeCard: View {
    @Environment(\.boothTheme) private var theme
    let title: String
    let subtitle: String
    let emoji: String
    let selected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Text(emoji).font(.system(size: 52))
                Text(title)
                    .font(theme.bodyFont(24, weight: .bold))
                    .foregroundStyle(selected ? theme.accentColor : theme.textColor)
                Text(subtitle)
                    .font(theme.bodyFont(16))
                    .foregroundStyle(theme.textSecondaryColor)
            }
            .frame(width: 240, height: 170)
            .background(theme.backgroundSecondaryColor,
                        in: RoundedRectangle(cornerRadius: theme.cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: theme.cornerRadius, style: .continuous)
                    .stroke(theme.accentColor, lineWidth: selected ? 4 : 0)
            )
            .shadow(color: theme.textColor.opacity(0.08), radius: 14, y: 5)
            .scaleEffect(selected ? 1.04 : 1)
            .animation(theme.bounce, value: selected)
        }
        .buttonStyle(BoothBounceStyle())
    }
}
