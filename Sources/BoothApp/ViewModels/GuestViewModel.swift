import AppKit
import BoothCore
import SessionEngine

// ============================================================
// 宾客大屏视图模型
//  - 订阅 SessionCoordinator 状态流 / LiveView 帧流
//  - 相机连接状态轮询（协议无推送，1s 轮询足够 UI 用）
//  - 帧显示抽稀：UI 刷新封顶 ~15fps，防大屏卡顿
// ============================================================

/// LiveView 帧显示 store（抽稀后供 SwiftUI 显示）
@MainActor
final class LiveViewStore: ObservableObject {
    @Published private(set) var image: NSImage?
    private var task: Task<Void, Never>?
    private var lastUpdate = Date.distantPast
    /// UI 刷新间隔（~15fps）
    private let minInterval: TimeInterval = 1.0 / 15.0

    /// 开始消费帧流（重复调用会替换旧订阅）
    func start(frames: AsyncStream<Data>) {
        task?.cancel()
        task = Task { [weak self] in
            for await data in frames {
                guard let self, !Task.isCancelled else { return }
                let now = Date()
                // 抽稀：距离上次刷新不足间隔则丢帧（解码是主要开销，直接不解）
                guard now.timeIntervalSince(self.lastUpdate) >= self.minInterval else { continue }
                self.lastUpdate = now
                self.image = NSImage(data: data)
            }
        }
    }

    func stop() {
        task?.cancel()
        task = nil
    }
}

/// 宾客大屏 VM：状态机镜像 + 外部控制 API 转发
@MainActor
final class GuestViewModel: ObservableObject {
    @Published private(set) var state: BoothState = .idle
    @Published private(set) var cameraState: CameraConnectionState = .disconnected
    @Published private(set) var mode: ShootMode = .collage(4)
    @Published private(set) var defaultCopies = 2
    /// 拍后自选滤镜（REVIEW 态大屏选择条；跟随配置 filterSelection 开关）
    @Published private(set) var filterSelection = true
    @Published private(set) var currentFilter: PhotoFilter = .none
    /// 操作员用 P 键触发打印（printKeyEnabled 开关）
    @Published private(set) var printKeyEnabled = true
    /// 大屏是否显示打印按钮（showPrintButton 开关；关闭时仅 iPad / P 键可打印）
    @Published private(set) var showPrintButton = true
    /// SELECT 选片页是否显示拼图样式条（跟 layoutSelection 开关）
    @Published private(set) var layoutSelectionShown = true
    /// 当前选中的拼图样式（SELECT 态；初始为模式布局）
    @Published private(set) var currentLayout: CollageLayout = .strip
    /// 触发方式（大屏快捷胶囊切换，持久生效）
    @Published private(set) var triggerStyle = TriggerStyle.countdown
    /// IDLE 背景历史成片轮播开关
    @Published private(set) var idleSlideshow = true

    let liveView = LiveViewStore()

    private let coordinator: SessionCoordinator
    private let camera: any CameraServicing
    private var tasks: [Task<Void, Never>] = []
    private var started = false

    // ---- 省电模式（idle N 分钟调暗大屏/暂停轮播） ----
    /// 待机超过阈值后置 true（GuestIdleView 盖半透明黑罩 + 停轮播）
    @Published private(set) var idleDimmed = false
    /// 省电阈值分钟（0 = 关闭；热更新生效）
    private var idleDimAfterMin = 10
    private var idleTimer: Task<Void, Never>?

    init(coordinator: SessionCoordinator, camera: any CameraServicing) {
        self.coordinator = coordinator
        self.camera = camera
    }

    /// 启动全部订阅（视图 .task 调用，幂等）
    func start() {
        guard !started else { return }
        started = true
        Log.ui.info("宾客大屏 VM 启动订阅")

        // ① 状态流（状态机 → 大屏页面切换）
        tasks.append(Task { [weak self] in
            guard let self else { return }
            for await s in await self.coordinator.states() {
                self.state = s
                // 省电模式：任何状态变化都重置待机调暗计时（状态离开 idle 即亮屏）
                self.resetIdleDim()
                // 回到待机/引导阶段时刷新模式与默认份数（iPad 可能改过）
                switch s {
                case .idle, .armed, .gestureWait:
                    self.refreshModeAndCopies()
                case .select(let sel):
                    // 选片页初始选中样式 = 当前模式布局
                    self.currentLayout = sel.defaultLayout
                default:
                    break
                }
                // REVIEW 态同步当前滤镜（大屏选择条高亮与状态机一致）
                if case .review = s {
                    Task { self.currentFilter = await self.coordinator.currentFilter }
                }
            }
        })

        // ② LiveView 帧流（抽稀显示）
        tasks.append(Task { [weak self] in
            guard let self else { return }
            let frames = await self.coordinator.frames()
            self.liveView.start(frames: frames)
        })

        // ③ 相机连接状态轮询（1s 一拍）
        tasks.append(Task { [weak self] in
            while !Task.isCancelled {
                guard let self else { return }
                let s = await self.camera.connectionState
                if s != self.cameraState { self.cameraState = s }
                try? await Task.sleep(nanoseconds: 1_000_000_000)
            }
        })

        refreshModeAndCopies()
    }

    private func refreshModeAndCopies() {
        Task { [weak self] in
            guard let self else { return }
            self.mode = await self.coordinator.mode
            let cfg = await ConfigStore.shared.config
            self.defaultCopies = cfg.printing.defaultCopies
            self.filterSelection = cfg.imaging.filterSelection
            self.printKeyEnabled = cfg.printing.printKeyEnabled
            self.showPrintButton = cfg.printing.showPrintButton
            self.layoutSelectionShown = cfg.capture.layoutSelection
            self.triggerStyle = cfg.capture.triggerStyle
            self.idleSlideshow = cfg.capture.idleSlideshow
            self.idleDimAfterMin = cfg.capture.idleDimAfterMin
            // 配置热更新后重估当前待机调暗状态
            self.resetIdleDim()
        }
    }

    // MARK: - 省电模式（借鉴商业软件 idle dim）

    /// 重置待机计时：离开 idle / 配置变更时调；idle 中重新挂 N 分钟闹钟
    private func resetIdleDim() {
        idleTimer?.cancel()
        idleDimmed = false
        guard idleDimAfterMin > 0, case .idle = state else { return }
        let minutes = idleDimAfterMin
        idleTimer = Task { [weak self] in
            try? await Task.sleep(nanoseconds: UInt64(minutes) * 60_000_000_000)
            guard !Task.isCancelled else { return }
            self?.idleDimmed = true   // 触发大屏盖罩 + 停轮播
            Log.ui.info("省电模式：待机 \(minutes) 分钟，大屏调暗/暂停轮播")
        }
    }

    // MARK: - 外部控制（键盘 / 大屏按钮）

    /// 空格：手动触发拍摄（手势失效兜底）
    func triggerStart() {
        Task { await coordinator.start() }
    }

    /// R / 重拍按钮
    func retake() {
        Task { await coordinator.retake() }
    }

    /// 大屏打印按钮（默认份数）
    func confirmPrint() {
        Task { await coordinator.confirmPrint(copies: defaultCopies) }
    }

    /// 取消回待机
    func cancel() {
        Task { await coordinator.cancel() }
    }

    /// idle 页模式选择
    func selectMode(_ newMode: ShootMode) {
        guard newMode != mode else { return }
        mode = newMode // 先本地高亮，状态机接受与否以下次刷新为准
        Task { await coordinator.setMode(newMode) }
        Log.ui.info("宾客选择模式：\(newMode.kind.rawValue)×\(newMode.shots)")
    }

    /// REVIEW 态换滤镜（大屏选择条；状态机重打成片后推新 review 状态）
    func selectFilter(_ filter: PhotoFilter) {
        currentFilter = filter // 先本地高亮
        Task { await coordinator.selectFilter(filter) }
        Log.ui.info("宾客选择滤镜：\(filter.displayName)")
    }

    /// 省电调暗下触碰大屏：揭罩回亮（轮播恢复；重新计时）
    func wakeFromDim() {
        resetIdleDim()
        Log.ui.info("省电调暗下触碰大屏，已揭罩回亮")
    }

    // MARK: - SELECT 态选片（拍后挑一张 / 挑拼图样式）

    /// 选片页点拼图样式（只改选中高亮，出片时随指令提交）
    func selectLayout(_ layout: CollageLayout) {
        currentLayout = layout
    }

    /// 选片页确认出片：single 只出点选那张；collage 用当前选中样式；filter 为选片页预览所选修图风格
    func confirmSelection(kind: ShootKind, indexes: [Int], filter: PhotoFilter = .none) {
        Task { await coordinator.selectOutput(kind: kind, layout: currentLayout, indexes: indexes, filter: filter) }
        Log.ui.info("选片确认: kind=\(kind.rawValue) layout=\(currentLayout.rawValue) filter=\(filter.rawValue) indexes=\(indexes)")
    }

}
