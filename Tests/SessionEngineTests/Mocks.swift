import Foundation
import BoothCore

// ============================================================
// 本地可编程 Mock —— 全部实现 BoothCore 协议，不接真机/真打印。
// 线程模型：final class + NSLock（协议要求非 async 属性 getter，
// 无法用 actor 实现），对外读取一律走锁内快照。
// ============================================================

// MARK: - MockCamera

final class MockCamera: CameraServicing, @unchecked Sendable {
    private let lock = NSLock()
    private let _frames: AsyncStream<Data>
    private let _events: AsyncStream<CameraEvent>
    private let frameCont: AsyncStream<Data>.Continuation
    private let eventCont: AsyncStream<CameraEvent>.Continuation
    private var _connectionState: CameraConnectionState = .liveView

    /// capture() 前的人工延迟（测断线打断拍摄用）
    var captureDelay: TimeInterval = 0
    /// >0 时接下来 N 次 capture() 抛 captureTimeout
    var failNextCaptures = 0
    var connectError: Error?
    var liveViewError: Error?
    private var _captureCount = 0

    init() {
        let (fs, fc) = AsyncStream.makeStream(of: Data.self, bufferingPolicy: .bufferingNewest(256))
        let (es, ec) = AsyncStream.makeStream(of: CameraEvent.self, bufferingPolicy: .bufferingNewest(256))
        _frames = fs; frameCont = fc
        _events = es; eventCont = ec
    }

    var liveViewFrames: AsyncStream<Data> { lock.withLock { _frames } }
    var events: AsyncStream<CameraEvent> { lock.withLock { _events } }
    var connectionState: CameraConnectionState {
        get async { lock.withLock { _connectionState } }
    }

    func connect() async throws { if let e = connectError { throw e } }
    func disconnect() async {}
    func startLiveView() async throws { if let e = liveViewError { throw e } }
    func stopLiveView() async {}
    func refreshStatus() async {}

    func capture() async throws -> CameraCapture {
        let (count, shouldFail): (Int, Bool) = lock.withLock {
            _captureCount += 1
            let fail = failNextCaptures > 0
            if fail { failNextCaptures -= 1 }
            return (_captureCount, fail)
        }
        if shouldFail { throw BoothError.captureTimeout }
        if captureDelay > 0 {
            try await Task.sleep(nanoseconds: UInt64(captureDelay * 1_000_000_000))
        }
        return CameraCapture(handle: UInt32(count),
                             data: Data("fake-jpeg-\(count)".utf8),
                             fileName: String(format: "P10000%02d.JPG", count))
    }

    var captureCount: Int { lock.withLock { _captureCount } }

    /// 测试注入一帧 LiveView
    func pushFrame(_ data: Data = Data([0xFF, 0xD8, 0xFF])) {
        frameCont.yield(data)
    }

    /// 测试注入相机事件
    func emit(_ event: CameraEvent) {
        if case .disconnected = event { lock.withLock { _connectionState = .disconnected } }
        if case .connected = event { lock.withLock { _connectionState = .liveView } }
        eventCont.yield(event)
    }
}

// MARK: - MockGesture

final class MockGesture: GestureDetecting, @unchecked Sendable {
    private let lock = NSLock()
    private var _gesture: DetectedGesture?
    private var _detectCount = 0

    /// 每次检测固定返回该手势（nil = 未检出）
    var gesture: DetectedGesture? {
        get { lock.withLock { _gesture } }
        set { lock.withLock { _gesture = newValue } }
    }

    var detectCount: Int { lock.withLock { _detectCount } }

    func detectGesture(in jpeg: Data) async -> DetectedGesture? {
        lock.withLock { _detectCount += 1 }
        return gesture
    }
}

// MARK: - MockReadiness

final class MockReadiness: PoseReadinessDetecting, @unchecked Sendable {
    private let lock = NSLock()
    private var _readiness = PoseReadiness.empty
    private var _detectCount = 0

    var readiness: PoseReadiness {
        get { lock.withLock { _readiness } }
        set { lock.withLock { _readiness = newValue } }
    }

    var detectCount: Int { lock.withLock { _detectCount } }

    func detectReadiness(in jpeg: Data) async -> PoseReadiness {
        lock.withLock { _detectCount += 1 }
        return readiness
    }

    /// 便捷预设：人在画面且就绪
    static func ready() -> PoseReadiness {
        PoseReadiness(humanPresent: true, facePresent: true, faceAreaRatio: 0.05, isReady: true)
    }
}

// MARK: - MockImaging

final class MockImaging: ImagingServing, @unchecked Sendable {
    struct Call: Sendable, Equatable {
        let originals: Int
        let mode: ShootMode
        let sessionDir: URL
    }

    private let lock = NSLock()
    private var _calls: [Call] = []
    private var _error: Error?
    private var _filterCalls: [PhotoFilter] = []
    private var _qrCalls: [String] = []

    /// 非 nil 时 process() 抛出该错误
    var error: Error? {
        get { lock.withLock { _error } }
        set { lock.withLock { _error = newValue } }
    }

    /// applyFilter 行为开关：true = 返回新 UUID 成片（模拟重打成功）
    var applyFilterReturnsNewPhoto = true

    var calls: [Call] { lock.withLock { _calls } }
    /// applyFilter 收到的滤镜序列
    var filterCalls: [PhotoFilter] { lock.withLock { _filterCalls } }
    /// overlayQR 收到的链接序列（QR 叠印路径验证用）
    var qrCalls: [String] { lock.withLock { _qrCalls } }

    func process(originals: [CameraCapture], mode: ShootMode, sessionDir: URL) async throws -> ProcessedPhoto {
        lock.withLock { _calls.append(Call(originals: originals.count, mode: mode, sessionDir: sessionDir)) }
        if let e = error { throw e }
        return ProcessedPhoto(
            id: UUID(),
            printFile: sessionDir.appendingPathComponent("print.png"),
            displayFile: sessionDir.appendingPathComponent("display.jpg"),
            originals: originals.map { sessionDir.appendingPathComponent($0.fileName) })
    }

    func applyFilter(_ filter: PhotoFilter, to photo: ProcessedPhoto, sessionDir: URL) async throws -> ProcessedPhoto {
        lock.withLock { _filterCalls.append(filter) }
        guard applyFilterReturnsNewPhoto else { return photo }
        return ProcessedPhoto(
            id: UUID(),
            printFile: sessionDir.appendingPathComponent("print-\(filter.rawValue).png"),
            displayFile: sessionDir.appendingPathComponent("display-\(filter.rawValue).jpg"),
            originals: photo.originals,
            baseFile: photo.baseFile)
    }

    func overlayQR(content: String, on photo: ProcessedPhoto) async throws -> ProcessedPhoto {
        lock.withLock { _qrCalls.append(content) }
        return ProcessedPhoto(
            id: photo.id,
            printFile: photo.printFile.deletingLastPathComponent().appendingPathComponent("print-qr.png"),
            displayFile: photo.displayFile,
            originals: photo.originals,
            baseFile: photo.baseFile)
    }
}

// MARK: - MockPrinter

final class MockPrinter: PrintServing, @unchecked Sendable {
    private let lock = NSLock()
    private let _queue: AsyncStream<[PrintJob]>
    private var _submitted: [(imagePath: String, copies: Int)] = []
    private var _jobs: [PrintJob] = []

    init() {
        let (qs, _) = AsyncStream.makeStream(of: [PrintJob].self, bufferingPolicy: .bufferingNewest(16))
        _queue = qs
    }

    var queue: AsyncStream<[PrintJob]> { lock.withLock { _queue } }
    var jobs: [PrintJob] { get async { lock.withLock { _jobs } } }

    @discardableResult
    func submit(image: URL, copies: Int) async -> PrintJob {
        let job = PrintJob(imagePath: image.path, copies: copies)
        lock.withLock {
            _submitted.append((image.path, copies))
            _jobs.append(job)
        }
        return job
    }

    func retry(jobID: UUID) async {}
    func remove(jobID: UUID) async {}

    var submitted: [(imagePath: String, copies: Int)] { lock.withLock { _submitted } }
}

// MARK: - MockServer

final class MockServer: BoothWebServing, @unchecked Sendable {
    private let lock = NSLock()
    private let _commands: AsyncStream<iPadCommand>
    private let commandCont: AsyncStream<iPadCommand>.Continuation
    private var _broadcastStates: [BoothState] = []
    private var _pushedFrameCount = 0
    private var _publishedPhotos: [ProcessedPhoto] = []
    private var _started = false

    let port: UInt16 = 8080

    init() {
        let (cs, cc) = AsyncStream.makeStream(of: iPadCommand.self, bufferingPolicy: .bufferingNewest(64))
        _commands = cs; commandCont = cc
    }

    var commands: AsyncStream<iPadCommand> { lock.withLock { _commands } }

    func start() async throws { lock.withLock { _started = true } }
    func stop() async { lock.withLock { _started = false } }

    func broadcast(state: BoothState) async { lock.withLock { _broadcastStates.append(state) } }
    func pushLiveViewFrame(_ jpeg: Data) async { lock.withLock { _pushedFrameCount += 1 } }
    func publishPhoto(_ photo: ProcessedPhoto) async { lock.withLock { _publishedPhotos.append(photo) } }

    /// 测试注入一条 iPad 指令
    func send(_ command: iPadCommand) { commandCont.yield(command) }

    var broadcastStates: [BoothState] { lock.withLock { _broadcastStates } }
    var pushedFrameCount: Int { lock.withLock { _pushedFrameCount } }
    var publishedPhotos: [ProcessedPhoto] { lock.withLock { _publishedPhotos } }
    var startedFlag: Bool { lock.withLock { _started } }
}

// MARK: - 状态记录器（订阅 EventBus，收集 stateChanged 序列）

final class StateRecorder: @unchecked Sendable {
    private let lock = NSLock()
    private var _states: [BoothState] = []
    private var task: Task<Void, Never>?

    func attach(to bus: EventBus) {
        task = Task { [weak self] in
            for await event in await bus.stream(replayLatest: false) {
                if case .stateChanged(let s) = event { self?.record(s) }
            }
        }
    }

    private func record(_ s: BoothState) { lock.withLock { _states.append(s) } }

    var states: [BoothState] { lock.withLock { _states } }

    func reset() { lock.withLock { _states.removeAll() } }

    deinit { task?.cancel() }
}

// MARK: - 帧计数器（并发安全的 Int 盒子）

final class FrameCounter: @unchecked Sendable {
    private let lock = NSLock()
    private var n = 0
    func increment() { lock.withLock { n += 1 } }
    var count: Int { lock.withLock { n } }
}
