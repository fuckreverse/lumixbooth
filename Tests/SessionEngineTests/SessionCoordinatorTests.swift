import XCTest
import BoothCore
@testable import SessionEngine

// 状态判定（文件级自由函数，避免在 @Sendable 闭包里捕获非 Sendable 的测试类实例）
private func isReview(_ s: BoothState) -> Bool { if case .review = s { return true }; return false }
private func isFailure(_ s: BoothState) -> Bool { if case .failure = s { return true }; return false }
private func isCapturing(_ s: BoothState) -> Bool { if case .capturing = s { return true }; return false }
private func isPrinting(_ s: BoothState) -> Bool { if case .printing = s { return true }; return false }
private func isSelect(_ s: BoothState) -> Bool { if case .select = s { return true }; return false }

// ============================================================
// SessionCoordinator 状态机测试：
// 全部使用本地 Mock（MockCamera/MockGesture/MockReadiness/MockImaging/
// MockPrinter/MockServer），不接真机、真打印。
// 倒计时用 countdownSec=0/1 加速；failure/printing 停留时长用
// coordinator.failureDwell/printingDwell 调短。
// 注意：ConfigStore 只暴露 .shared（契约限制），测试间通过 setUp 重置；
// XCTest 断言的 autoclosure 不支持 await，一律先取值再断言。
// ============================================================
final class SessionCoordinatorTests: XCTestCase {

    // 每个 test 全新一套 Mock + 独立 EventBus
    private var camera = MockCamera()
    private var gesture = MockGesture()
    private var readiness = MockReadiness()
    private var imaging = MockImaging()
    private var printer = MockPrinter()
    private var server = MockServer()
    private var bus = EventBus()
    private var recorder = StateRecorder()
    private var savedConfig: BoothConfig?   // 测试前真实配置快照（update 会落盘）

    // MARK: - 搭建

    override func setUp() async throws {
        // 先快照真实配置（shared.update 会写真实 config.json），tearDown 还原
        savedConfig = await ConfigStore.shared.config
        // 重置共享配置到默认值，各测试再覆写关键字段
        await ConfigStore.shared.update { c in
            c = BoothConfig()
            // Legacy automatic-trigger tests explicitly exercise the dormant pose/gesture path.
            c.capture.triggerStyle = .gesture
            c.vision.gestureEnabled = true
            c.vision.poseReadinessEnabled = true
        }
        camera = MockCamera()
        gesture = MockGesture()
        readiness = MockReadiness()
        imaging = MockImaging()
        printer = MockPrinter()
        server = MockServer()
        bus = EventBus()
        recorder = StateRecorder()
    }

    override func tearDown() async throws {
        // 还原测试前的真实配置，避免污染落盘的 config.json
        if let savedConfig {
            await ConfigStore.shared.update { c in c = savedConfig }
        }
    }

    /// 组装被测对象并挂上状态记录器
    private func makeSUT() -> SessionCoordinator {
        let coord = SessionCoordinator(
            camera: camera, gesture: gesture, readiness: readiness,
            imaging: imaging, printer: printer, server: server,
            config: .shared, bus: bus)
        recorder.attach(to: bus)
        return coord
    }

    /// 写入测试配置
    private func configure(_ mutate: @Sendable (inout BoothConfig) -> Void) async {
        await ConfigStore.shared.update(mutate)
    }

    /// 轮询等待条件成立（默认 10s）
    private func waitUntil(timeout: TimeInterval = 10,
                           _ check: @escaping @Sendable () async -> Bool) async -> Bool {
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            if await check() { return true }
            try? await Task.sleep(nanoseconds: 15_000_000)
        }
        return await check()
    }

    /// 等待 + 断言（绕过 XCTest autoclosure 不支持 await 的限制）
    @discardableResult
    private func expect(_ message: String, timeout: TimeInterval = 10,
                        file: StaticString = #filePath, line: UInt = #line,
                        _ check: @escaping @Sendable () async -> Bool) async -> Bool {
        let ok = await waitUntil(timeout: timeout, check)
        XCTAssertTrue(ok, message, file: file, line: line)
        return ok
    }

    /// 断言 states 按顺序包含 expected 子序列
    private func assertInOrder(_ states: [BoothState], _ expected: [BoothState],
                               file: StaticString = #filePath, line: UInt = #line) {
        var i = 0
        for s in states where i < expected.count && s == expected[i] { i += 1 }
        XCTAssertEqual(i, expected.count, "状态序列未按顺序包含期望子序列。\n实际: \(states)\n期望: \(expected)",
                       file: file, line: line)
    }

    /// 手动 start() 快速推进到 REVIEW（跳过手势路径）
    @discardableResult
    private func driveToReview(_ coord: SessionCoordinator, timeout: TimeInterval = 10) async -> Bool {
        await coord.begin()
        await coord.start()
        return await waitUntil(timeout: timeout) { isReview(await coord.state) }
    }

    /// 等事件总线/记录器追平当前状态（避免断言时事件还在路上）
    private func settle() async {
        try? await Task.sleep(nanoseconds: 250_000_000)
    }

    // MARK: - 快乐路径

    /// 全链路：idle→armed→gestureWait→countdown→capturing×4→processing→review→printing→idle
    func testHappyPathCollageGestureDriven() async {
        await configure { c in
            c.capture.countdownSec = 1
            c.capture.defaultMode = .collage(4)
            c.capture.reviewTimeoutSec = 60
            c.capture.layoutSelection = false   // 本测试验证不选片的直接出片路径
            c.vision.detectEveryNFrames = 1
            c.vision.readyStableMs = 0
            c.vision.gestureStableMs = 0
        }
        let coord = makeSUT()
        await coord.begin()

        // idle → armed → gestureWait（人站定）
        readiness.readiness = MockReadiness.ready()
        for _ in 0..<6 { camera.pushFrame() }
        await expect("应进入 gestureWait") { await coord.state == .gestureWait }

        // gestureWait → 手势命中 → 拍摄流程
        gesture.gesture = .peace
        for _ in 0..<4 { camera.pushFrame() }
        await expect("应走完流程进入 review") { isReview(await coord.state) }

        // review → 确认打印
        await coord.confirmPrint(copies: 2)
        await expect("打印后应回 idle") { await coord.state == .idle }

        // 逐状态断言（顺序子序列）
        await settle()
        assertInOrder(recorder.states, [
            .armed,
            .gestureWait,
            .countdown(secondsLeft: 1),
            .capturing(shot: 1, of: 4),
            .countdown(secondsLeft: 1),
            .capturing(shot: 2, of: 4),
            .countdown(secondsLeft: 1),
            .capturing(shot: 3, of: 4),
            .countdown(secondsLeft: 1),
            .capturing(shot: 4, of: 4),
            .processing,
            .printing(copies: 2),
            .idle,
        ])
        // review 出现在 processing 之后、printing 之前
        let states = recorder.states
        let reviewIdx = states.firstIndex(where: isReview)
        let processingIdx = states.firstIndex(of: .processing)
        let printingIdx = states.firstIndex(of: .printing(copies: 2))
        XCTAssertNotNil(reviewIdx)
        XCTAssertNotNil(processingIdx)
        XCTAssertNotNil(printingIdx)
        XCTAssertLessThan(processingIdx!, reviewIdx!)
        XCTAssertLessThan(reviewIdx!, printingIdx!)

        // 协作方调用断言
        XCTAssertEqual(imaging.calls.count, 1)
        XCTAssertEqual(imaging.calls.first?.originals, 4)
        XCTAssertEqual(imaging.calls.first?.mode, .collage(4))
        XCTAssertEqual(printer.submitted.count, 1)
        XCTAssertEqual(printer.submitted.first?.copies, 2)
        XCTAssertEqual(camera.captureCount, 4)
        // server 同步：状态广播 + 成片注册 + LiveView 推流（默认开启）
        XCTAssertFalse(server.broadcastStates.isEmpty)
        XCTAssertEqual(server.publishedPhotos.count, 1)
        XCTAssertGreaterThan(server.pushedFrameCount, 0)
    }

    /// 单张模式 shots=1，手动触发（空格键路径）
    func testSingleModeManualStart() async {
        await configure { c in
            c.capture.countdownSec = 0
            c.capture.defaultMode = .single
            c.capture.reviewTimeoutSec = 60
        }
        let coord = makeSUT()
        await coord.begin()
        await coord.start()

        await expect("应进入 review") { isReview(await coord.state) }
        await coord.confirmPrint(copies: 1)
        await expect("打印后应回 idle") { await coord.state == .idle }
        await settle()

        assertInOrder(recorder.states, [
            .capturing(shot: 1, of: 1),
            .processing,
            .printing(copies: 1),
            .idle,
        ])
        XCTAssertEqual(imaging.calls.count, 1)
        XCTAssertEqual(imaging.calls.first?.originals, 1)
        XCTAssertEqual(imaging.calls.first?.mode, .single)
        XCTAssertEqual(camera.captureCount, 1)
    }

    // MARK: - REVIEW 超时

    /// REVIEW 超时 + autoPrintOnTimeout=true → 按默认份数自动打印
    func testReviewTimeoutAutoPrint() async {
        await configure { c in
            c.capture.countdownSec = 0
            c.capture.defaultMode = .single
            c.capture.reviewTimeoutSec = 1
            c.capture.autoPrintOnTimeout = true
            c.printing.defaultCopies = 2
        }
        let coord = makeSUT()
        await coord.begin()
        await coord.start()
        await expect("应进入 review") { isReview(await coord.state) }

        await expect("超时后应自动打印并回 idle", timeout: 5) { await coord.state == .idle }
        await settle()
        XCTAssertTrue(recorder.states.contains(.printing(copies: 2)), "应按默认份数自动打印")
        XCTAssertEqual(printer.submitted.count, 1)
        XCTAssertEqual(printer.submitted.first?.copies, 2)
    }

    /// REVIEW 超时 + autoPrintOnTimeout=false → 直接回 idle，不打印
    func testReviewTimeoutNoAutoPrint() async {
        await configure { c in
            c.capture.countdownSec = 0
            c.capture.defaultMode = .single
            c.capture.reviewTimeoutSec = 1
            c.capture.autoPrintOnTimeout = false
        }
        let coord = makeSUT()
        await coord.begin()
        await coord.start()
        await expect("应进入 review") { isReview(await coord.state) }

        await expect("超时后应直接回 idle", timeout: 5) { await coord.state == .idle }
        await settle()
        XCTAssertFalse(recorder.states.contains(where: isPrinting), "不应出现 printing 态")
        XCTAssertTrue(printer.submitted.isEmpty, "不应提交打印")
    }

    // MARK: - 重拍

    /// review → retake → 重新倒计时 → 再次 review → 确认打印
    func testRetakeRestartsCountdown() async {
        await configure { c in
            c.capture.countdownSec = 1
            c.capture.defaultMode = .single
            c.capture.reviewTimeoutSec = 60
        }
        let coord = makeSUT()
        let reached = await driveToReview(coord)
        XCTAssertTrue(reached, "第一轮应到 review")

        recorder.reset()
        await coord.retake()

        // 重新倒计时 → 重新拍摄 → 第二次 review。
        // 注意：不能用 isReview 判断新流程（旧 review 还在时也会立即命中），
        // 用“又拍了一张”作为新流程真正启动的信号。
        let cam = camera
        await expect("重拍应重新拍一张") { cam.captureCount == 2 }
        await expect("重拍后应再次进入 review") { isReview(await coord.state) }
        await settle()
        assertInOrder(recorder.states, [
            .countdown(secondsLeft: 1),
            .capturing(shot: 1, of: 1),
            .processing,
        ])
        XCTAssertEqual(imaging.calls.count, 2, "重拍应再次修图")
        XCTAssertEqual(camera.captureCount, 2)

        await coord.confirmPrint(copies: 1)
        await expect("打印后应回 idle") { await coord.state == .idle }
    }

    // MARK: - 等待超时

    /// gestureWait 超时回 idle
    func testGestureTimeoutBackToIdle() async {
        await configure { c in
            c.capture.gestureTimeoutSec = 1
            c.vision.detectEveryNFrames = 1
            c.vision.readyStableMs = 0
        }
        let coord = makeSUT()
        await coord.begin()

        readiness.readiness = MockReadiness.ready()
        for _ in 0..<6 { camera.pushFrame() }
        await expect("应进入 gestureWait") { await coord.state == .gestureWait }

        // 不给手势 → 超时
        await expect("gestureWait 超时应回 idle", timeout: 5) { await coord.state == .idle }
        await settle()
        assertInOrder(recorder.states, [.gestureWait, .idle])
    }

    /// armed 态人一直未就绪，超时回 idle
    func testArmedTimeoutBackToIdle() async {
        await configure { c in
            c.capture.armedTimeoutSec = 1
            c.vision.detectEveryNFrames = 1
            c.vision.readyStableMs = 5000 // 永不达成就绪稳定窗口
        }
        let coord = makeSUT()
        await coord.begin()

        // 人在画面但未站定
        readiness.readiness = PoseReadiness(humanPresent: true, facePresent: true,
                                             faceAreaRatio: 0.02, isReady: false)
        for _ in 0..<6 { camera.pushFrame() }
        await expect("应进入 armed") { await coord.state == .armed }

        await expect("armed 超时应回 idle", timeout: 5) { await coord.state == .idle }
        await settle()
        assertInOrder(recorder.states, [.armed, .idle])
    }

    /// armed 态人消失（连续无人帧）→ 回 idle
    func testPersonAbsentBackToIdle() async {
        await configure { c in
            c.capture.armedTimeoutSec = 30
            c.vision.detectEveryNFrames = 1
            c.vision.readyStableMs = 5000 // 人站定与否都保持 armed，不进 gestureWait
            c.vision.absentStableMs = 0   // 人一帧即判离场
        }
        let coord = makeSUT()
        await coord.begin()

        // idle → armed
        readiness.readiness = MockReadiness.ready()
        for _ in 0..<2 { camera.pushFrame() }
        await expect("应进入 armed") { await coord.state == .armed }

        // 人走了（注意：readiness.isReady=false 且 humanPresent=false，先不涨就绪帧）
        readiness.readiness = .empty
        for _ in 0..<3 { camera.pushFrame() }
        await expect("人消失应回 idle", timeout: 5) { await coord.state == .idle }
        await settle()
        assertInOrder(recorder.states, [.armed, .idle])
    }

    // MARK: - 失败路径

    /// 拍照失败（重试后仍失败）→ failure 态 → idle
    func testCaptureFailureShowsFailureThenIdle() async {
        await configure { c in
            c.capture.countdownSec = 0
            c.capture.defaultMode = .single
            c.camera.captureRetry = 1
        }
        camera.failNextCaptures = 99 // 全部失败
        let coord = makeSUT()
        await coord.begin()
        await coord.setDwell(failure: 0.5)

        await coord.start()
        await expect("拍照失败应进 failure 态") { isFailure(await coord.state) }
        await expect("failure 展示后应回 idle") { await coord.state == .idle }
        await settle()

        assertInOrder(recorder.states, [.capturing(shot: 1, of: 1), .idle])
        XCTAssertTrue(recorder.states.contains(where: isFailure))
        XCTAssertEqual(camera.captureCount, 2, "含 1 次重试共尝试 2 次")
        XCTAssertTrue(printer.submitted.isEmpty)
    }

    /// 修图失败 → failure 态 → idle
    func testImagingFailureShowsFailureThenIdle() async {
        await configure { c in
            c.capture.countdownSec = 0
            c.capture.defaultMode = .single
        }
        imaging.error = BoothError.imagingFailed("管线爆炸")
        let coord = makeSUT()
        await coord.begin()
        await coord.setDwell(failure: 0.5)

        await coord.start()
        await expect("修图失败应进 failure 态") { isFailure(await coord.state) }
        await expect("failure 展示后应回 idle") { await coord.state == .idle }
        await settle()

        assertInOrder(recorder.states, [.capturing(shot: 1, of: 1), .processing, .idle])
        XCTAssertEqual(imaging.calls.count, 1)
    }

    /// 拍摄中相机断线 → failure 态 → idle
    func testCameraDisconnectDuringCapture() async {
        await configure { c in
            c.capture.countdownSec = 0
            c.capture.defaultMode = .single
        }
        camera.captureDelay = 2 // 让 capture 挂住，制造断线窗口
        let coord = makeSUT()
        await coord.begin()
        await coord.setDwell(failure: 0.5)

        await coord.start()
        await expect("应进入 capturing") { isCapturing(await coord.state) }

        camera.emit(.disconnected(reason: "USB 掉线"))
        await expect("断线应进 failure 态") { isFailure(await coord.state) }
        await expect("failure 展示后应回 idle") { await coord.state == .idle }
    }

    // MARK: - 取消

    /// 倒计时中 cancel → 立即回 idle
    func testCancelFromCountdown() async {
        await configure { c in
            c.capture.countdownSec = 5
            c.capture.defaultMode = .single
        }
        let coord = makeSUT()
        await coord.begin()
        await coord.start()
        await expect("应进入 countdown(5)") { await coord.state == .countdown(secondsLeft: 5) }

        await coord.cancel()
        await expect("cancel 应立即回 idle", timeout: 2) { await coord.state == .idle }
        // 取消后不应再出现后续拍摄状态
        try? await Task.sleep(nanoseconds: 300_000_000)
        let finalState = await coord.state
        XCTAssertEqual(finalState, .idle)
        XCTAssertFalse(recorder.states.contains(where: isCapturing))
        XCTAssertEqual(camera.captureCount, 0)
    }

    // MARK: - iPad 指令

    /// server.commands 的 confirmPrint 指令驱动打印
    func testServerCommandConfirmPrint() async {
        await configure { c in
            c.capture.countdownSec = 0
            c.capture.defaultMode = .single
            c.capture.reviewTimeoutSec = 60
        }
        let coord = makeSUT()
        _ = await driveToReview(coord)

        server.send(.confirmPrint(copies: 3))
        await expect("iPad 指令应驱动打印") { await coord.state == .printing(copies: 3) }
        await expect("打印后应回 idle") { await coord.state == .idle }
        XCTAssertEqual(printer.submitted.count, 1)
        XCTAssertEqual(printer.submitted.first?.copies, 3)
    }

    /// server.commands 的 retake 指令重拍
    func testServerCommandRetake() async {
        await configure { c in
            c.capture.countdownSec = 0
            c.capture.defaultMode = .single
            c.capture.reviewTimeoutSec = 60
        }
        let coord = makeSUT()
        _ = await driveToReview(coord)

        server.send(.retake)
        // capturing 是瞬态，轮询可能错过；用“又拍了一张”作为重拍信号
        let cam = camera
        await expect("retake 指令应重新拍摄") { cam.captureCount == 2 }
        await expect("重拍后应再次进入 review") { isReview(await coord.state) }
        XCTAssertEqual(camera.captureCount, 2)
    }

    // MARK: - 帧分发

    /// frames() 重广播给 UI；liveViewToIpad=false 时不推 iPad，改 true 后热生效
    func testFramesRebroadcastAndIpadGate() async {
        await configure { c in
            c.server.liveViewToIpad = false
            c.vision.detectEveryNFrames = 1
        }
        let coord = makeSUT()
        await coord.begin()

        let counter = FrameCounter()
        let uiStream = await coord.frames()
        let consume = Task { for await _ in uiStream { counter.increment() } }

        for _ in 0..<5 { camera.pushFrame() }
        try? await Task.sleep(nanoseconds: 400_000_000)
        XCTAssertEqual(server.pushedFrameCount, 0, "liveViewToIpad=false 不应推 iPad")
        XCTAssertGreaterThanOrEqual(counter.count, 2, "UI 帧流应收到帧（bufferingNewest(2) 允许丢帧）")

        // 热更新配置 → 开始推 iPad
        await configure { c in c.server.liveViewToIpad = true }
        for _ in 0..<3 { camera.pushFrame() }
        let mockServer = server
        await expect("配置热更新后应推 iPad") { mockServer.pushedFrameCount == 3 }
        consume.cancel()
    }

    // MARK: - 非法操作防护

    /// review 态下 start()/setMode() 应记 warn 并忽略
    func testInvalidOperationIgnoredInReview() async {
        await configure { c in
            c.capture.countdownSec = 0
            c.capture.defaultMode = .single
            c.capture.reviewTimeoutSec = 60
        }
        let coord = makeSUT()
        let reached = await driveToReview(coord)
        XCTAssertTrue(reached, "应进入 review")

        await coord.start()                 // review 态不允许手动触发
        await coord.setMode(.collage(4))    // review 态不允许切模式
        try? await Task.sleep(nanoseconds: 300_000_000)

        let stillReview = await isReview(coord.state)
        XCTAssertTrue(stillReview, "非法操作应被忽略，保持 review")
        let modeNow = await coord.mode
        XCTAssertEqual(modeNow, .single, "review 态切模式应被忽略")
        XCTAssertEqual(camera.captureCount, 1, "不应重复拍摄")

        await coord.cancel()
        await expect("cancel 后应回 idle") { await coord.state == .idle }
    }

    // MARK: - 拍后自选滤镜（PhotoBoothProject 借鉴）

    /// REVIEW 态换滤镜：重打成片（新 id）→ 重新广播 REVIEW + 注册新下载地址
    func testSelectFilterReprintsAndRebroadcasts() async {
        await configure { c in
            c.capture.countdownSec = 0
            c.capture.defaultMode = .single
            c.capture.reviewTimeoutSec = 60
        }
        let coord = makeSUT()
        let reached = await driveToReview(coord)
        XCTAssertTrue(reached, "应进入 review")
        let firstID: UUID
        if case .review(let p) = await coord.state { firstID = p.id } else { return XCTFail("非 review 态") }

        await coord.selectFilter(.vivid)
        await expect("换滤镜后应回到 review（新成片）") {
            if case .review(let p) = await coord.state { return p.id != firstID }
            return false
        }
        XCTAssertEqual(imaging.filterCalls, [.vivid], "应恰好调用一次 applyFilter(vivid)")
        XCTAssertEqual(server.publishedPhotos.count, 2, "原片 + 重打片都应注册下载")

        // 幂等：重复选同一滤镜不应再重打
        await coord.selectFilter(.vivid)
        try? await Task.sleep(nanoseconds: 300_000_000)
        XCTAssertEqual(imaging.filterCalls, [.vivid], "重复选择应被忽略")

        let filterNow = await coord.currentFilter
        XCTAssertEqual(filterNow, .vivid)
        await coord.cancel()
    }

    /// 非 REVIEW 态换滤镜应被忽略
    func testSelectFilterIgnoredOutsideReview() async {
        let coord = makeSUT()
        await coord.begin()
        try? await Task.sleep(nanoseconds: 200_000_000)
        await coord.selectFilter(.vivid)
        try? await Task.sleep(nanoseconds: 200_000_000)
        XCTAssertTrue(imaging.filterCalls.isEmpty, "非 review 态不应触发重打")
        await coord.cancel()
    }

    // MARK: - 连拍不中断（拼版仅首张倒计时）

    func testContinuousCollageOnlyFirstCountdown() async {
        await configure { c in
            c.capture.countdownSec = 2
            c.capture.defaultMode = .collage(4)
            c.capture.continuousCollage = true
            c.capture.reviewTimeoutSec = 60
            c.capture.layoutSelection = false   // 验证直接出片路径（连拍倒计时轮数不受选片影响）
        }
        let coord = makeSUT()
        await coord.begin()
        await coord.start()
        await expect("应完成 4 张连拍进入 review") { isReview(await coord.state) }
        await settle()

        // 倒计时按“轮”计数：countdownSec=2 首轮有 2 个 tick 状态，
        // 只有从非倒计时态进入倒计时才算新一轮
        var countdownRounds = 0
        var prev: BoothState?
        for s in recorder.states {
            if case .countdown = s, !(prev.map { if case .countdown = $0 { return true }; return false } ?? false) {
                countdownRounds += 1
            }
            prev = s
        }
        XCTAssertEqual(countdownRounds, 1, "连拍不中断模式仅首张倒计时，实际倒计时轮数: \(countdownRounds)")
        let capturingCount = recorder.states.filter { s -> Bool in
            if case .capturing = s { return true }
            return false
        }.count
        XCTAssertEqual(capturingCount, 4, "4 张都应拍摄")
        await coord.cancel()
    }

    // MARK: - QR 叠印打印流

    /// printQRCode=true（默认）：打印前把 /photo/{id} 下载链接叠印到成片
    func testPrintQRCodeStampsOverlay() async {
        await configure { c in
            c.capture.countdownSec = 0
            c.capture.defaultMode = .single
            c.capture.reviewTimeoutSec = 60
            c.printing.printingDwellSec = 0
        }
        let coord = makeSUT()
        await driveToReview(coord)
        await coord.confirmPrint(copies: 1)
        await expect("打印后应回 idle") { await coord.state == .idle }

        XCTAssertEqual(imaging.qrCalls.count, 1, "应叠印一次 QR")
        let content = imaging.qrCalls.first ?? ""
        XCTAssertTrue(content.contains("/photo/"), "QR 内容应为成片下载链接: \(content)")
        XCTAssertEqual((printer.submitted.first?.imagePath as NSString?).map { $0.lastPathComponent },
                       "print-qr.png", "打印应使用叠印后的成片")

        // 关闭开关：第二轮不应再叠印
        await configure { c in c.printing.printQRCode = false }
        await coord.start()
        await expect("第二轮应进入 review") { isReview(await coord.state) }
        await coord.confirmPrint(copies: 1)
        await expect("第二轮打印后应回 idle") { await coord.state == .idle }
        XCTAssertEqual(imaging.qrCalls.count, 1, "关闭开关后不应叠印")
        XCTAssertEqual((printer.submitted.last?.imagePath as NSString?).map { $0.lastPathComponent },
                       "print.png", "关闭开关时应打印原图")
    }

    // MARK: - 打印时序配置化

    /// autoPrintDelaySec：REVIEW 超时后延迟 N 秒才自动打印
    func testAutoPrintDelaySecDelaysPrint() async {
        await configure { c in
            c.capture.countdownSec = 0
            c.capture.defaultMode = .single
            c.capture.reviewTimeoutSec = 1
            c.capture.autoPrintOnTimeout = true
            c.printing.autoPrintDelaySec = 3
            c.printing.printingDwellSec = 0
        }
        let coord = makeSUT()
        await coord.begin()
        await coord.start()
        await expect("应进入 review") { isReview(await coord.state) }

        // 1s 超时 + 3s 延迟：2s 时应还在 review（打印发生在 ~4s）
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        let stillReview = await isReview(coord.state)
        XCTAssertTrue(stillReview, "延迟窗口内不应开始打印")
        XCTAssertEqual(printer.submitted.count, 0, "延迟窗口内不应提交打印")

        await expect("延迟过后应自动打印并回 idle", timeout: 8) { await coord.state == .idle }
        XCTAssertEqual(printer.submitted.count, 1)
    }

    /// printingDwellSec：打印完成停留时长跟随配置（非硬编码 3s）
    func testPrintingDwellFollowsConfig() async {
        await configure { c in
            c.capture.countdownSec = 0
            c.capture.defaultMode = .single
            c.capture.reviewTimeoutSec = 60
            c.printing.printingDwellSec = 1
        }
        let coord = makeSUT()
        await driveToReview(coord)
        let startedAt = Date()
        await coord.confirmPrint(copies: 1)
        await expect("dwell=1s 时应快速回 idle", timeout: 5) { await coord.state == .idle }
        let elapsed = Date().timeIntervalSince(startedAt)
        XCTAssertLessThan(elapsed, 3.0, "printingDwellSec=1 时回 idle 应明显早于硬编码 3s，实际 \(elapsed)s")
    }

    // MARK: - 操作员重打（/gallery 长按补打）

    /// 重打指令：错误口令拒绝、路径穿越拒绝、正确口令按默认份数入队
    func testOperatorReprintCodeAndPathValidation() async {
        await configure { c in
            c.security.reprintCode = "4321"
            c.printing.defaultCopies = 2
        }
        // 在真实 sessions 目录造一个历史会话成片（test 标记，测完清理）
        let fm = FileManager.default
        let date = "2099-99-99"
        let session = "testsession-reprint"
        let sessionDir = BoothPaths.sessionsDir
            .appendingPathComponent(date, isDirectory: true)
            .appendingPathComponent(session, isDirectory: true)
        try? fm.createDirectory(at: sessionDir, withIntermediateDirectories: true)
        let printFile = sessionDir.appendingPathComponent("print.jpg")
        try? Data("fake".utf8).write(to: printFile)
        defer { try? fm.removeItem(at: sessionDir) }

        let coord = makeSUT()
        await coord.begin()
        let printer = self.printer

        // 错误口令：不应入队
        server.send(.operatorReprint(code: "0000", date: date, session: session))
        // 路径穿越：date 含 ../ 应被清洗拒绝
        server.send(.operatorReprint(code: "4321", date: "../../etc", session: session))
        // 正确口令 + 合法路径：应入队
        server.send(.operatorReprint(code: "4321", date: date, session: session))

        await expect("正确口令重打应恰好入队 1 单") { await printer.submitted.count == 1 }
        XCTAssertEqual(printer.submitted.first?.imagePath, printFile.path,
                       "应重打 sessions/<date>/<session>/print.jpg")
        XCTAssertEqual(printer.submitted.first?.copies, 2, "重打份数用配置默认份数")
    }

    // MARK: - 邮箱采集指令

    /// submitEmail 指令：非法邮箱被 EmailStore 拒绝，不写真实 emails.json
    func testSubmitEmailCommandRejectsInvalid() async {
        let coord = makeSUT()
        await coord.begin()
        let before = await EmailStore.shared.count
        server.send(.submitEmail(email: "not-an-email", photoID: nil))
        server.send(.submitEmail(email: "also bad@example", photoID: nil))
        try? await Task.sleep(nanoseconds: 400_000_000)
        let after = await EmailStore.shared.count
        XCTAssertEqual(after, before, "非法邮箱不应入库（不污染真实 emails.json）")
    }

    // MARK: - 拍后选片（SELECT）

    /// 连拍完成进入 SELECT：预览已注册、尚未修图；只选一张（含去重/越界容错）→ single 直出
    func testSelectSingleShotAfterCollage() async {
        await configure { c in
            c.capture.countdownSec = 1
            c.capture.defaultMode = .collage(4)
            c.capture.selectTimeoutSec = 300
        }
        let coord = makeSUT()
        await coord.begin()
        await coord.start()

        await expect("连拍完成应进入 select 态") { isSelect(await coord.state) }
        await settle()
        // 选片确认前不应修图/打印；iPad 端 shots 已注册
        XCTAssertTrue(imaging.calls.isEmpty, "选片确认前不应修图")
        XCTAssertEqual(server.publishedShots.count, 1)
        XCTAssertEqual(server.publishedShots.first?.count, 4, "应注册 4 张选片预览")

        // indexes 含重复和越界：应容错归一化为第 1 张；未选滤镜则 filter 为空
        await coord.selectOutput(kind: .single, layout: .strip, indexes: [1, 1, 9], filter: .none)
        await expect("选片确认后应进入 review") { isReview(await coord.state) }
        XCTAssertEqual(imaging.calls.count, 1)
        XCTAssertEqual(imaging.calls.first?.originals, 1, "只要一张时修图只收 1 张原片")
        XCTAssertEqual(imaging.calls.first?.mode, .single)
        XCTAssertNil(imaging.calls.first?.filter, "未选修图风格时不应带滤镜覆盖")
        XCTAssertEqual(printer.submitted.count, 0)
    }

    /// 选片页改选拼图布局 + 挑其中两张：按所选布局和子集出片
    func testSelectCollageLayoutAndSubset() async {
        await configure { c in
            c.capture.countdownSec = 1
            c.capture.defaultMode = .collage(4, layout: .strip)
            c.capture.selectTimeoutSec = 300
        }
        let coord = makeSUT()
        await coord.begin()
        await coord.start()
        await expect("应进入 select 态") { isSelect(await coord.state) }

        await coord.selectOutput(kind: .collage, layout: .onePlusThree, indexes: [0, 2], filter: .warm)
        await expect("选片确认后应进入 review") { isReview(await coord.state) }
        XCTAssertEqual(imaging.calls.count, 1)
        XCTAssertEqual(imaging.calls.first?.mode, .collage(2, layout: .onePlusThree))
        XCTAssertEqual(imaging.calls.first?.originals, 2, "选中的两张应进入修图")
        XCTAssertEqual(imaging.calls.first?.filter, .warm, "选片页所选修图风格应随指令出片")
    }

    /// 选片超时：不操作，按默认布局自动出片
    func testSelectTimeoutFallsBackToDefaultLayout() async {
        await configure { c in
            c.capture.countdownSec = 1
            c.capture.defaultMode = .collage(2, layout: .grid2x2)
            c.capture.selectTimeoutSec = 5   // sanitized 下限
        }
        let coord = makeSUT()
        await coord.begin()
        await coord.start()
        await expect("应进入 select 态") { isSelect(await coord.state) }

        // 不操作，等超时自动按默认布局出片
        await expect("选片超时应按默认布局自动出片进 review", timeout: 20) { isReview(await coord.state) }
        XCTAssertEqual(imaging.calls.count, 1)
        XCTAssertEqual(imaging.calls.first?.mode, .collage(2, layout: .grid2x2))
        XCTAssertEqual(imaging.calls.first?.originals, 2)
    }

    // MARK: - 触发方式（手势/倒计时）

    func testManualCountdownWithPoseAndGestureDisabled() async {
        await configure { c in
            c.capture.countdownSec = 1
            c.capture.defaultMode = .single
            c.capture.layoutSelection = false
            c.capture.triggerStyle = .countdown
            c.vision.poseReadinessEnabled = false
            c.vision.gestureEnabled = false
            c.vision.detectEveryNFrames = 1
        }
        let coord = makeSUT()
        await coord.begin()
        readiness.readiness = MockReadiness.ready()
        for _ in 0..<8 { camera.pushFrame() }
        try? await Task.sleep(nanoseconds: 100_000_000)
        let stateBeforeStart = await coord.state
        XCTAssertEqual(stateBeforeStart, .idle, "禁用姿势后不应自动进入等待界面")
        await coord.start()
        await expect("手动开始应走倒计时进入 review") { isReview(await coord.state) }
        await settle()
        XCTAssertTrue(recorder.states.contains(.countdown(secondsLeft: 1)))
        XCTAssertFalse(recorder.states.contains(.armed))
        XCTAssertFalse(recorder.states.contains(.gestureWait))
    }

    /// 倒计时拍照模式：姿势就绪直接开拍，不经过 gestureWait
    func testCountdownTriggerStyleSkipsGestureWait() async {
        await configure { c in
            c.capture.countdownSec = 1
            c.capture.defaultMode = .collage(2)
            c.capture.triggerStyle = .countdown
            c.capture.layoutSelection = false
            c.vision.detectEveryNFrames = 1
            c.vision.readyStableMs = 0
        }
        let coord = makeSUT()
        await coord.begin()
        readiness.readiness = MockReadiness.ready()
        for _ in 0..<8 { camera.pushFrame() }
        await expect("姿势就绪应直接走完拍摄流程进 review") { isReview(await coord.state) }
        await settle()
        XCTAssertFalse(recorder.states.contains(.gestureWait), "倒计时模式不应进入 gestureWait")
        XCTAssertTrue(recorder.states.contains(.countdown(secondsLeft: 1)))
    }

    /// setMode 布局保留：未显式携布局（strip 默认）不冲掉已选四宫格
    func testSetModeKeepsNonStripLayout() async {
        await configure { c in
            c.capture.defaultMode = .collage(4, layout: .grid2x2)
        }
        let coord = makeSUT()
        await coord.begin()   // begin() 从配置加载默认模式
        var m = await coord.mode
        XCTAssertEqual(m, .collage(4, layout: .grid2x2))

        await coord.setMode(.collage(4))   // 未显式携布局（strip 默认）
        m = await coord.mode
        XCTAssertEqual(m, .collage(4, layout: .grid2x2), "切模式应保留当前非 strip 布局")

        await coord.setMode(.single)
        m = await coord.mode
        XCTAssertEqual(m, .single)
    }

    // MARK: - actor 重入竞态（await 后状态复验）

    /// idle 态在途就绪检测期间手动 start() 开拍：检测恢复后不应把流程状态打回 armed
    func testIdleDetectionInFlightDoesNotOverrideManualStart() async {
        await configure { c in
            c.capture.countdownSec = 0
            c.capture.defaultMode = .single
            c.capture.reviewTimeoutSec = 60
            c.vision.detectEveryNFrames = 1
            c.vision.readyStableMs = 0
        }
        readiness.readiness = MockReadiness.ready()
        readiness.detectDelay = 0.15   // 检测在途时外部可插入 start()
        let coord = makeSUT()
        await coord.begin()

        camera.pushFrame()             // idle 检测启动，卡 0.15s
        let det = readiness
        await expect("idle 检测应已在途") { det.detectCount >= 1 }
        await coord.start()            // 检测在途时手动触发（竞态窗口）

        await expect("手动流程应完成进入 review") { isReview(await coord.state) }
        // 等在途检测结束并确认它没有污染状态机
        try? await Task.sleep(nanoseconds: 300_000_000)
        await expect("流程不应被在途检测打回 armed") { isReview(await coord.state) }
        await settle()
        let states = recorder.states
        let captureIdx = states.firstIndex(where: isCapturing)
        XCTAssertNotNil(captureIdx, "手动触发应产生 capturing")
        if let captureIdx {
            XCTAssertFalse(states[(captureIdx + 1)...].contains(.armed),
                          "在途检测不应把已开拍流程打回 armed（实际序列: \(states)）")
        }
    }

    /// armed 态在途就绪检测期间 cancel()：检测恢复后不应复活状态机
    func testArmedDetectionInFlightIgnoredAfterCancel() async {
        await configure { c in
            c.vision.detectEveryNFrames = 1
            c.vision.readyStableMs = 0   // 任何就绪帧都会推进到 gestureWait
        }
        readiness.readiness = MockReadiness.ready()
        readiness.detectDelay = 0.15
        let coord = makeSUT()
        await coord.begin()

        camera.pushFrame()
        await expect("应进入 armed") { await coord.state == .armed }
        camera.pushFrame()             // armed 检测在途（0.15s）
        let det = readiness
        await expect("armed 检测应已在途") { det.detectCount >= 2 }   // 首帧 idle + 本帧 armed
        await coord.cancel()           // 在途时取消

        // 等待在途检测结束（不加复验它会推进到 gestureWait）
        try? await Task.sleep(nanoseconds: 400_000_000)
        let finalState = await coord.state
        XCTAssertEqual(finalState, .idle, "在途检测不应在取消后复活状态机")
    }

    // MARK: - gestureWait 增强

    /// gestureWait 态人离场：不必等满 gestureTimeoutSec，人持续消失即回 idle
    func testGestureWaitPersonAbsentBackToIdle() async {
        await configure { c in
            c.capture.gestureTimeoutSec = 30   // 排除超时路径
            c.vision.detectEveryNFrames = 1
            c.vision.readyStableMs = 0
            c.vision.absentStableMs = 0        // 人一帧即判离场
        }
        readiness.readiness = MockReadiness.ready()
        let coord = makeSUT()
        await coord.begin()

        camera.pushFrame()
        await expect("应进入 armed") { await coord.state == .armed }
        camera.pushFrame()
        await expect("应进入 gestureWait") { await coord.state == .gestureWait }

        // 人离场（无手势 + 无人）→ 应直接回 idle，而不是傻等 30s 超时
        readiness.readiness = .empty
        camera.pushFrame()
        await expect("gestureWait 人消失应回 idle", timeout: 5) { await coord.state == .idle }
        await settle()
        assertInOrder(recorder.states, [.armed, .gestureWait, .idle])
    }

    /// 换手势重置稳定窗口：交替切换手势不应触发拍摄，稳定同一手势才触发
    func testGestureSwitchResetsStableWindow() async {
        await configure { c in
            c.capture.countdownSec = 0
            c.capture.defaultMode = .single
            c.capture.reviewTimeoutSec = 60
            c.vision.detectEveryNFrames = 1
            c.vision.readyStableMs = 0
            c.vision.gestureStableMs = 400   // 需同一手势稳定 400ms
        }
        readiness.readiness = MockReadiness.ready()
        let coord = makeSUT()
        await coord.begin()

        camera.pushFrame()
        await expect("应进入 armed") { await coord.state == .armed }
        camera.pushFrame()
        await expect("应进入 gestureWait") { await coord.state == .gestureWait }

        // 4 帧交替 peace/openPalm：每次换手势都重置计时，即使整体超 400ms 也不触发
        gesture.responses = [.peace, .openPalm, .peace, .openPalm]
        for _ in 0..<4 { camera.pushFrame() }
        try? await Task.sleep(nanoseconds: 500_000_000)   // 超过稳定窗口，但无连续同一手势
        let midState = await coord.state
        XCTAssertEqual(midState, .gestureWait, "交替手势不应触发拍摄")

        // 稳定 peace：第一帧起算，跨过稳定窗口后下一帧触发
        gesture.responses = nil
        gesture.gesture = .peace
        camera.pushFrame()                                 // 起算
        try? await Task.sleep(nanoseconds: 500_000_000)   // 稳定 500ms > 400ms
        camera.pushFrame()                                 // 此帧判定 heldMs≥400 → 开拍
        await expect("稳定同一手势应触发拍摄") { isReview(await coord.state) }
    }
}
