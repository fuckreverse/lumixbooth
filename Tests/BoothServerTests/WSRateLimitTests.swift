import XCTest
import Foundation
import BoothCore
@testable import BoothServer

// ============================================================
// WS 指令限速集成测试（防脚本刷 print/retake）：
// 5 秒窗口内超过 12 条文本指令 → 服务端回 1008 关闭并断开
// ============================================================

final class WSRateLimitTests: XCTestCase {

    private func makeConf() -> BoothConfig {
        var conf = BoothConfig()
        conf.server.port = 0
        return conf
    }

    /// 建立 WS 连接（握手完成即返回）
    private func connectWS(port: UInt16) async throws -> RawTCPClient {
        let client = RawTCPClient(port: port)
        try await client.connect()
        let request = "GET /ws HTTP/1.1\r\nHost: 127.0.0.1\r\nUpgrade: websocket\r\n"
            + "Connection: Upgrade\r\nSec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ==\r\n"
            + "Sec-WebSocket-Version: 13\r\n\r\n"
        client.send(Data(request.utf8))
        let handshake = String(decoding: try await withTimeout {
            try await client.read(until: Data("\r\n\r\n".utf8))
        }, as: UTF8.self)
        XCTAssertTrue(handshake.contains("101"), "握手失败: \(handshake)")
        return client
    }

    func testNormalUsageNotRateLimited() async throws {
        let server = BoothWebService(conf: makeConf())
        try await server.start()
        defer { Task { await server.stop() } }

        actor CmdBox {
            var items: [iPadCommand] = []
            func add(_ c: iPadCommand) { items.append(c) }
            var all: [iPadCommand] { items }
        }
        let box = CmdBox()
        let pump = Task { for await c in server.commands { await box.add(c) } }
        defer { pump.cancel() }

        let client = try await connectWS(port: server.port)

        // 正常节奏发 10 条（低于阈值 12）→ 全部收到，连接不断
        for _ in 0..<10 {
            client.send(TestWS.maskedFrame(opcode: 0x1, payload: Data(#"{"type":"retake"}"#.utf8)))
            try await Task.sleep(nanoseconds: 100_000_000)   // 100ms/条，模拟人手
        }
        try await Task.sleep(nanoseconds: 400_000_000)
        let all = await box.all
        XCTAssertEqual(all.count, 10, "正常速率指令不应被丢弃")
    }

    func testFloodTriggersClose1008() async throws {
        let server = BoothWebService(conf: makeConf())
        try await server.start()
        defer { Task { await server.stop() } }

        let client = try await connectWS(port: server.port)

        // 15 条指令瞬间灌入 → 超过 12 条阈值，服务端应回 close(1008)
        for _ in 0..<15 {
            client.send(TestWS.maskedFrame(opcode: 0x1, payload: Data(#"{"type":"retake"}"#.utf8)))
        }

        // 读帧直到收到 close 帧（opcode 0x8），载荷前两字节 = 1008 (0x03E8)
        var gotClose = false
        for _ in 0..<20 {
            guard let frame = try? await withTimeout(seconds: 3, {
                try await TestWS.readServerFrame(client)
            }) else { break }
            if frame.opcode == 0x8 {
                let code = ([UInt8](frame.payload.prefix(2))).reduce(0) { ($0 << 8) | Int($1) }
                XCTAssertEqual(code, 1008, "应以 1008 Policy Violation 关闭")
                gotClose = true
                break
            }
        }
        XCTAssertTrue(gotClose, "刷指令应被限速断开")
    }
}
