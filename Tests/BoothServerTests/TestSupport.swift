import Foundation
import Network

// ============================================================
// 测试支持：手写 TCP 客户端（HTTP 请求 / WS 握手 / 帧收发）
// 以及超时与轮询工具（防止用例挂死）
// ============================================================

/// 原始 TCP 客户端：按条件消费收包缓冲，支持 async/await
final class RawTCPClient: @unchecked Sendable {

    enum ClientError: Error { case closed }

    private let conn: NWConnection
    private let queue = DispatchQueue(label: "booth.testclient")
    private let lock = NSLock()
    private var buffer = Data()
    private var closed = false
    private var readyCont: CheckedContinuation<Void, Error>?
    /// 等待数据的读者：闭包尝试从缓冲消费，返回 nil 表示数据不够继续等
    private var waiters: [(tryConsume: (inout Data) -> Data?, cont: CheckedContinuation<Data, Error>)] = []

    init(port: UInt16) {
        conn = NWConnection(host: "127.0.0.1",
                            port: NWEndpoint.Port(rawValue: port) ?? .any,
                            using: .tcp)
    }

    /// 连接（等待 ready，带超时防挂死）
    func connect(timeout seconds: Double = 5) async throws {
        try await withTimeout(seconds: seconds) {
            try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Void, Error>) in
                self.beginConnect(cont)
            }
        }
    }

    /// 同步上下文里完成连接初始化（NSLock 在 async 上下文不可用，收敛到同步方法）
    private func beginConnect(_ cont: CheckedContinuation<Void, Error>) {
        lock.lock()
        readyCont = cont
        lock.unlock()
        conn.stateUpdateHandler = { [weak self] state in
            guard let self else { return }
            switch state {
            case .ready:
                self.resumeReady(nil)
            case .failed(let error):
                self.resumeReady(error)
            case .cancelled:
                self.resumeReady(ClientError.closed)
            default:
                break
            }
        }
        conn.start(queue: queue)
        receiveNext()
    }

    private func resumeReady(_ error: Error?) {
        lock.lock()
        let c = readyCont
        readyCont = nil
        lock.unlock()
        if let error { c?.resume(throwing: error) } else { c?.resume() }
    }

    private func receiveNext() {
        conn.receive(minimumIncompleteLength: 1, maximumLength: 1 << 20) { [weak self] data, _, isComplete, error in
            guard let self else { return }
            if let data, !data.isEmpty { self.append(data) }
            if isComplete || error != nil { self.finish() } else { self.receiveNext() }
        }
    }

    private func append(_ data: Data) {
        lock.lock()
        buffer.append(data)
        // 尝试唤醒能满足的读者
        var pending: [(tryConsume: (inout Data) -> Data?, cont: CheckedContinuation<Data, Error>)] = []
        for w in waiters {
            if let chunk = w.tryConsume(&buffer) {
                w.cont.resume(returning: chunk)
            } else {
                pending.append(w)
            }
        }
        waiters = pending
        lock.unlock()
    }

    private func finish() {
        lock.lock()
        closed = true
        let ws = waiters
        waiters = []
        lock.unlock()
        for w in ws { w.cont.resume(throwing: ClientError.closed) }
    }

    /// 发送数据（立即返回，不等待对端确认）
    func send(_ data: Data) {
        conn.send(content: data, completion: .contentProcessed { _ in })
    }

    /// 读到 marker（含 marker 本身）为止
    func read(until marker: Data) async throws -> Data {
        try await read { buf in
            guard let r = buf.range(of: marker) else { return nil }
            let chunk = buf.subdata(in: buf.startIndex..<r.upperBound)
            buf.removeSubrange(buf.startIndex..<r.upperBound)
            return chunk
        }
    }

    /// 读满 n 字节
    func read(_ n: Int) async throws -> Data {
        try await read { buf in
            guard buf.count >= n else { return nil }
            let chunk = buf.prefix(n)
            buf.removeFirst(n)
            return Data(chunk)
        }
    }

    private func read(_ tryConsume: @escaping (inout Data) -> Data?) async throws -> Data {
        // 先同步尝试消费（锁操作收敛在同步方法里）
        if let chunk = try syncConsume(tryConsume) { return chunk }
        return try await withCheckedThrowingContinuation { cont in
            registerWaiter(tryConsume, cont)
        }
    }

    /// 同步尝试消费缓冲；返回 nil 表示数据不够
    private func syncConsume(_ f: (inout Data) -> Data?) throws -> Data? {
        lock.lock(); defer { lock.unlock() }
        if closed { throw ClientError.closed }
        return f(&buffer)
    }

    /// 登记等待者；持锁期间再尝试消费一次（消除「同步尝试失败 → 登记之间数据到达」的窗口死锁）
    private func registerWaiter(_ f: @escaping (inout Data) -> Data?,
                                _ cont: CheckedContinuation<Data, Error>) {
        lock.lock()
        if closed {
            lock.unlock()
            cont.resume(throwing: ClientError.closed)
            return
        }
        if let chunk = f(&buffer) {
            lock.unlock()
            cont.resume(returning: chunk)
            return
        }
        waiters.append((f, cont))
        lock.unlock()
    }
}

// MARK: - WS 测试帧工具

enum TestWS {

    /// 构造客户端→服务端的掩码帧（RFC 规定客户端帧必带 mask）
    static func maskedFrame(opcode: UInt8, payload: Data) -> Data {
        let mask: [UInt8] = [0xA7, 0x31, 0x5C, 0xE9]
        var out = Data([0x80 | opcode])
        let len = payload.count
        if len < 126 {
            out.append(UInt8(0x80 | len))
        } else if len <= 0xFFFF {
            out.append(UInt8(0x80 | 126))
            out.append(UInt8((len >> 8) & 0xFF))
            out.append(UInt8(len & 0xFF))
        } else {
            out.append(UInt8(0x80 | 127))
            for s in stride(from: 56, through: 0, by: -8) {
                out.append(UInt8((len >> s) & 0xFF))
            }
        }
        out.append(contentsOf: mask)
        let bytes = [UInt8](payload)
        for i in 0..<bytes.count { out.append(bytes[i] ^ mask[i & 3]) }
        return out
    }

    /// 读一个服务端帧（不掩码），返回 (opcode, payload)
    static func readServerFrame(_ client: RawTCPClient) async throws -> (opcode: UInt8, payload: Data) {
        let head = [UInt8](try await client.read(2))
        let opcode = head[0] & 0x0F
        var len = Int(head[1] & 0x7F)
        if len == 126 {
            let ext = [UInt8](try await client.read(2))
            len = (Int(ext[0]) << 8) | Int(ext[1])
        } else if len == 127 {
            let ext = [UInt8](try await client.read(8))
            len = ext.reduce(0) { ($0 << 8) | Int($1) }
        }
        let payload = try await client.read(len)
        return (opcode, payload)
    }
}

// MARK: - 超时与轮询

struct TimeoutError: Error {}

/// 竞速超时：防测试挂死（BoothServer 模块的 withTimeout 是 internal，测试自带一份）
func withTimeout<T: Sendable>(seconds: Double = 5, _ op: @escaping @Sendable () async throws -> T) async throws -> T {
    try await withThrowingTaskGroup(of: T.self) { group in
        group.addTask { try await op() }
        group.addTask {
            try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
            throw TimeoutError()
        }
        guard let first = try await group.next() else { throw TimeoutError() }
        group.cancelAll()
        return first
    }
}

/// 轮询等待条件成立（50ms 步进）
func waitUntil(seconds: Double = 5, _ cond: @escaping @Sendable () async -> Bool) async throws {
    let deadline = Date().addingTimeInterval(seconds)
    while Date() < deadline {
        if await cond() { return }
        try await Task.sleep(nanoseconds: 50_000_000)
    }
    throw TimeoutError()
}
