import SwiftUI
import AppKit
import BoothCore
import BoothUI
import CameraKit
import VisionKit
import ImagingKit
import PrintKit
import BoothServer
import SessionEngine

// ============================================================
// BoothApp 组装根 + @main 入口
//  - 按依赖序构建七大模块：CameraKit → VisionKit → ImagingKit →
//    PrintKit → BoothServer → SessionCoordinator（SPEC §2）
//  - 启动参数含 -mock 时用 MockCameraService（UI 开发/无相机演示）
//  - 退出前经 AppDelegate 停 Web 服务、断相机
// ============================================================

/// 给 AppDelegate 传递组装根的弱引用盒（Delegate 由系统实例化，无法注入构造参数）
private enum CompositionHolder {
    @MainActor static weak var composition: AppComposition?
}

/// 应用组装根：唯一持有全部模块实例的地方
@MainActor
final class AppComposition: ObservableObject {
    let isMock: Bool
    let camera: any CameraServicing
    let gesture: GestureDetector
    let readiness: PoseReadinessDetector
    let segmenter: PersonSegmenter
    let landmarker: FaceLandmarkDetector
    let imaging: ImagingService
    let printer: PrintService
    let server: BoothWebService
    let coordinator: SessionCoordinator

    /// 是否显示操作员页（Esc / 齿轮按钮切换）
    @Published var showingOperator = false
    /// Web 服务是否在跑（idle 页决定是否显示二维码）
    @Published var serverRunning = false
    /// iPad 访问地址（服务启动后算出，供二维码）
    @Published var iPadURL: String?
    /// 操作员门禁（PIN 验证 / 防爆破退避 / 退出保护拦截）
    let gate = OperatorGate()
    /// 退出保护开关镜像（config 热更新；AppDelegate 同步读）
    @Published var quitProtection = true

    private var configWatchTask: Task<Void, Never>?
    private var started = false

    init() {
        let args = ProcessInfo.processInfo.arguments
        isMock = args.contains("-mock")
        Log.ui.info("═══ App 组装开始（模式：\(isMock ? "Mock 演示" : "真机")）═══")

        // ① 相机：-mock 时用合成相机，不接真机
        if isMock {
            camera = MockCameraService()
            Log.ui.info("模块[1/6] 相机 = MockCameraService")
        } else {
            camera = LumixCameraService()
            Log.ui.info("模块[1/6] 相机 = LumixCameraService（libLmxptpif）")
        }
        // ② 视觉四件套（手势 / 姿势就绪 / 人像分割 / 人脸关键点）
        gesture = GestureDetector()
        readiness = PoseReadinessDetector()
        segmenter = PersonSegmenter()
        landmarker = FaceLandmarkDetector()
        Log.ui.info("模块[2/6] 视觉 = GestureDetector + PoseReadinessDetector + PersonSegmenter + FaceLandmarkDetector")
        // ③ 修图管线（注入人像分割 + 人脸关键点：换背景 / 搞怪装饰能力）
        imaging = ImagingService(segmenter: segmenter, landmarker: landmarker)
        Log.ui.info("模块[3/6] 修图 = ImagingService(segmenter:landmarker:)")
        // ④ 打印队列（CUPS 后端）
        printer = PrintService()
        Log.ui.info("模块[4/6] 打印 = PrintService")
        // ⑤ iPad Web 服务：同步读一遍配置文件快照（ConfigStore 是 actor 不能同步读，
        //    这里直接解码同一 config.json，数据一致；BoothWebService 构造时需要端口）
        let conf = Self.loadConfigSnapshot()
        server = BoothWebService(conf: conf)
        quitProtection = conf.security.quitProtection
        Log.ui.info("模块[5/6] 服务 = BoothWebService（端口 \(conf.server.port)）")
        // ⑥ 状态机：注入全部协议服务
        coordinator = SessionCoordinator(
            camera: camera, gesture: gesture, readiness: readiness,
            imaging: imaging, printer: printer, server: server)
        Log.ui.info("模块[6/6] 状态机 = SessionCoordinator（全依赖注入完成）")
        Log.ui.info("═══ App 组装完成 ═══")
    }

    /// 同步读配置快照（仅组装期用；运行期一律走 ConfigStore）
    private static func loadConfigSnapshot() -> BoothConfig {
        if let data = try? Data(contentsOf: BoothPaths.configFile) {
            return BoothConfig.load(from: data)   // 缺字段补默认 + 净化
        }
        return BoothConfig()
    }

    /// 启动序列：主题 → 状态机后台运行 → Web 服务 → 配置热更新监听。幂等。
    func start(theme: ThemeProvider) async {
        guard !started else { return }
        started = true
        Log.ui.info("启动序列开始")

        // 主题按配置加载（无 theme.json 自动回退默认奶油风）
        let cfg = await ConfigStore.shared.config
        theme.load(name: cfg.imaging.themeName)

        // 状态机后台运行（内部自动尝试相机 connect + startLiveView，失败靠 CameraKit 重连）
        await coordinator.begin()
        Log.ui.info("状态机已后台运行（相机连接交给 CameraKit 自重连）")

        // 门禁快照加载（是否有 PIN / 是否放弃保护）
        await gate.refreshState()

        // Web 服务：失败记日志不崩 app
        if cfg.server.enabled {
            await startServer()
        } else {
            Log.ui.info("Web 服务已在配置中关闭，跳过启动")
        }

        watchConfig()
        Log.ui.info("启动序列完成")
    }

    private func startServer() async {
        do {
            try await server.start()
            serverRunning = true
            if let ip = LANAddress.localIPv4() {
                iPadURL = "http://\(ip):\(server.port)"
                Log.ui.info("iPad 确认屏地址：\(iPadURL!)")
            } else {
                Log.ui.warn("未找到局域网 IP，二维码不可用")
            }
        } catch {
            serverRunning = false
            iPadURL = nil
            Log.ui.error("Web 服务启动失败（不影响拍照主流程）: \(error.localizedDescription)")
        }
    }

    /// 配置热更新：打印段即时生效；服务器开关即时生效（端口变更需重启 App）
    private func watchConfig() {
        configWatchTask = Task { [weak self] in
            var first = true
            for await cfg in await ConfigStore.shared.stream() {
                guard let self else { return }
                if first { first = false; continue } // 首帧是当前值，跳过
                self.quitProtection = cfg.security.quitProtection
                await self.printer.applyConfig(cfg.printing)
                if cfg.server.enabled, !self.serverRunning {
                    Log.ui.info("配置变更：Web 服务打开，正在启动…")
                    await self.startServer()
                } else if !cfg.server.enabled, self.serverRunning {
                    Log.ui.info("配置变更：Web 服务关闭，正在停止…")
                    await self.server.stop()
                    self.serverRunning = false
                    self.iPadURL = nil
                }
            }
        }
    }

    /// 退出前清理：停 Web 服务 + 断相机
    func shutdown() async {
        Log.ui.info("退出清理：停止 Web 服务…")
        await server.stop()
        Log.ui.info("退出清理：断开相机…")
        await camera.disconnect()
        configWatchTask?.cancel()
        Log.ui.info("退出清理完成")
    }
}

/// App 生命周期代理：退出前停服务/断相机（terminateLater 等清理完再退）
final class BoothAppDelegate: NSObject, NSApplicationDelegate {
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        // 退出保护：门禁锁定时关窗不退出（防宾客关掉 App）。
        // 回调固定在主线程，assumeIsolated 安全
        if let c = CompositionHolder.composition,
           MainActor.assumeIsolated({ quitBlocked(c) }) {
            return false
        }
        return true
    }

    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        // 退出保护：门禁锁定时拦截退出，弹锁屏验证（Esc 取消 / 验证通过放行）
        if let c = CompositionHolder.composition,
           MainActor.assumeIsolated({ quitBlocked(c) }) {
            MainActor.assumeIsolated {
                c.gate.requestQuit()
                c.showingOperator = true
            }
            return .terminateCancel
        }
        Task { @MainActor in
            guard let composition = CompositionHolder.composition else {
                NSApp.reply(toApplicationShouldTerminate: true)
                return
            }
            Log.ui.info("收到退出请求，开始清理")
            await composition.shutdown()
            NSApp.reply(toApplicationShouldTerminate: true)
        }
        return .terminateLater
    }

    /// 退出是否被拦：开关打开且门禁生效中（未设 PIN / 放弃保护时无从验证 → 不拦）
    @MainActor
    private func quitBlocked(_ c: AppComposition) -> Bool {
        c.quitProtection && c.gate.quitGuardActive && c.gate.isLocked
    }
}

// MARK: - @main

@main
struct BoothAppMain: App {
    @NSApplicationDelegateAdaptor(BoothAppDelegate.self) private var appDelegate
    @StateObject private var theme = ThemeProvider()
    @StateObject private var composition: AppComposition

    init() {
        let c = AppComposition()
        CompositionHolder.composition = c
        _composition = StateObject(wrappedValue: c)
    }

    var body: some Scene {
        WindowGroup {
            RootView(composition: composition)
                .environment(\.boothTheme, theme.theme)
                .frame(minWidth: 1100, minHeight: 760)
                .background(WindowConfigurator(isMock: composition.isMock))
                .task { await composition.start(theme: theme) }
        }
        .windowStyle(.hiddenTitleBar)
    }
}

// MARK: - 根视图（宾客大屏 ⇄ 操作员页）

struct RootView: View {
    @Environment(\.boothTheme) private var theme
    @ObservedObject var composition: AppComposition
    @ObservedObject private var gate: OperatorGate
    @StateObject private var guestVM: GuestViewModel

    init(composition: AppComposition) {
        _composition = ObservedObject(wrappedValue: composition)
        _gate = ObservedObject(wrappedValue: composition.gate)
        _guestVM = StateObject(wrappedValue: GuestViewModel(
            coordinator: composition.coordinator, camera: composition.camera))
    }

    var body: some View {
        ZStack {
            if composition.showingOperator {
                if gate.isLocked {
                    // 门禁锁屏：验证前不暴露任何操作员界面
                    OperatorLockView(gate: gate)
                        .transition(.opacity)
                } else {
                    OperatorScreen(composition: composition)
                        .transition(.opacity)
                }
            } else {
                GuestScreen(composition: composition, vm: guestVM)
                    .transition(.opacity)
            }
        }
        .animation(theme.bounce, value: composition.showingOperator)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(theme.backgroundColor.ignoresSafeArea())
        .focusable()
        .focusEffectDisabled()
        // 快捷键（SPEC §9）：空格=手动触发，R=重拍，P=打印（操作员），Esc=操作员页往返。
        // 操作员页打开时空格/R 不触发拍摄（防宾客按 Esc 后空格还能隔着锁屏拍照）
        .onKeyPress(.space) {
            guard !composition.showingOperator else { return .handled }
            guestVM.triggerStart(); return .handled
        }
        .onKeyPress(KeyEquivalent("r")) {
            guard !composition.showingOperator else { return .handled }
            guestVM.retake(); return .handled
        }
        .onKeyPress(KeyEquivalent("R")) {
            guard !composition.showingOperator else { return .handled }
            guestVM.retake(); return .handled
        }
        .onKeyPress(KeyEquivalent("p")) { handlePrintKey(); return .handled }
        .onKeyPress(KeyEquivalent("P")) { handlePrintKey(); return .handled }
        .onKeyPress(.escape) { toggleOperatorPage(); return .handled }
        .task { guestVM.start() }
        // 进入操作员页：门禁拦截（放弃保护者自动放行）；返回宾客大屏：重新上锁
        .onChange(of: composition.showingOperator) { _, showing in
            if showing {
                Task { await gate.entryRequested() }
            } else {
                gate.lock()
            }
        }
    }

    /// Esc：进操作员页（同时退出全屏）；在操作员页按 Esc 返回宾客大屏
    private func toggleOperatorPage() {
        if composition.showingOperator {
            composition.showingOperator = false
        } else {
            if let window = NSApp.keyWindow, window.styleMask.contains(.fullScreen) {
                window.toggleFullScreen(nil)
            }
            composition.showingOperator = true
            Log.ui.info("进入操作员页")
        }
    }

    /// P 键打印（PhotoBoothProject 借鉴）：操作员兜底打印通道，配置可关
    private func handlePrintKey() {
        guard guestVM.printKeyEnabled else { return }
        Log.ui.info("P 键触发打印")
        guestVM.confirmPrint()
    }
}

// MARK: - 窗口配置（标题 / 默认全屏）

/// 拿到 NSWindow 做一次性配置：标题（Mock 加后缀）+ 默认全屏
private struct WindowConfigurator: NSViewRepresentable {
    let isMock: Bool

    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            guard let window = view.window else { return }
            window.title = isMock ? "LUMIX Photobooth [Mock]" : "LUMIX Photobooth"
            window.isMovableByWindowBackground = true
            // 默认全屏（宾客大屏形态）；Esc 进操作员页时退出全屏
            if !window.styleMask.contains(.fullScreen) {
                window.toggleFullScreen(nil)
            }
            Log.ui.info("窗口已配置：标题=\(window.title) 全屏=是")
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {}
}
