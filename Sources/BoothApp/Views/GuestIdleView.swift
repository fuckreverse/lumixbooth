import SwiftUI
import BoothCore
import BoothUI

/// 待机吸引页：背景历史成片轮播 + 漂浮 emoji + 大标题 + 模式选择 + 相机状态胶囊 + iPad 二维码
struct GuestIdleView: View {
    @Environment(\.boothTheme) private var theme
    @ObservedObject var composition: AppComposition
    @ObservedObject var vm: GuestViewModel

    var body: some View {
        ZStack {
            theme.backgroundColor.ignoresSafeArea()

            // 背景历史成片轮播（配置开启且未省电调暗时；给路过的宾客看“现场能拍出什么”）
            if vm.idleSlideshow && !vm.idleDimmed {
                IdleHistorySlideshow()
            }

            FloatingEmojis()

            VStack(spacing: 30) {
                Spacer()
                BoothIcon(emoji: theme.mascotEmoji, size: 96)
                Text("LUMIX 拍照亭")
                    .font(theme.titleFont(56))
                    .foregroundStyle(theme.textColor)
                HStack(spacing: 6) {
                    Text("靠近一点，我们开始吧")
                    BoothIcon(emoji: "💖", size: 26)
                }
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

                // 触发方式快捷切换（免密，持久生效）：手势 ↔ 倒计时
                BoothStatusPill(emoji: vm.triggerStyle.emoji,
                               text: vm.triggerStyle.displayName + "（点我切换）",
                               tint: theme.accentColor)
                    .onTapGesture { vm.toggleTriggerStyle() }
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

            // 省电调暗罩：待机超过配置分钟后盖半透明黑罩（任何状态变化自动揭罩）
            if vm.idleDimmed {
                Color.black.opacity(0.82).ignoresSafeArea()
                    .transition(.opacity)
                    .onTapGesture { vm.wakeFromDim() }
            }
        }
        .animation(theme.bounce, value: vm.idleDimmed)
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
                BoothIcon(emoji: "📱", size: 44)
                Text(composition.serverRunning ? "正在获取地址…" : "iPad 服务未启动")
                    .font(theme.bodyFont(15, weight: .bold))
                    .foregroundStyle(theme.textSecondaryColor)
            }
        }
    }
}

/// IDLE 背景历史成片轮播：扫 sessions/ 目录，隔配置秒数淡入淡出切图
/// （大屏吸引力用；淡到 12% 透明度不干扰前景内容，无历史则不显示）
private struct IdleHistorySlideshow: View {
    @Environment(\.boothTheme) private var theme
    @State private var images: [NSImage] = []
    @State private var index = 0
    @State private var timer: Timer?

    var body: some View {
        ZStack {
            if images.isEmpty {
                Color.clear
            } else if let img = images.indices.contains(index) ? images[index] : nil {
                GeometryReader { geo in
                    Image(nsImage: img)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geo.size.width, height: geo.size.height)
                        .clipped()
                }
                .opacity(0.12)
                .blur(radius: 1)
            }
        }
        .allowsHitTesting(false)
        .task {
            loadImages()
            startTimer()
        }
        .onDisappear { timer?.invalidate() }
    }

    /// 扫最近会话的 display.jpg（最多 12 张，够轮播不扫全盘）
    private func loadImages() {
        let fm = FileManager.default
        let root = BoothPaths.sessionsDir
        guard let days = try? fm.contentsOfDirectory(at: root, includingPropertiesForKeys: [.isDirectoryKey])
            .filter({ (try? $0.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) == true }) else { return }
        var urls: [URL] = []
        for dayDir in days.sorted(by: { $0.lastPathComponent > $1.lastPathComponent }) {
            guard let sessions = try? fm.contentsOfDirectory(at: dayDir, includingPropertiesForKeys: [.isDirectoryKey])
                .filter({ (try? $0.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) == true }) else { continue }
            for s in sessions.sorted(by: { $0.lastPathComponent > $1.lastPathComponent }) {
                let display = s.appendingPathComponent("display.jpg")
                if fm.fileExists(atPath: display.path) { urls.append(display) }
                if urls.count >= 12 { break }
            }
            if urls.count >= 12 { break }
        }
        images = urls.compactMap { NSImage(contentsOf: $0) }
        if images.count > 1 { images.shuffle() }   // 打乱避免总从最新一张开始
        Log.ui.debug("IDLE 轮播加载 \(images.count) 张历史成片")
    }

    private func startTimer() {
        Task { @MainActor in
            let sec = await ConfigStore.shared.config.capture.idleSlideshowSec
            let interval = Double(max(2, sec))
            timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
                Task { @MainActor in
                    if !images.isEmpty { index = (index + 1) % images.count }
                }
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
                BoothIcon(emoji: emoji, size: 56)
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
