import BoothCore
import Foundation

// ============================================================
// LumixCameraService — CameraServicing 真机实现（SPEC §4）
//  - actor 串行隔离：libLmxptpif.dylib 非线程安全，所有库调用收敛在本 actor
//  - 连接流程按 lmx.py：Init → Reg_NotifyCallback → Search → Select → OpenSession(0)
//  - 断线（0x10000010 或 LiveView 连续错误）→ 指数退避重连，恢复后自动重启 LiveView
//  - C 回调不能捕获上下文：经 LmxEventRouter 单例转发进 actor（Task 投递）
// ============================================================

/// C 回调跳板：全局函数（无捕获），直接作为函数指针注册进 dylib
private func lmxNotifyTrampoline(_ cbid: UInt32, _ param: UInt32,
                                 _ uuid: UnsafeMutablePointer<CChar>?) -> Int32 {
    LmxEventRouter.shared.dispatch(cbid: cbid, param: param, uuid: uuid)
    return 0
}

/// C 回调线程 → actor 的转发单例。
/// C 回调在库的内部线程触发，这里只做一件事：把事件投递出去，绝不调库。
final class LmxEventRouter: @unchecked Sendable {
    static let shared = LmxEventRouter()

    private let lock = NSLock()
    private var handler: (@Sendable (UInt32, UInt32, String) -> Void)?

    private init() {}

    func setHandler(_ h: (@Sendable (UInt32, UInt32, String) -> Void)?) {
        lock.lock(); handler = h; lock.unlock()
    }

    func dispatch(cbid: UInt32, param: UInt32, uuid: UnsafeMutablePointer<CChar>?) {
        // uuid 是库线程的栈/堆指针，必须当场拷贝成 Swift String
        let uuidStr = uuid.map { String(cString: $0) } ?? ""
        lock.lock(); let h = handler; lock.unlock()
        h?(cbid, param, uuidStr)
    }
}

public actor LumixCameraService: CameraServicing {

    // MARK: - 库与会话状态

    private var lib: LmxLibrary?
    private var device: CameraDeviceInfo?
    private var uuidCString: UnsafeMutablePointer<CChar>?   // strdup 持有，API 全链路使用
    private var session: UInt32 = 0
    private var callbacksRegistered = false
    private var state: CameraConnectionState = .disconnected

    /// 配置快照（connect 时从 ConfigStore 刷新）
    private var config = BoothConfig.CameraConf()

    // MARK: - 任务与缓冲区

    private var liveViewTask: Task<Void, Never>?
    private var reconnectTask: Task<Void, Never>?
    private var statusTask: Task<Void, Never>?      // 电量/存储轮询
    private var liveViewBuffer: UnsafeMutablePointer<UInt8>?
    private var liveViewBufferSize = 0
    /// 断线前是否开着 LiveView（重连成功后据此恢复）
    private var wantLiveView = false
    /// 用户主动 disconnect 后置位，抑制自动重连
    private var manuallyDisconnected = false
    /// LiveView 连续非忙错误计数（判定失联的启发式）
    private var consecutiveLiveErrors = 0
    private var consecutiveStatusErrors = 0
    /// 拍照/下载期间置位：暂停 LiveView 取帧与状态轮询的库调用。
    /// 库内 ICCameraDevice 不支持并发命令——拍照数据流期间并发取帧/查状态
    /// 会在库内写坏内存（2026-09-29 两次拍照即崩的根因）。
    private var libraryBusy = false
    private static let liveErrorThreshold = 5

    // MARK: - 事件 / 帧广播（多订阅者各自独立）

    private var eventContinuations: [UUID: AsyncStream<CameraEvent>.Continuation] = [:]
    private var frameContinuations: [UUID: AsyncStream<Data>.Continuation] = [:]

    // MARK: - ObjectAdded 等待者（capture 阻塞点）

    private struct ObjectWaiter {
        let continuation: CheckedContinuation<UInt32, any Error>
        let timeoutTask: Task<Void, Never>
    }
    private var objectWaiters: [UUID: ObjectWaiter] = [:]

/// 无等待者期间到达的 ObjectAdded handle（跳过 RAW 重等 JPEG 时不丢事件）
private var pendingObjectHandles: [UInt32] = []

    // MARK: - 协议属性

    /// 相机事件流（非隔离：协议要求同步 get；注册动作 Task 投递进 actor）
    public nonisolated var events: AsyncStream<CameraEvent> {
        AsyncStream { continuation in
            let id = UUID()
            Task { await self.addEventContinuation(id: id, continuation: continuation) }
            continuation.onTermination = { _ in
                Task { await self.removeEventContinuation(id: id) }
            }
        }
    }

    /// LiveView JPEG 帧流（bufferingNewest(3) 防消费慢积压）
    public nonisolated var liveViewFrames: AsyncStream<Data> {
        AsyncStream(bufferingPolicy: .bufferingNewest(3)) { continuation in
            let id = UUID()
            Task { await self.addFrameContinuation(id: id, continuation: continuation) }
            continuation.onTermination = { _ in
                Task { await self.removeFrameContinuation(id: id) }
            }
        }
    }

    public var connectionState: CameraConnectionState { state }

    public init() {}

    // MARK: - 订阅管理

    private func addEventContinuation(id: UUID, continuation: AsyncStream<CameraEvent>.Continuation) {
        eventContinuations[id] = continuation
    }
    private func removeEventContinuation(id: UUID) {
        eventContinuations.removeValue(forKey: id)
    }
    private func addFrameContinuation(id: UUID, continuation: AsyncStream<Data>.Continuation) {
        frameContinuations[id] = continuation
    }
    private func removeFrameContinuation(id: UUID) {
        frameContinuations.removeValue(forKey: id)
    }

    private func emit(_ event: CameraEvent) {
        for c in eventContinuations.values { c.yield(event) }
    }

    private func pushFrame(_ jpeg: Data) {
        for c in frameContinuations.values { c.yield(jpeg) }
    }

    // MARK: - 状态机

    private func setState(_ new: CameraConnectionState, reason: String = "") {
        guard new != state else { return }
        let old = state
        state = new
        let suffix = reason.isEmpty ? "" : "（\(reason)）"
        Log.camera.info("相机状态: \(old.rawValue) → \(new.rawValue)\(suffix)")
    }

    // MARK: - 连接生命周期（流程严格按 lmx.py open()）

    public func connect() async throws {
        // 已连接/重连中直接返回（幂等）
        switch state {
        case .connected, .liveView:
            Log.camera.debug("connect() 忽略：已连接")
            return
        case .reconnecting:
            throw BoothError.cameraConnectFailed("相机断线重连中，请稍后")
        default:
            break
        }
        manuallyDisconnected = false

        // 刷新配置快照（dylib 路径 / 超时 / 退避参数可能热更新）
        config = await ConfigStore.shared.config.camera

        // 1) 加载库（只加载一次）
        if lib == nil {
            setState(.searching, reason: "加载相机库")
            do {
                lib = try LmxLibrary.load(configuredPath: config.dylibPath)
            } catch let e as LmxLibrary.LoadError {
                setState(.disconnected, reason: "相机库加载失败")
                Log.camera.error("相机库加载失败: \(describe(loadError: e))")
                throw BoothError.cameraConnectFailed(describe(loadError: e))
            }
        }
        guard let lib else { throw BoothError.cameraConnectFailed("相机库未加载") }

        // 2) Init + 注册事件回调（全进程一次）
        if !callbacksRegistered {
            Log.camera.debug("LMX_func_api_Init + 注册事件回调")
            LmxDriver.shared.sync { lib.Init() }
            LmxEventRouter.shared.setHandler { [weak self] cbid, param, uuid in
                Task { await self?.handleNotify(cbid: cbid, param: param, uuid: uuid) }
            }
            var ok = true
            for ev in [LmxEvent.objectAdded, LmxEvent.deviceStray, LmxEvent.deviceStrayAlt,
                       LmxEvent.reqObjTransfer,
                       LmxEvent.dataTransferProg, LmxEvent.dataTransferProgLegacy,
                       LmxEvent.storeAdded, LmxEvent.storeRemoved,
                       LmxEvent.storageInfoChanged] {
                let r = LmxDriver.shared.sync { lib.RegNotifyCallback(ev, lmxNotifyTrampoline) }
                // 逆向前确认：返回值 0 = 注册成功；0x20003(131075) = 事件已在表中；
                // 0x20004(131076) = 表满（>255）。只有后者才是真失败。
                if r != 0 && r != 131075 {
                    Log.camera.warn("Reg_NotifyCallback 失败 event=\(lmxErrHex(ev)) ret=\(r)")
                    ok = false
                }
            }
            callbacksRegistered = ok
        }

        // 3) Search → Select → OpenSession；首连失败进入指数退避重连循环
        //（BoothApp 启动时"相机连接交给 CameraKit 自重连"，SessionCoordinator
        //  只等事件，不负责重试）
        do {
            try openSessionFlow(lib: lib)
        } catch {
            if !manuallyDisconnected {
                Log.camera.warn("首连失败，进入自动重连循环")
                setState(.reconnecting, reason: "首连失败")
                startReconnectLoop()
            }
            throw error
        }

        // 连接成功即拉首份状态报告 + 启动轮询
        startStatusLoop()
        await refreshStatus()
    }

    /// Search → Select → OpenSession 主流程（connect 与重连共用）
    private func openSessionFlow(lib: LmxLibrary) throws {
        setState(.searching)

        // 3) Search_Device 枚举
        let devices = searchDevices(lib: lib)
        guard let dev = devices.first else {
            setState(.disconnected, reason: "未发现相机")
            Log.camera.error("未发现 LUMIX 相机——请检查：1) USB 线已连接 2) 机身 USB 模式已设为『Tether』 3) 相机已开机")
            throw BoothError.cameraNotFound
        }
        Log.camera.info("发现相机: model=\(dev.model) serial=\(dev.serial) devId=\(dev.devId) uuid=\(dev.uuid)")
        setState(.connecting, reason: dev.model)

        // 4) 重新 Search 填 info 缓冲区，再 SelectPnPDevice（lmx.py open() 的顺序）
        var err: UInt32 = 0
        let info = UnsafeMutableRawPointer.allocate(byteCount: LmxDeviceInfoParser.bufferSize, alignment: 8)
        defer { info.deallocate() }
        _ = LmxDriver.shared.sync { lib.SearchDevice(info, &err) }
        let name = UnsafeMutablePointer<CChar>.allocate(capacity: 512)
        defer { name.deallocate() }
        guard LmxDriver.shared.sync({ lib.SelectPnPDevice(dev.devId, info, name, nil, nil, 0, &err) }) != 0 else {
            setState(.disconnected, reason: "SelectPnPDevice 失败")
            Log.camera.error("SelectPnPDevice 失败 err=\(lmxErrHex(err))")
            throw BoothError.cameraConnectFailed("SelectPnPDevice err=\(lmxErrHex(err))")
        }
        // SelectPnPDevice 成功后，name 输出参数里是库内部生成的【会话 UUID】
        // （uuid_generate_random，存于句柄 handle+260）。后续所有 API 的 uuid
        // 参数必须传这个会话 UUID，而不是 Search 返回的序列号——
        // Controller send: 按 strcmp(handle+260, uuid) 查句柄，传序列号必然失败。
        let nameLen = strlen(name)
        guard nameLen > 0 else {
            setState(.disconnected, reason: "SelectPnPDevice 未返回会话 UUID")
            Log.camera.error("SelectPnPDevice 成功但 name 为空（无会话 UUID）")
            throw BoothError.cameraConnectFailed("SelectPnPDevice 未返回会话 UUID")
        }
        Log.camera.info("SelectPnPDevice 会话 UUID: \(String(cString: name))")

        // 5) OpenSession(0) —— 传会话 UUID（name），不是序列号
        let uuidBuf = strdup(name)
        var sess: UInt32 = 0
        err = 0
        guard let uuidBuf, LmxDriver.shared.sync({ lib.OpenSession(0, &sess, uuidBuf, &err) }) != 0 else {
            free(uuidBuf)
            setState(.disconnected, reason: "OpenSession 失败")
            Log.camera.error("OpenSession 失败 err=\(lmxErrHex(err))")
            throw BoothError.cameraConnectFailed("OpenSession err=\(lmxErrHex(err))")
        }

        // 替换旧会话
        if let old = uuidCString { free(old) }
        uuidCString = uuidBuf
        device = dev
        session = sess
        consecutiveLiveErrors = 0
        consecutiveStatusErrors = 0
        setState(.connected, reason: "session=0x\(String(sess, radix: 16))")
        emit(.connected(dev))
    }

    /// 枚举 USB 相机（失败返回空数组并记日志，不抛错——给重连用）
    private func searchDevices(lib: LmxLibrary) -> [CameraDeviceInfo] {
        let buf = UnsafeMutableRawPointer.allocate(byteCount: LmxDeviceInfoParser.bufferSize, alignment: 8)
        defer { buf.deallocate() }
        buf.initializeMemory(as: UInt8.self, repeating: 0, count: LmxDeviceInfoParser.bufferSize)
        var err: UInt32 = 0
        guard LmxDriver.shared.sync({ lib.SearchDevice(buf, &err) }) != 0 else {
            Log.camera.warn("Search_Device 失败 err=\(lmxErrHex(err))")
            return []
        }
        return LmxDeviceInfoParser.parse(UnsafeRawPointer(buf))
    }

    public func disconnect() async {
        Log.camera.info("disconnect() 主动断开")
        manuallyDisconnected = true
        reconnectTask?.cancel(); reconnectTask = nil
        statusTask?.cancel(); statusTask = nil
        await stopLiveViewInternal(callLibrary: state == .liveView)
        failAllObjectWaiters(BoothError.captureFailed("相机已断开"))
        if let lib, let uuid = uuidCString {
            var err: UInt32 = 0
            _ = LmxDriver.shared.sync { lib.CloseDevice(uuid, &err) }
            Log.camera.debug("CloseDevice err=\(lmxErrHex(err))")
        }
        if let uuid = uuidCString { free(uuid) }
        uuidCString = nil
        device = nil
        session = 0
        wantLiveView = false
        setState(.disconnected, reason: "主动断开")
        emit(.disconnected(reason: "主动断开"))
    }

    // MARK: - LiveView

    public func startLiveView() async throws {
        guard let lib, let uuid = uuidCString else {
            throw BoothError.liveViewFailed("相机未连接")
        }
        guard state == .connected else {
            if state == .liveView { Log.camera.debug("startLiveView() 忽略：已在取流"); return }
            if state == .reconnecting { throw BoothError.liveViewFailed("相机断线重连中，请稍后") }
            throw BoothError.liveViewFailed("当前状态 \(state.rawValue) 不能开 LiveView")
        }
        var err: UInt32 = 0
        guard LmxDriver.shared.sync({ lib.LiveViewStart(uuid, &err) }) != 0 else {
            Log.camera.error("LiveView Start 失败 err=\(lmxErrHex(err))")
            throw BoothError.liveViewFailed("LiveView Start err=\(lmxErrHex(err))")
        }
        wantLiveView = true
        setState(.liveView)
        startLiveViewLoop()
        Log.camera.info("LiveView 已开启（~30Hz 轮询）")
    }

    public func stopLiveView() async {
        await stopLiveViewInternal(callLibrary: true)
    }

    private func stopLiveViewInternal(callLibrary: Bool) {
        wantLiveView = false
        liveViewTask?.cancel(); liveViewTask = nil
        freeLiveViewBuffer()
        if callLibrary, let lib, let uuid = uuidCString {
            var err: UInt32 = 0
            _ = LmxDriver.shared.sync { lib.LiveViewStop(uuid, &err) }
            Log.camera.debug("LiveView Stop err=\(lmxErrHex(err))")
        }
        if state == .liveView { setState(.connected, reason: "LiveView 停止") }
        Log.camera.info("LiveView 已停止")
    }

    private func startLiveViewLoop() {
        liveViewTask?.cancel()
        allocateLiveViewBuffer()
        liveViewTask = Task { [weak self] in
            while !Task.isCancelled {
                guard let self else { return }
                let keepGoing = await self.pollLiveViewFrame()
                if !keepGoing { return }
                try? await Task.sleep(nanoseconds: 33_000_000)  // ~30Hz
            }
        }
    }

    private func allocateLiveViewBuffer() {
        freeLiveViewBuffer()
        liveViewBufferSize = max(config.liveViewBufferSize, 1 << 20)  // E3：官方 1MB，防 JPEG 帧截断
        liveViewBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: liveViewBufferSize)
    }

    private func freeLiveViewBuffer() {
        liveViewBuffer?.deallocate()
        liveViewBuffer = nil
        liveViewBufferSize = 0
    }

    /// 轮询一帧 LiveView。返回值：是否继续轮询（false = 失联转重连）
    private func pollLiveViewFrame() -> Bool {
        guard state == .liveView, let lib, let uuid = uuidCString, let buf = liveViewBuffer else { return false }
        if libraryBusy { return true }   // 拍照/下载中：跳过本帧，不碰库
        var size: UInt32 = 0
        var err: UInt32 = 0
        let r = LmxDriver.shared.sync { lib.GetLiveViewData(buf, &size, uuid, &err) }
        if r != 0 && size > 0 {
            let raw = Data(bytes: buf, count: Int(size))
            // Mnt_Get_LiveView_data 返回的不是裸 JPEG：前面是 PTP TLV 段
            //（{u32 tag(0x17xxxxxx); u32 size; payload} 列表，实测 JPEG 负载
            // 从 SOI 标记 FF D8 FF 起，头长约 0xB4 字节）。定位 SOI 后截取。
            if let soi = raw.firstRange(of: Data([0xFF, 0xD8, 0xFF])) {
                pushFrame(raw.subdata(in: soi.lowerBound..<raw.endIndex))
                consecutiveLiveErrors = 0
                return true
            }
            // 无 SOI：当作无新帧，不计数（避免误判失联）
            return true
        }
        if err == LmxError.lvBusy { return true }   // 忙：正常，跳过等下一帧
        if err == 0 { return true }                  // 无新帧
        // 其他错误：计数，连续超阈值判失联
        consecutiveLiveErrors += 1
        Log.camera.warn("LiveView 取帧错误 err=\(lmxErrHex(err))（连续 \(consecutiveLiveErrors)/\(LumixCameraService.liveErrorThreshold)）")
        if consecutiveLiveErrors >= LumixCameraService.liveErrorThreshold {
            handleConnectionLost("LiveView 连续取帧失败 err=\(lmxErrHex(err))")
            return false
        }
        return true
    }

    // MARK: - 电量 / 存储状态轮询

    /// 立即查一次电量/存储并广播 statusReport（协议要求；也供事件触发刷新）
    public func refreshStatus() async {
        guard let lib, let uuid = uuidCString,
              state == .connected || state == .liveView else { return }
        if libraryBusy { return }   // 拍照/下载中：跳过本轮状态轮询，不碰库

        // 电量：GetBatteryInfo 写 16B 结构体
        var batteryFields: [UInt16] = []
        var bat = LmxBatteryInfo()
        var err: UInt32 = 0
        var failCount = 0
        if LmxDriver.shared.sync({ lib.GetBatteryInfo(&bat, uuid, &err) }) != 0 {
            batteryFields = bat.fieldArray
        } else {
            failCount += 1
            Log.camera.debug("GetBatteryInfo 失败 err=\(lmxErrHex(err))")
        }

        // 存储：GetFreeSpaceInSec 可录秒数
        var freeSec: UInt32 = 0
        err = 0
        var freeSeconds: UInt32?
        if LmxDriver.shared.sync({ lib.GetFreeSpaceInSec(&freeSec, uuid, &err) }) != 0 {
            freeSeconds = freeSec
        } else {
            failCount += 1
            Log.camera.debug("GetFreeSpaceInSec 失败 err=\(lmxErrHex(err))")
        }

        // 失联检测：两项都返回 0（err=0）说明句柄/会话已静默失效
        //（如 ptpcamerad 抢走设备后 XPC 代理失效）。连续两轮全失败则转重连。
        if failCount >= 2 {
            consecutiveStatusErrors += 1
            if consecutiveStatusErrors >= 2 {
                handleConnectionLost("状态轮询连续失败（会话静默失效）")
                return
            }
        } else {
            consecutiveStatusErrors = 0
        }

        let report = CameraStatusReport(batteryFields: batteryFields, freeRecordSeconds: freeSeconds)
        Log.camera.debug("状态报告: battery=\(batteryFields) freeSec=\(freeSec)")
        emit(.statusReport(report))
    }

    /// 连接成功后启动轮询（间隔 config.statusPollIntervalSec，0 = 不启动）
    private func startStatusLoop() {
        statusTask?.cancel()
        let interval = max(config.statusPollIntervalSec, 1)
        guard config.statusPollIntervalSec > 0 else { return }
        statusTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))
                guard !Task.isCancelled else { return }
                await self?.refreshStatus()
            }
        }
    }

    // MARK: - 断线重连

    /// 进入重连：状态 reconnecting，指数退避 Search/Select/OpenSession，
    /// 成功后恢复 connected 并按需自动重启 LiveView（SPEC §4.2）
    private func handleConnectionLost(_ reason: String) {
        guard state != .reconnecting, state != .disconnected else { return }
        Log.camera.error("相机连接丢失：\(reason)")
        failAllObjectWaiters(BoothError.captureFailed("相机连接中断（\(reason)），正在重连"))
        emit(.disconnected(reason: reason))

        // 断开现场清理（不调库——设备已失联）
        liveViewTask?.cancel(); liveViewTask = nil
        statusTask?.cancel(); statusTask = nil
        freeLiveViewBuffer()
        if let uuid = uuidCString { free(uuid) }
        uuidCString = nil
        setState(.reconnecting, reason: reason)

        guard !manuallyDisconnected else { return }
        startReconnectLoop()
    }

    private func startReconnectLoop() {
        reconnectTask?.cancel()
        let base = config.reconnectBaseDelaySec
        let maxDelay = config.reconnectMaxDelaySec
        reconnectTask = Task { [weak self] in
            var delay = max(base, 0.2)
            var attempt = 0
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                guard !Task.isCancelled else { return }
                guard let self else { return }
                attempt += 1
                let recovered = await self.attemptReconnect(attempt: attempt)
                if recovered { return }
                delay = min(delay * 2, maxDelay)
            }
        }
    }

    /// 单次重连尝试。成功返回 true。
    private func attemptReconnect(attempt: Int) async -> Bool {
        guard let lib else { return false }
        Log.camera.info("重连尝试 #\(attempt)…")
        do {
            try openSessionFlow(lib: lib)
        } catch {
            Log.camera.warn("重连 #\(attempt) 失败: \(error.localizedDescription)")
            return false
        }
        // 恢复 LiveView
        if wantLiveView, state == .connected, let lib2 = self.lib, let uuid = uuidCString {
            var err: UInt32 = 0
            if lib2.LiveViewStart(uuid, &err) != 0 {
                setState(.liveView, reason: "重连后自动恢复")
                startLiveViewLoop()
                Log.camera.info("重连成功，LiveView 已自动恢复（第 \(attempt) 次尝试）")
            } else {
                Log.camera.error("重连成功但 LiveView 恢复失败 err=\(lmxErrHex(err))")
            }
        } else {
            Log.camera.info("重连成功（第 \(attempt) 次尝试）")
        }
        // 恢复状态轮询 + 立即出一份报告
        startStatusLoop()
        await refreshStatus()
        return true
    }

    // MARK: - 事件回调（C 线程 → 本 actor）

    private func handleNotify(cbid: UInt32, param: UInt32, uuid: String) {
        switch cbid {
        case LmxEvent.objectAdded:
            Log.camera.info("事件 ObjectAdded handle=\(param)")
            emit(.objectAdded(handle: param))
            fulfillObjectWaiters(handle: param)
        case LmxEvent.reqObjTransfer:
            Log.camera.info("事件 ReqObjTransfer handle=\(param)")
            fulfillObjectWaiters(handle: param)
        case LmxEvent.deviceStray, LmxEvent.deviceStrayAlt:
            handleConnectionLost("相机失联（事件 0x\(String(cbid, radix: 16))）")
        case LmxEvent.dataTransferProg, LmxEvent.dataTransferProgLegacy:
            emit(.transferProgress(percent: param))
        case LmxEvent.storeAdded:
            Log.camera.info("事件：存储卡插入 storageID=\(param)")
            emit(.storeAdded(storageID: param))
            Task { await self.refreshStatus() }   // 事件线程外立刻刷一份
        case LmxEvent.storeRemoved:
            Log.camera.warn("事件：存储卡拔出 storageID=\(param)")
            emit(.storeRemoved(storageID: param))
        case LmxEvent.storageInfoChanged:
            Log.camera.info("事件：存储信息变更 storageID=\(param)")
            Task { await self.refreshStatus() }
        default:
            Log.camera.debug("事件 cbid=\(lmxErrHex(cbid)) param=\(param)")
        }
    }

    // MARK: - 拍照 / 下载

    public func capture() async throws -> CameraCapture {
        guard let lib, let uuid = uuidCString else {
            throw BoothError.cameraConnectFailed("相机未连接")
        }
        switch state {
        case .reconnecting:
            throw BoothError.captureFailed("相机断线重连中，请稍候再拍")
        case .connected, .liveView:
            break
        default:
            throw BoothError.captureFailed("相机未就绪（状态 \(state.rawValue)）")
        }

        // 清 pending：上一次遗留的等待者一律作废
        failAllObjectWaiters(BoothError.captureFailed("被新一次拍照取代"))

        // 拍照+下载期间独占库：暂停 LiveView 取帧与状态轮询
        libraryBusy = true
        defer { libraryBusy = false }

        // E2（官方对齐）：拍照走 Rec_Ctrl_Release one_shot（PTP 0x9404）。
        // 官方主程序从未调用过 StilLCapture_Single（docs/lumix-tether-analysis 04/06），
        // 它是库暴露的未验证路径——恰是历次拍照 SIGBUS 崩溃点，弃用。
        var ctrl = LmxRecCtrl()
        ctrl.param = 0x3000011          // one_shot：单张全按
        var capErr: UInt32 = 0
        Log.camera.info("拍照：Rec_Ctrl_Release one_shot（官方路径，已暂停 LiveView/状态轮询）")
        guard LmxDriver.shared.sync({ lib.RecCtrlRelease(&ctrl, uuid, &capErr) }) != 0 else {
            Log.camera.error("Rec_Ctrl_Release 失败 err=\(lmxErrHex(capErr))")
            throw BoothError.captureFailed("Rec_Ctrl_Release 失败 err=\(lmxErrHex(capErr))")
        }

        // 等 ObjectAdded；RAW+JPEG 双落卡时官方下载器只取 JPEG（Get_Object 整包），
        // RAW 走 Get_Partial_Object 分段——我们同理：跳过非 JPEG 对象，只下载 JPEG。
        // 若相机设为仅 RAW，会在超时后报错提示切回 JPEG。
        let deadline = Date().addingTimeInterval(config.captureTimeoutSec)
        var handle: UInt32 = 0
        while true {
            let remaining = deadline.timeIntervalSinceNow
            guard remaining > 0 else { throw BoothError.captureTimeout }
            let h = try await waitObjectAdded(timeout: remaining)
            var fmt: UInt32 = 0
            var fmtErr: UInt32 = 0
            if LmxDriver.shared.sync({ lib.GetObjectFormatType(h, &fmt, uuid, &fmtErr) }) != 0,
               fmt == 1 || fmt == 2 {   // 库内部枚举：0x3800/0x3801/0x3808 各代 JPEG → 1/2；0x3001 RAW → 3（反编译 0x18bd0）
                handle = h
                break
            }
            Log.camera.info("跳过非 JPEG 对象 handle=\(h) format=\(fmt)（3=RAW/4-5=视频），继续等 JPEG 落卡")
        }
        Log.camera.info("收到 JPEG ObjectAdded handle=\(handle)，开始下载")
        return try downloadObject(handle: handle, lib: lib, uuid: uuid)
    }

    /// 阻塞等 ObjectAdded 回调；超时抛 captureTimeout。
    /// 无等待者期间到达的 handle 先存 pending（拍照方跳过 RAW 重等 JPEG 时不会丢 JPEG 事件）
    private func waitObjectAdded(timeout: Double) async throws -> UInt32 {
        if !pendingObjectHandles.isEmpty {
            return pendingObjectHandles.removeFirst()
        }
        let id = UUID()
        return try await withCheckedThrowingContinuation { continuation in
            let timeoutTask = Task { [weak self] in
                try? await Task.sleep(nanoseconds: UInt64(max(timeout, 0.1) * 1_000_000_000))
                guard !Task.isCancelled else { return }
                await self?.objectAddedTimedOut(id: id, timeout: timeout)
            }
            objectWaiters[id] = ObjectWaiter(continuation: continuation, timeoutTask: timeoutTask)
        }
    }

    private func objectAddedTimedOut(id: UUID, timeout: Double) {
        guard let w = objectWaiters.removeValue(forKey: id) else { return }
        Log.camera.error("拍照超时：\(timeout)s 内未收到 ObjectAdded（检查存储卡/快门状态）")
        w.continuation.resume(throwing: BoothError.captureTimeout)
    }

    private func fulfillObjectWaiters(handle: UInt32) {
        let waiters = objectWaiters
        objectWaiters.removeAll()
        if waiters.isEmpty {
            pendingObjectHandles.append(handle)   // 暂无等待者（如正跳过 RAW）：存起来不丢
            return
        }
        for w in waiters.values {
            w.timeoutTask.cancel()
            w.continuation.resume(returning: handle)
        }
    }

    private func failAllObjectWaiters(_ error: any Error) {
        pendingObjectHandles.removeAll()
        let waiters = objectWaiters
        objectWaiters.removeAll()
        for w in waiters.values {
            w.timeoutTask.cancel()
            w.continuation.resume(throwing: error)
        }
    }

    /// Get_Object_DataSize → Get_Object → Get_Object_FileName（lmx.py download + object_info）
    private func downloadObject(handle: UInt32, lib: LmxLibrary,
                                uuid: UnsafeMutablePointer<CChar>) throws -> CameraCapture {
        var err: UInt32 = 0

        // 大小 + 格式（崩溃诊断关键信息，务必先落盘）
        var size: UInt64 = 0
        guard LmxDriver.shared.sync({ lib.GetObjectDataSize(handle, &size, uuid, &err) }) != 0, size > 0 else {
            Log.camera.error("Get_Object_DataSize 失败 handle=\(handle) err=\(lmxErrHex(err))")
            throw BoothError.captureFailed("Get_Object_DataSize err=\(lmxErrHex(err))")
        }
        var dlFmt: UInt32 = 0
        _ = LmxDriver.shared.sync { lib.GetObjectFormatType(handle, &dlFmt, uuid, &err) }
        Log.camera.info("下载对象 handle=\(handle) format=\(lmxErrHex(dlFmt)) size=\(size)")

        // 文件名（失败不阻断，用 handle 兜底命名）
        var nameStr = "P\(handle).JPG"
        var ptpName = LmxPTPArrayString()
        err = 0
        if LmxDriver.shared.sync({ lib.GetObjectFileName(handle, &ptpName, uuid, &err) }) != 0 {   // 裸指针传结构体，布局见 LmxTypes
            let n = ptpName.string()
            if !n.isEmpty { nameStr = n }
        } else {
            Log.camera.warn("Get_Object_FileName 失败 err=\(lmxErrHex(err))，使用兜底名 \(nameStr)")
        }

        // 下载全图：小 JPEG 走官方整包 Get_Object；大文件走官方 RAW 同款
        // Get_Partial_Object 分段（历次 SIGBUS 均发生在长事务中，分段缩短单次事务）
        let bufSize = UInt32(min(size, UInt64(UInt32.max)))
        let buf = UnsafeMutablePointer<UInt8>.allocate(capacity: Int(bufSize))
        defer { buf.deallocate() }
        err = 0
        if bufSize <= 8 << 20 {
            guard LmxDriver.shared.sync({ lib.GetObject(handle, buf, bufSize, uuid, &err) }) != 0 else {
                Log.camera.error("Get_Object 失败 handle=\(handle) err=\(lmxErrHex(err))")
                throw BoothError.captureFailed("Get_Object err=\(lmxErrHex(err))")
            }
        } else {
            let chunkSize: UInt32 = 1 << 20   // 1MB/段，段间控制台可观察进度
            var offset: UInt32 = 0
            while offset < bufSize {
                let n = min(chunkSize, bufSize - offset)
                err = 0
                // 参数序（反编译 0x3b9ec）：handle, buf, offset, size——a3=offset, a4=size（a4≠0）
                guard LmxDriver.shared.sync({ lib.GetPartialObject(handle, buf + Int(offset), offset, n, uuid, &err) }) != 0 else {
                    Log.camera.error("Get_Partial_Object 失败 handle=\(handle) offset=\(offset) err=\(lmxErrHex(err))")
                    throw BoothError.captureFailed("Get_Partial_Object err=\(lmxErrHex(err))")
                }
                offset += n
                Log.camera.debug("分段下载 handle=\(handle) \(offset)/\(bufSize)")
            }
        }
        let data = Data(bytes: buf, count: Int(bufSize))
        Log.camera.info("下载完成: \(nameStr) \(data.count) 字节")
        return CameraCapture(handle: handle, data: data, fileName: nameStr)
    }

    // MARK: - 错误描述

    private func describe(loadError: LmxLibrary.LoadError) -> String {
        switch loadError {
        case .notFound(let searched):
            return "找不到 libLmxptpif.dylib，已查找: \(searched.joined(separator: ", "))"
        case .openFailed(let path, let detail):
            return "dlopen 失败 \(path): \(detail)"
        case .missingSymbols(let missing):
            return "相机库版本不匹配，缺失符号: \(missing.joined(separator: ", "))"
        }
    }
}
