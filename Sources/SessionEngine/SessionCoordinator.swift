import Foundation
import BoothCore

// ============================================================
// SessionCoordinator —— 拍照流程状态机（SPEC §3），全 App 的编排中枢。
//
// 职责：
//  1. 严格按 SPEC §3 驱动 idle→armed→gestureWait→countdown→capturing
//     →processing→review→printing→idle 状态机，每次转移同步四路：
//     Log.session 日志 / 内部状态流 / EventBus / BoothServer 广播。
//  2. 唯一消费 camera.liveViewFrames（防止多消费者抢流），职责三分发：
//     UI 重广播（bufferingNewest(2)）/ iPad MJPEG 推流（配置开关）/ 抽帧检测。
//  3. 姿势与手势的连续帧防抖判定（BoothCore 契约规定防抖由本模块负责）。
//  4. 倒计时、连拍编排（collage 循环 shots 次）、修图、REVIEW 决策、打印。
//  5. 相机断线 / 拍照失败 / 修图失败的降级恢复（failure 态展示后回 idle）。
//
// 使用约定：构造后必须调用 begin() 启动帧消费/事件消费/指令消费任务；
// 手动触发拍摄用 start()（与手势命中等价）。
// ============================================================
public actor SessionCoordinator {

    // MARK: - 依赖注入（全部走 BoothCore 协议，测试用 Mock 替换）

    private let camera: any CameraServicing
    private let gesture: any GestureDetecting
    private let readiness: any PoseReadinessDetecting
    private let imaging: any ImagingServing
    private let printer: any PrintServing
    private let server: (any BoothWebServing)?
    private let config: ConfigStore
    private let bus: EventBus

    // MARK: - 状态

    /// 当前流程状态（UI / 测试轮询入口）
    public private(set) var state: BoothState = .idle
    /// 当前拍摄模式（IDLE 页可选，begin() 时从配置加载默认值）
    public private(set) var mode: ShootMode = .collage(4)
    private var modeLoaded = false
    /// 当前生效滤镜（拍后自选；流程启动时重置为配置默认值）
    public private(set) var currentFilter: PhotoFilter = .none

    // MARK: - 可调延迟（测试加速用；nil = 跟随配置）

    /// failure 态展示时长（SPEC：5s）
    public var failureDwell: TimeInterval = 5
    /// printing 态完成后停留时长；nil = 用配置 printingDwellSec（原硬编码 3s）
    public var printingDwell: TimeInterval?

    /// 调整停留时长（测试加速 / 运营微调用；actor 属性不允许外部直接赋值）
    public func setDwell(failure: TimeInterval? = nil, printing: TimeInterval? = nil) {
        if let failure { failureDwell = failure }
        if let printing { printingDwell = printing }
    }

    // MARK: - 内部任务

    private var started = false
    private var frameTask: Task<Void, Never>?      // 唯一帧消费者
    private var eventTask: Task<Void, Never>?      // 相机事件消费者
    private var commandTask: Task<Void, Never>?    // iPad 指令消费者
    private var flowTask: Task<Void, Never>?       // 当前拍摄流程（倒计时→…→review）
    private var timeoutTask: Task<Void, Never>?    // armed / gestureWait / review 超时
    private var dwellTask: Task<Void, Never>?      // failure / printing 停留计时

    // MARK: - 防抖计数

    private var frameIndex = 0        // 帧序号（detectEveryNFrames 抽帧用）
    private var readyStreak = 0       // armed 态连续就绪帧
    private var absentStreak = 0      // armed 态连续无人帧
    private var gestureStreak = 0     // gestureWait 态连续手势命中帧

    // MARK: - 重广播流（UI 订阅）

    private var frameConts: [UUID: AsyncStream<Data>.Continuation] = [:]
    private var stateConts: [UUID: AsyncStream<BoothState>.Continuation] = [:]

    // MARK: - 初始化

    public init(camera: any CameraServicing,
                gesture: any GestureDetecting,
                readiness: any PoseReadinessDetecting,
                imaging: any ImagingServing,
                printer: any PrintServing,
                server: (any BoothWebServing)? = nil,
                config: ConfigStore = .shared,
                bus: EventBus = .shared) {
        self.camera = camera
        self.gesture = gesture
        self.readiness = readiness
        self.imaging = imaging
        self.printer = printer
        self.server = server
        self.config = config
        self.bus = bus
        Log.session.info("SessionCoordinator 已组装（server=\(server == nil ? "无" : "有")）")
    }

    // MARK: - 生命周期

    /// 启动引擎：连接相机（尽力而为）+ 三个消费任务（帧 / 相机事件 / iPad 指令）。幂等。
    public func begin() async {
        guard !started else { return }
        started = true
        if !modeLoaded {
            mode = (await config.config).capture.defaultMode
            modeLoaded = true
        }
        Log.session.info("引擎启动，默认模式=\(mode.kind.rawValue) shots=\(mode.shots)")
        // 相机连接：失败不阻断启动——CameraKit 自带重连，恢复事件会驱动状态机回 idle
        Task { [camera] in
            do { try await camera.connect() } catch {
                Log.session.warn("相机连接失败（等待自动重连）: \(error.localizedDescription)")
            }
            do { try await camera.startLiveView() } catch {
                Log.session.warn("LiveView 启动失败（等待自动重连）: \(error.localizedDescription)")
            }
        }
        // 唯一帧消费者：所有对 camera.liveViewFrames 的订阅只允许发生在这里
        frameTask = Task { await self.consumeFrames() }
        eventTask = Task { await self.consumeCameraEvents() }
        commandTask = Task { await self.consumeServerCommands() }
    }

    // MARK: - 对外流

    /// UI 用 LiveView 帧流（重广播，bufferingNewest(2) 防慢消费者堆积）
    public func frames() -> AsyncStream<Data> {
        let id = UUID()
        return AsyncStream(bufferingPolicy: .bufferingNewest(2)) { cont in
            frameConts[id] = cont
            cont.onTermination = { [weak self] _ in
                Task { await self?.removeFrameCont(id) }
            }
        }
    }

    /// 内部状态流（比 EventBus 更轻量的直订阅，UI 可二选一）
    public func states() -> AsyncStream<BoothState> {
        let id = UUID()
        return AsyncStream(bufferingPolicy: .bufferingNewest(8)) { cont in
            cont.yield(state) // 新订阅者立即拿到当前态
            stateConts[id] = cont
            cont.onTermination = { [weak self] _ in
                Task { await self?.removeStateCont(id) }
            }
        }
    }

    private func removeFrameCont(_ id: UUID) { frameConts.removeValue(forKey: id) }
    private func removeStateCont(_ id: UUID) { stateConts.removeValue(forKey: id) }

    // MARK: - 外部控制 API（UI / 快捷键 / 测试）

    /// 手动触发拍摄（空格键兜底），与手势命中等价。
    /// 仅 idle / armed / gestureWait 合法，其余态记 warn 忽略。
    public func start() async {
        switch state {
        case .idle, .armed, .gestureWait:
            Log.session.info("手动触发拍摄（当前态 \(describe(state))）")
            await beginShootFlow(reason: "手动触发")
        default:
            Log.session.warn("当前态 \(describe(state)) 不允许手动触发，已忽略")
        }
    }

    /// 重拍：仅 REVIEW 态合法，直接回到 COUNTDOWN 重新走流程（新会话目录）
    public func retake() async {
        guard case .review(let photo) = state else {
            Log.session.warn("当前态 \(describe(state)) 不允许重拍，已忽略")
            return
        }
        Log.session.info("用户选择重拍（放弃成片 \(photo.id.uuidString.prefix(8))）")
        await beginShootFlow(reason: "REVIEW 重拍")
    }

    /// 确认打印：仅 REVIEW 态合法；份数按配置 min/max 截断
    public func confirmPrint(copies: Int) async {
        guard case .review = state else {
            Log.session.warn("当前态 \(describe(state)) 不允许确认打印，已忽略")
            return
        }
        await confirmPrintInternal(copies: copies, reason: "用户确认打印")
    }

    /// REVIEW 态换滤镜（拍后自选）：重打成片后回 REVIEW（新成片 id，iPad 端换图自然避缓存）
    public func selectFilter(_ filter: PhotoFilter) async {
        guard case .review(let photo) = state else {
            Log.session.warn("当前态 \(describe(state)) 不允许换滤镜，已忽略")
            return
        }
        guard filter != currentFilter else { return }   // 幂等
        Log.session.info("REVIEW 换滤镜: \(currentFilter.rawValue) → \(filter.rawValue)")
        let sessionDir = photo.printFile.deletingLastPathComponent()
        do {
            let newPhoto = try await imaging.applyFilter(filter, to: photo, sessionDir: sessionDir)
            currentFilter = filter
            if newPhoto.id != photo.id {
                // 重打成功：注册新下载地址 + 重新广播 REVIEW（超时计时重置，宾客在活跃操作）
                if let server { await server.publishPhoto(newPhoto) }
                let cfg = await config.config
                await enterReview(newPhoto, cfg: cfg)
            } else {
                // 无底图不支持重打（Mock/旧会话）：仅更新标记，成片保持
                Log.session.warn("换滤镜重打不可用，保持当前成片")
            }
        } catch {
            Log.session.warn("换滤镜失败，保持当前成片: \(describeError(error))")
        }
    }

    /// 取消：任意态回 idle 并清理全部在途任务
    public func cancel() async {
        Log.session.info("外部取消（当前态 \(describe(state))）")
        flowTask?.cancel(); flowTask = nil
        timeoutTask?.cancel(); timeoutTask = nil
        dwellTask?.cancel(); dwellTask = nil
        resetStreaks()
        await transition(.idle, reason: "外部取消")
    }

    /// 切换拍摄模式：待机/引导阶段合法，流程中记 warn 忽略
    public func setMode(_ newMode: ShootMode) async {
        switch state {
        case .idle, .armed, .gestureWait:
            mode = newMode
            Log.session.info("拍摄模式切换为 \(newMode.kind.rawValue)×\(newMode.shots)")
        default:
            Log.session.warn("当前态 \(describe(state)) 不允许切模式，已忽略")
        }
    }

    // MARK: - 帧消费（唯一消费者）

    private func consumeFrames() async {
        Log.session.info("帧消费任务启动（唯一消费者）")
        for await frame in camera.liveViewFrames {
            await handleFrame(frame)
        }
        Log.session.notice("LiveView 帧流结束（相机停止取流）")
    }

    private func handleFrame(_ frame: Data) async {
        let cfg = await config.config
        // ① UI 重广播
        for cont in frameConts.values { cont.yield(frame) }
        // ② iPad MJPEG 推流（配置开关，服务内部再做降频/丢帧）
        if cfg.server.liveViewToIpad, let server {
            await server.pushLiveViewFrame(frame)
        }
        // ③ 抽帧检测：拍摄流程进行中（flowTask 在跑）不做检测
        guard flowTask == nil else { return }
        let every = max(1, cfg.vision.detectEveryNFrames)
        frameIndex += 1
        guard frameIndex % every == 0 else { return }

        switch state {
        case .idle:
            // IDLE 也要跑就绪检测——SPEC：ARMED 进入条件是"检测到人进入取景区域"
            guard cfg.vision.poseReadinessEnabled else { return }
            let r = await readiness.detectReadiness(in: frame)
            if r.humanPresent {
                Log.session.debug("IDLE 检测到人（人脸占比 \(String(format: "%.3f", r.faceAreaRatio))）")
                await transition(.armed, reason: "检测到人进入取景区域")
                startArmedTimeout(cfg)
            }

        case .armed:
            guard cfg.vision.poseReadinessEnabled else { return }
            let r = await readiness.detectReadiness(in: frame)
            if r.isReady {
                readyStreak += 1
                absentStreak = 0
                Log.session.debug("姿势就绪命中 \(readyStreak)/\(cfg.vision.readyFrames) 帧")
                if readyStreak >= cfg.vision.readyFrames {
                    readyStreak = 0
                    timeoutTask?.cancel(); timeoutTask = nil
                    await transition(.gestureWait, reason: "姿势就绪（连续 \(cfg.vision.readyFrames) 帧）")
                    startGestureTimeout(cfg)
                }
            } else {
                readyStreak = 0
                if r.humanPresent {
                    absentStreak = 0
                } else {
                    absentStreak += 1
                    Log.session.debug("人离开画面 \(absentStreak)/\(cfg.vision.readyFrames) 帧")
                    // 人消失连续若干帧（复用 readyFrames 作阈值）→ 回 idle
                    if absentStreak >= cfg.vision.readyFrames {
                        await resetToIdle("人离开画面（连续 \(absentStreak) 帧）")
                    }
                }
            }

        case .gestureWait:
            guard cfg.vision.gestureEnabled else { return }
            if let g = await gesture.detectGesture(in: frame) {
                gestureStreak += 1
                Log.session.debug("手势命中 \(g.rawValue) \(gestureStreak)/\(cfg.vision.gestureHitFrames) 帧")
                if gestureStreak >= cfg.vision.gestureHitFrames {
                    await beginShootFlow(reason: "手势命中（\(g.rawValue) 连续 \(gestureStreak) 帧）")
                }
            } else if gestureStreak > 0 {
                gestureStreak = 0
                Log.session.debug("手势中断，连续计数清零")
            }

        default:
            break // 其余状态不需要视觉检测
        }
    }

    // MARK: - 拍摄流程（gestureWait 命中 / 手动触发 / 重拍共用）

    private func beginShootFlow(reason: String) async {
        timeoutTask?.cancel(); timeoutTask = nil
        dwellTask?.cancel(); dwellTask = nil
        resetStreaks()
        flowTask?.cancel()
        let sessionDir = BoothPaths.newSessionDir()
        let m = mode
        Log.session.info("拍摄流程启动（\(reason)）mode=\(m.kind.rawValue)×\(m.shots) session=\(sessionDir.lastPathComponent)")
        flowTask = Task { await self.runShootFlow(sessionDir: sessionDir, mode: m) }
    }

    private func runShootFlow(sessionDir: URL, mode m: ShootMode) async {
        let cfg = await config.config
        let shots = max(1, m.shots)
        var originals: [CameraCapture] = []
        // 连拍不中断（PhotoBoothProject 借鉴）：拼版仅首张倒计时，后续张间短暂停顿立即连拍
        let continuous = m.kind == .collage && cfg.capture.continuousCollage
        currentFilter = cfg.imaging.defaultFilter
        if continuous {
            Log.session.info("连拍不中断模式：\(shots) 张，仅首张倒计时")
        }

        for shot in 1...shots {
            if continuous && shot > 1 {
                // 张间短停顿：给宾客摆下一个姿势的节奏，不停倒计时
                try? await Task.sleep(nanoseconds: 800_000_000)
                if Task.isCancelled { return }
            } else {
                // 倒计时（countdownSec=0 跳过；collage 每张独立倒计时）
                var n = max(0, cfg.capture.countdownSec)
                while n > 0 {
                    await transition(.countdown(secondsLeft: n), reason: "第 \(shot)/\(shots) 张倒计时")
                    await bus.publish(.countdownTick(n))
                    Log.session.info("倒计时 tick=\(n)（第 \(shot)/\(shots) 张）")
                    do {
                        try await Task.sleep(nanoseconds: 1_000_000_000)
                    } catch {
                        return // 流程被取消（cancel / 相机断线）
                    }
                    n -= 1
                }
                if Task.isCancelled { return }
            }

            await transition(.capturing(shot: shot, of: shots),
                             reason: shots > 1 ? "连拍第 \(shot)/\(shots) 张" : "快门")
            guard let cap = await captureWithRetry(cfg) else { return } // 失败已转 failure 态
            originals.append(cap)
            Log.session.info("第 \(shot)/\(shots) 张拍摄完成 \(cap.fileName)（\(cap.data.count)B）")
        }

        await transition(.processing, reason: "全部拍摄完成（\(originals.count) 张），开始修图")
        do {
            let photo = try await imaging.process(originals: originals, mode: m, sessionDir: sessionDir)
            if let server { await server.publishPhoto(photo) } // 注册 /photo/{id} 供 QR 下载
            flowTask = nil // 流程主体结束，REVIEW 决策交由外部 API / 超时驱动
            await enterReview(photo, cfg: cfg)
        } catch {
            await failAndRecover("修图失败: \(describeError(error))")
        }
    }

    /// 拍照（含超时重试：captureRetry 次额外尝试）。失败返回 nil，且已转入 failure 态。
    private func captureWithRetry(_ cfg: BoothConfig) async -> CameraCapture? {
        let attempts = max(1, cfg.camera.captureRetry + 1)
        for attempt in 1...attempts {
            do {
                return try await camera.capture()
            } catch is CancellationError {
                return nil // 流程被取消，静默退出（状态已由取消方处理）
            } catch {
                Log.session.error("拍照失败（第 \(attempt)/\(attempts) 次）: \(describeError(error))")
            }
        }
        await failAndRecover("拍照失败（已重试 \(attempts - 1) 次）")
        return nil
    }

    // MARK: - REVIEW 决策

    private func enterReview(_ photo: ProcessedPhoto, cfg: BoothConfig) async {
        await transition(.review(photo), reason: "修图完成，等待确认")
        let photoID = photo.id
        timeoutTask?.cancel()
        timeoutTask = Task {
            let sec = max(0.1, Double(cfg.capture.reviewTimeoutSec))
            try? await Task.sleep(nanoseconds: UInt64(sec * 1_000_000_000))
            guard !Task.isCancelled, case .review(let current) = state, current.id == photoID else { return }
            if cfg.capture.autoPrintOnTimeout {
                // 超时自动打印延迟（借鉴 PhotoBoothProject：给宾客最后反应时间）
                let delay = Double(max(0, cfg.printing.autoPrintDelaySec))
                if delay > 0 {
                    Log.session.warn("REVIEW 超时（\(sec)s 无操作），\(delay)s 后自动打印 \(cfg.printing.defaultCopies) 份")
                    try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                    guard !Task.isCancelled, case .review(let still) = state, still.id == photoID else { return }
                } else {
                    Log.session.warn("REVIEW 超时（\(sec)s 无操作），自动打印 \(cfg.printing.defaultCopies) 份")
                }
                await confirmPrintInternal(copies: cfg.printing.defaultCopies, reason: "REVIEW 超时自动打印")
            } else {
                Log.session.warn("REVIEW 超时（\(sec)s 无操作），回待机")
                await resetToIdle("REVIEW 超时")
            }
        }
    }

    private func confirmPrintInternal(copies: Int, reason: String) async {
        guard case .review(var photo) = state else { return }
        timeoutTask?.cancel(); timeoutTask = nil
        let cfg = await config.config
        let clamped = min(max(copies, cfg.printing.minCopies), cfg.printing.maxCopies)
        await transition(.printing(copies: clamped), reason: reason)
        // 打印 QR 叠印（PhotoBoothProject 借鉴）：把电子版下载链接印到成片右缘
        if cfg.printing.printQRCode, let server, server.port > 0 {
            let host = LANAddress.localIPv4() ?? "127.0.0.1"
            let content = "http://\(host):\(server.port)/photo/\(photo.id.uuidString)"
            do {
                photo = try await imaging.overlayQR(content: content, on: photo)
            } catch {
                Log.session.warn("QR 叠印失败，用原图打印: \(describeError(error))")
            }
        }
        let job = await printer.submit(image: photo.printFile, copies: clamped)
        Log.session.info("打印任务已入队 \(job.id.uuidString.prefix(8)) copies=\(clamped) 路径=\(photo.printFile.lastPathComponent)")
        dwellTask?.cancel()
        dwellTask = Task {
            // “打印中请稍候”停留时长：测试覆盖优先，否则跟随配置（原硬编码 3s）
            let dwell = printingDwell ?? Double(max(0, cfg.printing.printingDwellSec))
            try? await Task.sleep(nanoseconds: UInt64(max(0, dwell) * 1_000_000_000))
            guard !Task.isCancelled else { return }
            await resetToIdle("打印完成，回待机")
        }
    }

    // MARK: - 相机事件响应

    private func consumeCameraEvents() async {
        for await event in camera.events {
            switch event {
            case .disconnected(let reason):
                Log.session.error("相机断开事件: \(reason)")
                switch state {
                case .countdown, .capturing, .processing:
                    // 拍摄流程中断线：failure 态记日志后回 idle
                    await failAndRecover("相机断开: \(reason)")
                case .armed, .gestureWait:
                    // 取景都没了，引导态无意义
                    await resetToIdle("相机断开")
                case .idle, .failure:
                    break // 已在待机/错误展示
                case .review, .printing:
                    break // 成片已拿到，相机断线不影响确认与打印
                }
            case .connected:
                Log.session.info("相机已连接/恢复，回待机待命")
                await resetToIdle("相机恢复")
            case .failure(let msg):
                Log.session.error("相机错误事件: \(msg)")
            case .objectAdded, .transferProgress:
                break // ObjectAdded 由 camera.capture() 内部等待，这里不处理
            }
        }
    }

    // MARK: - iPad 指令响应

    private func consumeServerCommands() async {
        guard let server else { return }
        for await command in server.commands {
            switch command {
            case .confirmPrint(let copies):
                await confirmPrint(copies: copies)
            case .retake:
                await retake()
            case .selectMode(let m):
                await setMode(m)
            case .selectFilter(let filter):
                await selectFilter(filter)
            }
        }
    }

    // MARK: - 超时任务

    /// ARMED 态超时：人一直未就绪 → idle
    private func startArmedTimeout(_ cfg: BoothConfig) {
        timeoutTask?.cancel()
        timeoutTask = Task {
            let sec = max(0.1, Double(cfg.capture.armedTimeoutSec))
            try? await Task.sleep(nanoseconds: UInt64(sec * 1_000_000_000))
            guard !Task.isCancelled, case .armed = state else { return }
            Log.session.warn("ARMED 超时（\(sec)s 人未就绪），回待机")
            await resetToIdle("ARMED 超时")
        }
    }

    /// GESTURE 态超时：一直没比手势 → idle
    private func startGestureTimeout(_ cfg: BoothConfig) {
        timeoutTask?.cancel()
        timeoutTask = Task {
            let sec = max(0.1, Double(cfg.capture.gestureTimeoutSec))
            try? await Task.sleep(nanoseconds: UInt64(sec * 1_000_000_000))
            guard !Task.isCancelled, case .gestureWait = state else { return }
            Log.session.warn("GESTURE 超时（\(sec)s 未命中手势），回待机")
            await resetToIdle("GESTURE 超时")
        }
    }

    // MARK: - 状态转移与恢复

    /// 统一转移入口：日志 + 内部状态流 + EventBus + Server 广播
    private func transition(_ to: BoothState, reason: String) async {
        let from = state
        guard from != to else { return } // 相同状态不重复广播
        Log.session.info("[状态] \(describe(from)) → \(describe(to))（\(reason)）")
        state = to
        for cont in stateConts.values { cont.yield(to) }
        await bus.publish(.stateChanged(to))
        if let server { await server.broadcast(state: to) }
    }

    /// 回 idle 并清理计时任务
    private func resetToIdle(_ reason: String) async {
        timeoutTask?.cancel(); timeoutTask = nil
        dwellTask?.cancel(); dwellTask = nil
        resetStreaks()
        await transition(.idle, reason: reason)
    }

    /// 进入 failure 态展示一段时间后自动回 idle
    private func failAndRecover(_ message: String) async {
        flowTask?.cancel(); flowTask = nil
        timeoutTask?.cancel(); timeoutTask = nil
        await transition(.failure(message), reason: "流程错误")
        dwellTask?.cancel()
        dwellTask = Task {
            try? await Task.sleep(nanoseconds: UInt64(max(0, failureDwell) * 1_000_000_000))
            guard !Task.isCancelled, case .failure = state else { return }
            await resetToIdle("错误展示结束")
        }
    }

    private func resetStreaks() {
        readyStreak = 0
        absentStreak = 0
        gestureStreak = 0
    }

    /// 状态的可读描述（日志用）
    private func describe(_ s: BoothState) -> String {
        switch s {
        case .idle: return "idle"
        case .armed: return "armed"
        case .gestureWait: return "gestureWait"
        case .countdown(let n): return "countdown(\(n))"
        case .capturing(let shot, let of): return "capturing(\(shot)/\(of))"
        case .processing: return "processing"
        case .review(let p): return "review(\(p.id.uuidString.prefix(8)))"
        case .printing(let c): return "printing(\(c))"
        case .failure(let m): return "failure(\(m))"
        }
    }

    private func describeError(_ error: Error) -> String {
        if let booth = error as? BoothError { return "\(booth)" }
        return error.localizedDescription
    }
}
