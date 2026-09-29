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

    let liveView = LiveViewStore()

    private let coordinator: SessionCoordinator
    private let camera: any CameraServicing
    private var tasks: [Task<Void, Never>] = []
    private var started = false

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
                // 回到待机/引导阶段时刷新模式与默认份数（iPad 可能改过）
                switch s {
                case .idle, .armed, .gestureWait:
                    self.refreshModeAndCopies()
                default:
                    break
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
            self.defaultCopies = await ConfigStore.shared.config.printing.defaultCopies
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
}
