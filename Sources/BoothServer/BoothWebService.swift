import Foundation
import Network
import BoothCore

// ============================================================
// BoothWebService —— 内嵌 HTTP + WebSocket 服务（SPEC §8）
// Network.framework 手写实现，零第三方依赖。
//
// 路由：
//   GET /                     iPad 单页应用（WebAssets.indexHTML）
//   GET /live                 LiveView MJPEG 流（multipart/x-mixed-replace; boundary=booth）
//   GET /photo/{id}           成片下载（QR 码指向），publishPhoto 注册后可取
//   GET /photo/history/{date}/{session}  历史成片（gallery/slideshow 用）
//   GET /api/photos           最近成片列表 JSON（gallery/slideshow 拉取）
//   GET /gallery              iPad 独立相册页
//   GET /slideshow            iPad 独立放映页
//   GET /ws                   WebSocket（Upgrade 握手）：状态下行 + iPad 指令上行
//
// 并发模型（Swift 6 严格并发）：
//   - 本类型是 actor：所有连接的收包解析、路由、广播都在 actor 内串行执行
//   - Network 回调在队列线程，只做一件事：Task { await self.xxx() } 投递回 actor
//   - 协议的同步要求（port / commands）用 nonisolated + 线程安全小箱子满足
//   - 每个连接的「下一次 receive」在当前数据处理完之后才调度，
//     保证同一连接的数据严格按序处理
// ============================================================

/// 线程安全端口盒子（协议同步要求 port 需要 nonisolated 读取）
final class PortBox: @unchecked Sendable {
    private let lock = NSLock()
    private var value_: UInt16 = 0
    var value: UInt16 {
        lock.lock(); defer { lock.unlock() }
        return value_
    }
    func set(_ v: UInt16) {
        lock.lock(); value_ = v; lock.unlock()
    }
}

/// 多订阅指令流枢纽：每次访问 commands 生成一条独立流，iPad 指令广播到所有订阅者
final class MultiStreamHub<Element: Sendable>: @unchecked Sendable {
    private let lock = NSLock()
    private var continuations: [UUID: AsyncStream<Element>.Continuation] = [:]

    func makeStream() -> AsyncStream<Element> {
        let id = UUID()
        return AsyncStream(bufferingPolicy: .bufferingNewest(64)) { cont in
            lock.lock()
            continuations[id] = cont
            lock.unlock()
            cont.onTermination = { [weak self] _ in self?.remove(id) }
        }
    }

    private func remove(_ id: UUID) {
        lock.lock()
        continuations.removeValue(forKey: id)
        lock.unlock()
    }

    func yield(_ element: Element) {
        lock.lock()
        let targets = Array(continuations.values)
        lock.unlock()
        for c in targets { c.yield(element) }
    }
}

/// 一次性就绪信号（listener ready/failed 只 resume 一次）
final class ReadyPromise: @unchecked Sendable {
    private let lock = NSLock()
    private var continuation: CheckedContinuation<Void, Error>?
    private var result: Result<Void, Error>?

    func wait() async throws {
        try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Void, Error>) in
            lock.lock()
            if let r = result { lock.unlock(); cont.resume(with: r); return }
            continuation = cont
            lock.unlock()
        }
    }

    func resume(_ r: Result<Void, Error>) {
        lock.lock()
        guard result == nil else { lock.unlock(); return }
        result = r
        let cont = continuation
        continuation = nil
        lock.unlock()
        cont?.resume(with: r)
    }
}

/// 带超时执行（防 listener 永不 ready 卡死 start）
func withTimeout<T: Sendable>(seconds: Double, _ op: @escaping @Sendable () async throws -> T) async throws -> T {
    try await withThrowingTaskGroup(of: T.self) { group in
        group.addTask { try await op() }
        group.addTask {
            try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
            throw BoothError.serverFailed("等待超时（\(seconds)s）")
        }
        guard let first = try await group.next() else {
            throw BoothError.serverFailed("超时竞速异常")
        }
        group.cancelAll()
        return first
    }
}

/// 单个客户端连接的会话状态（只在 actor 内访问，无并发问题）
final class ClientSession {
    enum Mode {
        case http          // 还在收 HTTP 请求
        case live          // MJPEG 取景流（服务端只写不读）
        case websocket     // 已完成 WS 升级
    }

    let conn: NWConnection
    var mode: Mode = .http
    var buffer = Data()
    // WS 分片消息重组缓冲
    var fragments = Data()
    var fragmentOpcode: UInt8?
    // 指令限速记账：滑动窗口内收到的文本指令时间戳（防脚本刷 print/retake）
    var commandTimes: [Date] = []

    init(conn: NWConnection) { self.conn = conn }
}

public actor BoothWebService: BoothWebServing {

    private let conf: BoothConfig
    private let netQueue = DispatchQueue(label: "booth.server", qos: .userInitiated)
    private let commandHub = MultiStreamHub<iPadCommand>()
    private let portBox = PortBox()

    private var listener: NWListener?
    private var sessions: [ObjectIdentifier: ClientSession] = [:]
    private var photos: [UUID: URL] = [:]
    /// 最近一次广播的状态，新 WS 客户端接入立即补发（断线重连不丢屏）
    private var lastState: BoothState?
    /// MJPEG 帧率封顶用的时间戳
    private var lastLivePush: Date?
    /// 历史成片列表缓存（访问 /api/photos 时刷新；避免每次扫盘）
    private var historyCache: [HistoryPhoto]?
    private var historyCacheAt: Date?

    public init(conf: BoothConfig = BoothConfig()) {
        self.conf = conf
    }

    // MARK: - BoothWebServing 协议（同步要求 → nonisolated）

    public nonisolated var port: UInt16 { portBox.value }
    public nonisolated var commands: AsyncStream<iPadCommand> { commandHub.makeStream() }

    // MARK: - 生命周期（幂等）

    public func start() async throws {
        if listener != nil {
            Log.server.info("start() 幂等：服务已在端口 \(portBox.value) 运行，忽略")
            return
        }
        let params = NWParameters.tcp
        params.allowLocalEndpointReuse = true
        // port=0 → 系统分配（测试用），实际端口等 ready 后从 listener 读
        let requested = conf.server.port == 0 ? NWEndpoint.Port.any : NWEndpoint.Port(rawValue: conf.server.port)!

        let newListener: NWListener
        do {
            newListener = try NWListener(using: params, on: requested)
        } catch {
            Log.server.error("创建监听失败（端口 \(conf.server.port)）: \(error)")
            throw BoothError.serverFailed("创建监听失败: \(error)")
        }

        let ready = ReadyPromise()
        newListener.stateUpdateHandler = { [weak newListener] state in
            guard let newListener else { return }
            switch state {
            case .ready:
                let p = newListener.port?.rawValue ?? 0
                self.portBox.set(p)
                Log.server.info("监听就绪：实际端口 \(p)（配置请求 \(requested.rawValue)）")
                ready.resume(.success(()))
            case .failed(let error):
                // 典型场景：端口被占用（EADDRINUSE）
                Log.server.error("监听失败（端口 \(requested.rawValue)）: \(error)")
                ready.resume(.failure(BoothError.serverFailed("监听失败: \(error)")))
                newListener.cancel()
            case .cancelled:
                ready.resume(.failure(BoothError.serverFailed("监听被取消")))
            default:
                break
            }
        }
        newListener.newConnectionHandler = { [weak self] connection in
            guard let self else { connection.cancel(); return }
            Task { await self.accept(connection) }
        }

        listener = newListener
        newListener.start(queue: netQueue)

        do {
            try await withTimeout(seconds: 5) { try await ready.wait() }
            Log.server.info("BoothServer 启动完成，端口 \(portBox.value)")
        } catch {
            newListener.newConnectionHandler = nil
            newListener.stateUpdateHandler = nil
            newListener.cancel()
            if listener === newListener { listener = nil }
            portBox.set(0)
            if let boothError = error as? BoothError { throw boothError }
            throw BoothError.serverFailed("启动失败: \(error)")
        }
    }

    public func stop() async {
        guard let l = listener else {
            Log.server.info("stop() 幂等：服务未在运行，忽略")
            return
        }
        l.newConnectionHandler = nil
        l.stateUpdateHandler = nil
        l.cancel()
        listener = nil
        portBox.set(0)
        let conns = sessions.values.map { $0.conn }
        sessions.removeAll()
        for c in conns { c.cancel() }
        Log.server.info("BoothServer 已停止，关闭 \(conns.count) 个连接")
    }

    // MARK: - 对外推送接口

    public func broadcast(state: BoothState) async {
        lastState = state
        let json = stateJSON(state)
        let frame = WSCodec.encode(opcode: WSOpcode.text, payload: Data(json.utf8))
        var sent = 0
        for session in sessions.values where session.mode == .websocket {
            send(session.conn, frame)
            sent += 1
        }
        Log.server.info("广播状态给 \(sent) 个 WS 客户端: \(json)")
    }

    public func pushLiveViewFrame(_ jpeg: Data) async {
        let liveSessions = sessions.values.filter { $0.mode == .live }
        guard !liveSessions.isEmpty else { return }
        // 帧率封顶：太快直接丢帧（不排队，避免延迟累积）
        let maxFPS = max(1, conf.server.ipadMaxFPS)
        if let last = lastLivePush, Date().timeIntervalSince(last) < 1.0 / Double(maxFPS) {
            return
        }
        lastLivePush = Date()
        var part = Data()
        part.append(Data("--booth\r\nContent-Type: image/jpeg\r\nContent-Length: \(jpeg.count)\r\n\r\n".utf8))
        part.append(jpeg)
        part.append(Data("\r\n".utf8))
        for session in liveSessions { send(session.conn, part) }
        Log.server.debug("MJPEG 推帧 \(jpeg.count) 字节给 \(liveSessions.count) 个取景连接")
    }

    public func publishPhoto(_ photo: ProcessedPhoto) async {
        photos[photo.id] = photo.displayFile
        Log.server.info("注册成片供下载: \(photo.id.uuidString) → \(photo.displayFile.lastPathComponent)")
    }

    // MARK: - 连接接入与收包

    private func accept(_ conn: NWConnection) {
        sessions[ObjectIdentifier(conn)] = ClientSession(conn: conn)
        Log.server.info("新连接: \(conn.endpointDescription)")
        conn.stateUpdateHandler = { [weak self] state in
            switch state {
            case .failed(let error):
                Log.server.warn("连接出错: \(error)")
                Task { await self?.cleanup(conn) }
            case .cancelled:
                Task { await self?.cleanup(conn) }
            default:
                break
            }
        }
        conn.start(queue: netQueue)
        receive(conn)
    }

    /// 调度一次收包；数据/事件处理完（回到 actor）后才调度下一次，保证按序
    private func receive(_ conn: NWConnection) {
        conn.receive(minimumIncompleteLength: 1, maximumLength: 1 << 20) { [weak self] data, _, isComplete, error in
            guard let self else { return }
            Task { await self.handleRead(conn, data: data, isComplete: isComplete, error: error) }
        }
    }

    private func handleRead(_ conn: NWConnection, data: Data?, isComplete: Bool, error: NWError?) {
        let key = ObjectIdentifier(conn)
        guard sessions[key] != nil else { return }   // 已清理

        if let error {
            Log.server.warn("读取错误（\(conn.endpointDescription)）: \(error)")
            cleanup(conn)
            return
        }
        if let data, !data.isEmpty {
            sessions[key]?.buffer.append(data)
        }
        if isComplete {
            Log.server.info("对端关闭写入（EOF）: \(conn.endpointDescription)")
            cleanup(conn)
            return
        }

        processData(conn)
        if sessions[key] != nil {
            receive(conn)
        }
    }

    private func processData(_ conn: NWConnection) {
        guard let session = sessions[ObjectIdentifier(conn)] else { return }
        switch session.mode {
        case .http:
            processHTTP(conn, session)
        case .websocket:
            processWS(conn, session)
        case .live:
            // 取景流方向是服务端→客户端；客户端不该发数据，丢弃防缓冲膨胀
            if !session.buffer.isEmpty {
                Log.server.debug("MJPEG 连接上收到客户端数据 \(session.buffer.count) 字节，丢弃")
                session.buffer.removeAll()
            }
        }
    }

    // MARK: - HTTP 路由

    private func processHTTP(_ conn: NWConnection, _ session: ClientSession) {
        switch HTTPParser.parse(session.buffer) {
        case .incomplete:
            return   // 头部/身体没收全，继续等
        case .invalid:
            Log.server.warn("HTTP 请求解析失败 → 400")
            send(conn, HTTPResponse.badRequest("请求格式错误"), thenCancel: true)
            cleanup(conn, cancelConnection: false)
        case .request(let req, let consumed):
            session.buffer.removeFirst(consumed)
            route(conn, session, req)
        }
    }

    private func route(_ conn: NWConnection, _ session: ClientSession, _ req: HTTPRequest) {
        let queryDesc = req.query.map { "?\($0)" } ?? ""
        Log.server.info("请求路由: \(req.method) \(req.path)\(queryDesc)")

        switch (req.method, req.path) {
        case ("GET", "/"):
            // iPad 单页应用（HTML+CSS+JS 全内嵌）
            send(conn, HTTPResponse.ok(contentType: "text/html; charset=utf-8",
                                       body: Data(WebAssets.indexHTML.utf8)), thenCancel: true)

        case ("GET", "/live"):
            // MJPEG 取景流：响应头发完保持连接，后续 pushLiveViewFrame 追加分片
            session.mode = .live
            send(conn, HTTPResponse.liveStreamHead())
            Log.server.info("MJPEG 取景流开始（\(conn.endpointDescription)）")

        case ("GET", "/gallery"):
            // iPad 独立相册页（浏览 / 下载历史成片）
            send(conn, HTTPResponse.ok(contentType: "text/html; charset=utf-8",
                                       body: Data(WebAssets.galleryHTML.utf8)), thenCancel: true)

        case ("GET", "/slideshow"):
            // iPad 独立放映页（全屏轮播历史成片，秒间隔跟随配置）
            let html = WebAssets.slideshowHTML(intervalSec: max(2, conf.capture.idleSlideshowSec))
            send(conn, HTTPResponse.ok(contentType: "text/html; charset=utf-8",
                                       body: Data(html.utf8)), thenCancel: true)

        case ("GET", "/api/photos"):
            serveHistoryList(conn)

        case ("GET", "/ws"):
            upgradeWebSocket(conn, session, req)

        case ("GET", let p) where p.hasPrefix("/photo/history/"):
            serveHistoryPhoto(conn, String(p.dropFirst("/photo/history/".count)))

        case ("GET", let p) where p.hasPrefix("/photo/"):
            servePhoto(conn, String(p.dropFirst("/photo/".count)))

        case ("GET", let p) where p.hasPrefix("/theme/icon/"):
            serveThemeIcon(conn, String(p.dropFirst("/theme/icon/".count)))

        default:
            Log.server.warn("未知路由 \(req.method) \(req.path) → 404")
            send(conn, HTTPResponse.notFound(), thenCancel: true)
        }
    }

    /// 主题图标：/theme/icon/<key>.png（key 仅限映射表内的语义名，防路径穿越）
    private func serveThemeIcon(_ conn: NWConnection, _ rawKey: String) {
        let key = rawKey.lowercased().hasSuffix(".png") ? String(rawKey.dropLast(4)) : rawKey
        let valid = key.allSatisfy { $0.isLetter && $0.isASCII || $0 == "-" }
        guard valid, let data = ThemeIcons.data(for: key) else {
            Log.server.warn("主题图标不存在: \(rawKey) → 404")
            send(conn, HTTPResponse.notFound(), thenCancel: true)
            return
        }
        send(conn, HTTPResponse.ok(contentType: "image/png", body: data), thenCancel: true)
    }

    private func servePhoto(_ conn: NWConnection, _ rawID: String) {
        // 兼容带 .jpg 后缀的写法
        let idStr = rawID.lowercased().hasSuffix(".jpg") ? String(rawID.dropLast(4)) : rawID
        guard let id = UUID(uuidString: idStr), let url = photos[id] else {
            Log.server.warn("照片未注册: \(rawID) → 404")
            send(conn, HTTPResponse.notFound(), thenCancel: true)
            return
        }
        do {
            let data = try Data(contentsOf: url)
            send(conn, HTTPResponse.ok(contentType: "image/jpeg", body: data), thenCancel: true)
            Log.server.info("提供照片 \(id)（\(data.count) 字节）")
        } catch {
            Log.server.error("读取照片文件失败 \(url.path): \(error)")
            send(conn, HTTPResponse.notFound(), thenCancel: true)
        }
    }

    // MARK: - 历史成片（gallery / slideshow）

    /// 历史成片条目：只描述磁盘目录，不占内存位图
    struct HistoryPhoto: Sendable {
        let date: String      // yyyy-MM-dd
        let session: String   // HHmmss-短id
        var url: String { "/photo/history/\(date)/\(session)" }
    }

    /// 扫描 sessions/ 目录找最近有成片的会话（按目录名即时间排序，新→旧）
    private func listHistoryPhotos(limit: Int = 50) -> [HistoryPhoto] {
        if let cache = historyCache, let at = historyCacheAt,
           Date().timeIntervalSince(at) < 30 {
            return Array(cache.prefix(limit))
        }
        let fm = FileManager.default
        let sessionsRoot = BoothPaths.sessionsDir
        guard let days = try? fm.contentsOfDirectory(at: sessionsRoot, includingPropertiesForKeys: [.isDirectoryKey])
            .filter({ (try? $0.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) == true }) else {
            historyCache = []; historyCacheAt = Date()
            return []
        }
        var result: [HistoryPhoto] = []
        // 日目录名即 yyyy-MM-dd，倒序即时间新→旧
        for dayDir in days.sorted(by: { $0.lastPathComponent > $1.lastPathComponent }) {
            let day = dayDir.lastPathComponent
            guard let sessions = try? fm.contentsOfDirectory(at: dayDir, includingPropertiesForKeys: [.isDirectoryKey])
                .filter({ (try? $0.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) == true }) else { continue }
            for sessionDir in sessions.sorted(by: { $0.lastPathComponent > $1.lastPathComponent }) {
                // 有 display.jpg 才算有效会话（成片落盘过）
                guard fm.fileExists(atPath: sessionDir.appendingPathComponent("display.jpg").path) else { continue }
                result.append(HistoryPhoto(date: day, session: sessionDir.lastPathComponent))
                if result.count >= limit { break }
            }
            if result.count >= limit { break }
        }
        historyCache = result
        historyCacheAt = Date()
        Log.server.info("历史成片扫描：\(result.count) 个会话（根 \(sessionsRoot.path)）")
        return result
    }

    /// GET /api/photos：[{url, date, session}, ...]
    private func serveHistoryList(_ conn: NWConnection) {
        let items = listHistoryPhotos(limit: 50).map { photo -> [String: String] in
            ["url": photo.url, "date": photo.date, "session": photo.session]
        }
        let obj: [String: Any] = ["photos": items]
        guard let data = try? JSONSerialization.data(withJSONObject: obj, options: [.sortedKeys]) else {
            send(conn, HTTPResponse.ok(contentType: "application/json", body: Data("{\"photos\":[]}".utf8)), thenCancel: true)
            return
        }
        send(conn, HTTPResponse.ok(contentType: "application/json", body: data), thenCancel: true)
    }

    /// GET /photo/history/{date}/{session}：直接从磁盘读 display.jpg（30s 缓存之外也不依赖注册表）
    private func serveHistoryPhoto(_ conn: NWConnection, _ rawPath: String) {
        // 严格校验路径段格式，防目录穿越（只允许 日期/会话名 两段）
        let parts = rawPath.split(separator: "/").map(String.init)
        guard parts.count == 2,
              parts[0].range(of: "^\\d{4}-\\d{2}-\\d{2}$", options: .regularExpression) != nil,
              parts[1].range(of: "^[0-9a-zA-Z-]+$", options: .regularExpression) != nil else {
            Log.server.warn("历史成片路径非法: \(rawPath) → 404")
            send(conn, HTTPResponse.notFound(), thenCancel: true)
            return
        }
        let url = BoothPaths.sessionsDir.appendingPathComponent(parts[0], isDirectory: true)
            .appendingPathComponent(parts[1], isDirectory: true)
            .appendingPathComponent("display.jpg")
        do {
            let data = try Data(contentsOf: url)
            send(conn, HTTPResponse.ok(contentType: "image/jpeg", body: data), thenCancel: true)
            Log.server.info("提供历史成片 \(parts[0])/\(parts[1])（\(data.count) 字节）")
        } catch {
            send(conn, HTTPResponse.notFound(), thenCancel: true)
        }
    }

    // MARK: - WebSocket

    private func upgradeWebSocket(_ conn: NWConnection, _ session: ClientSession, _ req: HTTPRequest) {
        let wantsUpgrade = (req.headers["connection"] ?? "").lowercased().contains("upgrade")
            && (req.headers["upgrade"] ?? "").lowercased() == "websocket"
        guard wantsUpgrade, let key = req.headers["sec-websocket-key"], !key.isEmpty else {
            Log.server.warn("WS 握手缺少 Upgrade/Sec-WebSocket-Key 头 → 400")
            send(conn, HTTPResponse.badRequest("需要 WebSocket 升级请求"), thenCancel: true)
            return
        }
        let accept = WSCodec.acceptValue(for: key)
        session.mode = .websocket
        send(conn, HTTPResponse.switchingProtocols(accept: accept))
        Log.server.info("WebSocket 握手成功（\(conn.endpointDescription)，accept=\(accept)）")

        // 新客户端立即同步当前状态（重连/晚加入不丢屏）
        if let state = lastState {
            sendState(conn, state)
        }
    }

    private func processWS(_ conn: NWConnection, _ session: ClientSession) {
        while sessions[ObjectIdentifier(conn)] != nil {
            let frame: WSFrame
            let consumed: Int
            do {
                let (f, c) = try WSCodec.decode(session.buffer, requireMask: true)
                frame = f
                consumed = c
            } catch let e as WSError {
                switch e {
                case .incomplete:
                    return   // 帧没收全，等下一包
                case .protocolViolation(let reason):
                    Log.server.warn("WS 协议违规（\(conn.endpointDescription)）: \(reason)，回 1002 关闭")
                    sendClose(conn, code: 1002, reason: reason)
                    return
                }
            } catch {
                Log.server.warn("WS 解帧未知错误: \(error)")
                return
            }
            session.buffer.removeFirst(consumed)
            handleFrame(conn, session, frame)
        }
    }

    private func handleFrame(_ conn: NWConnection, _ session: ClientSession, _ frame: WSFrame) {
        switch frame.opcode {
        case WSOpcode.ping:
            // 心跳：ping → pong
            Log.server.debug("WS ping（\(frame.payload.count) 字节）→ pong")
            send(conn, WSCodec.encode(opcode: WSOpcode.pong, payload: frame.payload))

        case WSOpcode.pong:
            break   // 心跳回包，忽略

        case WSOpcode.close:
            let code = closeCode(frame.payload)
            Log.server.info("客户端请求关闭 WS（code=\(code)，\(conn.endpointDescription)）")
            // 回 close 帧后断开（RFC 正常关闭流程）
            sendClose(conn, code: code, reason: "")
            return

        case WSOpcode.text:
            if frame.fin {
                handleTextMessage(conn, session, String(data: frame.payload, encoding: .utf8) ?? "")
            } else {
                // 分片首帧：开始重组
                session.fragments = frame.payload
                session.fragmentOpcode = frame.opcode
            }

        case WSOpcode.binary:
            Log.server.warn("收到 binary 消息（\(frame.payload.count) 字节），忽略")
            if !frame.fin {
                session.fragments = frame.payload
                session.fragmentOpcode = frame.opcode
            }

        case WSOpcode.continuation:
            // 分片延续帧
            session.fragments.append(frame.payload)
            if frame.fin {
                let op = session.fragmentOpcode ?? WSOpcode.text
                let message = session.fragments
                session.fragments.removeAll()
                session.fragmentOpcode = nil
                if op == WSOpcode.text {
                    handleTextMessage(conn, session, String(data: message, encoding: .utf8) ?? "")
                } else {
                    Log.server.warn("分片 binary 消息重组完成，忽略")
                }
            }

        default:
            Log.server.warn("未知 WS opcode: \(frame.opcode)")
        }
    }

    /// 处理一条完整文本消息（JSON 指令）；非法 JSON 记 warn 不崩。
    /// 指令限速：5 秒窗口内超过 12 条 → 判定为脚本刷指令，断开连接
    private func handleTextMessage(_ conn: NWConnection, _ session: ClientSession, _ text: String) {
        let key = ObjectIdentifier(conn)
        guard sessions[key] != nil else { return }
        let now = Date()
        session.commandTimes.removeAll { now.timeIntervalSince($0) > 5 }
        session.commandTimes.append(now)
        if session.commandTimes.count > 12 {
            Log.server.warn("WS 指令限速触发（5 秒内 \(session.commandTimes.count) 条），断开连接")
            sendClose(conn, code: 1008, reason: "指令过于频繁")
            return
        }
        Log.server.info("WS 收到消息: \(text.prefix(200))")
        guard let data = text.data(using: .utf8),
              let obj = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any] else {
            Log.server.warn("非法 JSON，忽略: \(text.prefix(100))")
            return
        }
        switch obj["type"] as? String {
        case "print":
            var copies = obj["copies"] as? Int ?? conf.printing.defaultCopies
            copies = min(max(copies, conf.printing.minCopies), conf.printing.maxCopies)
            Log.server.info("iPad 指令: 打印 \(copies) 张")
            commandHub.yield(.confirmPrint(copies: copies))

        case "retake":
            Log.server.info("iPad 指令: 重拍")
            commandHub.yield(.retake)

        case "mode":
            switch obj["kind"] as? String {
            case "single":
                Log.server.info("iPad 指令: 选择单张模式")
                commandHub.yield(.selectMode(.single))
            case "collage":
                let shots = obj["shots"] as? Int ?? conf.capture.defaultMode.shots
                let layout = CollageLayout(rawValue: (obj["layout"] as? String) ?? "")
                    ?? conf.capture.defaultMode.layout
                Log.server.info("iPad 指令: 选择拼版模式（\(shots) 张，\(layout.rawValue)）")
                commandHub.yield(.selectMode(.collage(shots, layout: layout)))
            default:
                Log.server.warn("mode 指令 kind 非法: \(obj["kind"] ?? "nil")")
            }

        case "filter":
            // REVIEW 态换滤镜（拍后自选）：{"type":"filter","filter":"vivid"}
            let filter = PhotoFilter.parse(obj["filter"] as? String)
            Log.server.info("iPad 指令: 选择滤镜 \(filter.rawValue)")
            commandHub.yield(.selectFilter(filter))

        default:
            Log.server.warn("未知指令类型: \(obj["type"] ?? "nil")，忽略")
        }
    }

    // MARK: - 状态编码

    /// BoothState → iPad 协议 JSON
    private func stateJSON(_ state: BoothState) -> String {
        var obj: [String: Any] = ["type": "state"]
        switch state {
        case .idle:
            obj["state"] = "idle"
        case .armed:
            obj["state"] = "armed"
        case .gestureWait:
            obj["state"] = "gestureWait"
        case .countdown(let secondsLeft):
            obj["state"] = "countdown"
            obj["secondsLeft"] = secondsLeft
        case .capturing(let shot, let of):
            obj["state"] = "capturing"
            obj["shot"] = shot
            obj["of"] = of
        case .processing:
            obj["state"] = "processing"
        case .review(let photo):
            obj["state"] = "review"
            obj["photoId"] = photo.id.uuidString
            obj["copies"] = conf.printing.defaultCopies   // iPad 步进器默认份数
            // 打印按钮可见性 / 滤镜选择条开关（PhotoBoothProject 借鉴）
            obj["showPrint"] = conf.printing.showPrintButton
            if conf.imaging.filterSelection {
                obj["filters"] = PhotoFilter.allCases.map { ["id": $0.rawValue, "name": $0.displayName] }
            }
        case .printing(let copies):
            obj["state"] = "printing"
            obj["copies"] = copies
        case .failure(let message):
            obj["state"] = "failure"
            obj["message"] = message
        }
        if let data = try? JSONSerialization.data(withJSONObject: obj, options: [.sortedKeys]),
           let json = String(data: data, encoding: .utf8) {
            return json
        }
        return "{\"state\":\"idle\",\"type\":\"state\"}"
    }

    private func sendState(_ conn: NWConnection, _ state: BoothState) {
        send(conn, WSCodec.encode(opcode: WSOpcode.text, payload: Data(stateJSON(state).utf8)))
    }

    // MARK: - 发送与清理

    private func send(_ conn: NWConnection, _ data: Data, thenCancel: Bool = false) {
        if thenCancel {
            // isComplete=true：数据写完即结束写侧（发 FIN），完成后再 cancel 清理
            conn.send(content: data, contentContext: .defaultMessage, isComplete: true,
                      completion: .contentProcessed { _ in conn.cancel() })
        } else {
            conn.send(content: data, completion: .contentProcessed { _ in })
        }
    }

    /// 从 close 帧载荷解析状态码（前 2 字节大端；缺省 1000 正常关闭）
    private func closeCode(_ payload: Data) -> Int {
        let b = [UInt8](payload.prefix(2))
        guard b.count == 2 else { return 1000 }
        return (Int(b[0]) << 8) | Int(b[1])
    }

    private func sendClose(_ conn: NWConnection, code: Int, reason: String) {
        var payload = Data([UInt8((code >> 8) & 0xFF), UInt8(code & 0xFF)])
        payload.append(Data(reason.utf8))
        // 先回 close 帧，发送完成后再断开，并移除会话
        send(conn, WSCodec.encode(opcode: WSOpcode.close, payload: payload), thenCancel: true)
        cleanup(conn, cancelConnection: false)
    }

    private func cleanup(_ conn: NWConnection, cancelConnection: Bool = true) {
        let key = ObjectIdentifier(conn)
        guard let session = sessions.removeValue(forKey: key) else { return }
        if cancelConnection { conn.cancel() }
        let label: String
        switch session.mode {
        case .http: label = "HTTP"
        case .live: label = "MJPEG 取景"
        case .websocket: label = "WebSocket"
        }
        Log.server.info("连接关闭（\(label)，\(conn.endpointDescription)，剩余 \(sessions.count) 个）")
    }
}

// MARK: - NWConnection 便利描述

extension NWConnection {
    /// 日志用的端点描述
    var endpointDescription: String {
        if case let NWEndpoint.hostPort(host, port) = endpoint {
            return "\(host):\(port)"
        }
        return String(describing: endpoint)
    }
}
