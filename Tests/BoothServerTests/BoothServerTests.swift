import XCTest
import Foundation
import CoreGraphics
import ImageIO
import UniformTypeIdentifiers
import BoothCore
@testable import BoothServer

// ============================================================
// BoothServer 集成测试：port=0 起真实服务，localhost 打通
//  - HTTP：GET / 返回单页应用；GET /photo/{id} 注册前后 404/200
//  - WS：手写客户端完成 RFC6455 握手；验证状态广播 JSON、指令上行
//  - MJPEG：GET /live 后 pushLiveViewFrame 收到 multipart 分片
// ============================================================

final class BoothServerTests: XCTestCase {

    /// 测试配置：端口 0（系统分配），方便并行与重复运行
    private func makeConf(ipadMaxFPS: Int = 10) -> BoothConfig {
        var conf = BoothConfig()
        conf.server.port = 0
        conf.server.ipadMaxFPS = ipadMaxFPS
        return conf
    }

    /// 生成一张临时 JPEG 文件（32×32 纯色），返回 (URL, 字节)
    private func makeTempJPEG() throws -> (url: URL, data: Data) {
        let size = 32
        let ctx = CGContext(data: nil, width: size, height: size, bitsPerComponent: 8,
                            bytesPerRow: 0, space: CGColorSpaceCreateDeviceRGB(),
                            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
        ctx.setFillColor(CGColor(red: 1.0, green: 0.56, blue: 0.67, alpha: 1.0))
        ctx.fill(CGRect(x: 0, y: 0, width: size, height: size))
        let image = ctx.makeImage()!

        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("booth-test-\(UUID().uuidString).jpg")
        let data = NSMutableData()
        let dest = CGImageDestinationCreateWithData(data, UTType.jpeg.identifier as CFString, 1, nil)!
        CGImageDestinationAddImage(dest, image,
                                   [kCGImageDestinationLossyCompressionQuality: 0.8] as CFDictionary)
        XCTAssertTrue(CGImageDestinationFinalize(dest), "JPEG 编码失败")
        try (data as Data).write(to: url)
        return (url, data as Data)
    }

    // MARK: - HTTP 端点

    func testHTTPEndpoints() async throws {
        let server = BoothWebService(conf: makeConf())
        try await server.start()
        let port = server.port
        XCTAssertGreaterThan(port, 0, "port=0 时应从 listener 读出系统分配端口")
        defer { Task { await server.stop() } }

        // GET / → 200 + 单页应用 HTML
        let (htmlData, resp) = try await URLSession.shared.data(from: URL(string: "http://127.0.0.1:\(port)/")!)
        XCTAssertEqual((resp as? HTTPURLResponse)?.statusCode, 200)
        let html = String(decoding: htmlData, as: UTF8.self)
        XCTAssertTrue(html.contains("LUMIX"), "应包含应用标题")
        XCTAssertTrue(html.contains("/live"), "应包含 LiveView 小窗")
        XCTAssertTrue(html.contains("/ws"), "应包含 WebSocket 连接逻辑")
        XCTAssertTrue((resp as? HTTPURLResponse)?.value(forHTTPHeaderField: "Content-Type")?.contains("text/html") == true)

        // 未注册照片 → 404
        let (_, resp404) = try await URLSession.shared.data(
            from: URL(string: "http://127.0.0.1:\(port)/photo/\(UUID().uuidString)")!)
        XCTAssertEqual((resp404 as? HTTPURLResponse)?.statusCode, 404)

        // publishPhoto 之后 → 200 + JPEG 字节一致
        let jpeg = try makeTempJPEG()
        defer { try? FileManager.default.removeItem(at: jpeg.url) }
        let photo = ProcessedPhoto(id: UUID(), printFile: jpeg.url, displayFile: jpeg.url, originals: [jpeg.url])
        await server.publishPhoto(photo)
        let (photoData, respPhoto) = try await URLSession.shared.data(
            from: URL(string: "http://127.0.0.1:\(port)/photo/\(photo.id.uuidString)")!)
        XCTAssertEqual((respPhoto as? HTTPURLResponse)?.statusCode, 200)
        XCTAssertEqual((respPhoto as? HTTPURLResponse)?.value(forHTTPHeaderField: "Content-Type"), "image/jpeg")
        XCTAssertEqual(photoData, jpeg.data, "下载字节应与磁盘文件逐字节一致")

        // stop 幂等
        await server.stop()
        await server.stop()
    }

    // MARK: - WebSocket 协议

    func testWebSocketProtocol() async throws {
        let server = BoothWebService(conf: makeConf())
        try await server.start()
        defer { Task { await server.stop() } }

        // 指令流订阅（SessionEngine 视角）
        actor CmdBox {
            var items: [iPadCommand] = []
            func add(_ c: iPadCommand) { items.append(c) }
            var all: [iPadCommand] { items }
        }
        let box = CmdBox()
        let pump = Task { for await c in server.commands { await box.add(c) } }
        defer { pump.cancel() }

        // ---- 握手（RFC6455 例值 key → 期望 accept）----
        let client = RawTCPClient(port: server.port)
        try await client.connect()
        let key = "dGhlIHNhbXBsZSBub25jZQ=="
        let request = "GET /ws HTTP/1.1\r\nHost: 127.0.0.1\r\nUpgrade: websocket\r\n"
            + "Connection: Upgrade\r\nSec-WebSocket-Key: \(key)\r\nSec-WebSocket-Version: 13\r\n\r\n"
        client.send(Data(request.utf8))
        let handshake = String(decoding: try await withTimeout {
            try await client.read(until: Data("\r\n\r\n".utf8))
        }, as: UTF8.self)
        XCTAssertTrue(handshake.contains("101"), "应为 101 Switching Protocols: \(handshake)")
        XCTAssertTrue(handshake.contains("Sec-WebSocket-Accept: s3pPLMBiTxaQ9kYGzzhZRbK+xOo="),
                      "Accept 应为 RFC6455 例值: \(handshake)")

        // ---- 服务端广播 state → 客户端收到 JSON ----
        await server.broadcast(state: .countdown(secondsLeft: 3))
        var frame = try await withTimeout { try await TestWS.readServerFrame(client) }
        XCTAssertEqual(frame.opcode, 0x1, "应为文本帧")
        var obj = try XCTUnwrap(JSONSerialization.jsonObject(with: frame.payload) as? [String: Any])
        XCTAssertEqual(obj["type"] as? String, "state")
        XCTAssertEqual(obj["state"] as? String, "countdown")
        XCTAssertEqual(obj["secondsLeft"] as? Int, 3)

        // ---- 非法 JSON：记 warn 不崩 ----
        client.send(TestWS.maskedFrame(opcode: 0x1, payload: Data("不是JSON".utf8)))
        try await Task.sleep(nanoseconds: 200_000_000)

        // ---- iPad 指令上行：print / retake / mode ----
        client.send(TestWS.maskedFrame(opcode: 0x1, payload: Data(#"{"type":"print","copies":2}"#.utf8)))
        try await waitUntil { await box.all.count >= 1 }
        let c0 = await box.all.first
        XCTAssertEqual(c0, .confirmPrint(copies: 2))

        client.send(TestWS.maskedFrame(opcode: 0x1, payload: Data(#"{"type":"retake"}"#.utf8)))
        try await waitUntil { await box.all.count >= 2 }
        let all12 = await box.all
        XCTAssertEqual(all12.count >= 2 ? all12[1] : nil, .retake)

        client.send(TestWS.maskedFrame(opcode: 0x1,
                                        payload: Data(#"{"type":"mode","kind":"collage","shots":4}"#.utf8)))
        try await waitUntil { await box.all.count >= 3 }
        let all123 = await box.all
        XCTAssertEqual(all123.count >= 3 ? all123[2] : nil, .selectMode(.collage(4)))

        // ---- 非法 JSON 后服务仍存活：能继续广播 ----
        await server.broadcast(state: .idle)
        frame = try await withTimeout { try await TestWS.readServerFrame(client) }
        obj = try XCTUnwrap(JSONSerialization.jsonObject(with: frame.payload) as? [String: Any])
        XCTAssertEqual(obj["state"] as? String, "idle")

        // ---- ping → pong ----
        client.send(TestWS.maskedFrame(opcode: 0x9, payload: Data("hb".utf8)))
        frame = try await withTimeout { try await TestWS.readServerFrame(client) }
        XCTAssertEqual(frame.opcode, 0xA, "应回 pong")
        XCTAssertEqual(frame.payload, Data("hb".utf8))

        // ---- review 状态携带 photoId / copies ----
        let jpeg = try makeTempJPEG()
        defer { try? FileManager.default.removeItem(at: jpeg.url) }
        let photo = ProcessedPhoto(id: UUID(), printFile: jpeg.url, displayFile: jpeg.url, originals: [jpeg.url])
        await server.broadcast(state: .review(photo))
        frame = try await withTimeout { try await TestWS.readServerFrame(client) }
        obj = try XCTUnwrap(JSONSerialization.jsonObject(with: frame.payload) as? [String: Any])
        XCTAssertEqual(obj["state"] as? String, "review")
        XCTAssertEqual(obj["photoId"] as? String, photo.id.uuidString)
        XCTAssertEqual(obj["copies"] as? Int, 2, "默认份数应为 2")

        // ---- 客户端主动 close → 服务端回 close 帧后断开 ----
        client.send(TestWS.maskedFrame(opcode: 0x8, payload: Data([0x03, 0xE8])))
        frame = try await withTimeout { try await TestWS.readServerFrame(client) }
        XCTAssertEqual(frame.opcode, 0x8, "应回 close 帧")

        await server.stop()
    }

    // MARK: - MJPEG 取景流

    func testMJPEGLiveStream() async throws {
        // 5fps → 帧间隔 200ms，用于验证丢帧逻辑
        let server = BoothWebService(conf: makeConf(ipadMaxFPS: 5))
        try await server.start()
        defer { Task { await server.stop() } }

        let client = RawTCPClient(port: server.port)
        try await client.connect()
        client.send(Data("GET /live HTTP/1.1\r\nHost: 127.0.0.1\r\n\r\n".utf8))

        // 响应头：multipart 头 + 边界
        let head = String(decoding: try await withTimeout {
            try await client.read(until: Data("\r\n\r\n".utf8))
        }, as: UTF8.self)
        XCTAssertTrue(head.contains("200 OK"))
        XCTAssertTrue(head.contains("multipart/x-mixed-replace"), head)
        XCTAssertTrue(head.contains("boundary=booth"), head)

        // 帧内容（服务端不解析 JPEG 内容，构造可区分的假字节即可）
        let frame1 = Data((0..<600).map { UInt8($0 % 251) })
        let frame2 = Data((0..<700).map { UInt8(($0 + 7) % 251) })
        let frame3 = Data((0..<800).map { UInt8(($0 + 13) % 251) })

        // ---- 第一帧 ----
        await server.pushLiveViewFrame(frame1)
        let part1 = try await readMJPEGPart(client)
        XCTAssertEqual(part1.header.contains("--booth"), true)
        XCTAssertTrue(part1.header.contains("image/jpeg"))
        XCTAssertTrue(part1.header.contains("Content-Length: \(frame1.count)"))
        XCTAssertEqual(part1.body, frame1)

        // ---- 第二帧：在帧率窗口内推送应被丢弃（丢帧不排队）----
        await server.pushLiveViewFrame(frame2)
        // ---- 越过窗口后推第三帧：应收到第三帧而非排队的第二帧 ----
        try await Task.sleep(nanoseconds: 300_000_000)
        await server.pushLiveViewFrame(frame3)
        let part2 = try await readMJPEGPart(client)
        XCTAssertTrue(part2.header.contains("Content-Length: \(frame3.count)"))
        XCTAssertEqual(part2.body, frame3, "窗口内的第二帧应被丢弃，收到的是第三帧")

        await server.stop()
    }

    /// 读一个 multipart 分片：分隔符+头（到 \r\n\r\n）+ 精确字节数的 body + 结尾 \r\n
    private func readMJPEGPart(_ client: RawTCPClient) async throws -> (header: String, body: Data) {
        let header = String(decoding: try await withTimeout {
            try await client.read(until: Data("\r\n\r\n".utf8))
        }, as: UTF8.self)
        // 从头里取 Content-Length
        let length = header
            .components(separatedBy: "\r\n")
            .compactMap { line -> Int? in
                guard line.lowercased().hasPrefix("content-length:") else { return nil }
                return Int(line.split(separator: ":")[1].trimmingCharacters(in: .whitespaces))
            }.first
        let bodyLen = try XCTUnwrap(length, "分片头应含 Content-Length: \(header)")
        let body = try await withTimeout { try await client.read(bodyLen) }
        // 分片结尾的 \r\n（下一分片分隔符前）
        _ = try await withTimeout { try await client.read(2) }
        return (header, body)
    }

    // MARK: - filter 指令 + 新路由（PhotoBoothProject 借鉴）

    /// WS 指令上行：filter / mode 带 layout
    func testFilterAndModeLayoutCommands() async throws {
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

        let client = RawTCPClient(port: server.port)
        try await client.connect()

        // /ws 握手
        let key = "dGhlIHNhbXBsZSBub25jZQ=="
        let request = "GET /ws HTTP/1.1\r\nHost: 127.0.0.1\r\nUpgrade: websocket\r\n"
            + "Connection: Upgrade\r\nSec-WebSocket-Key: \(key)\r\nSec-WebSocket-Version: 13\r\n\r\n"
        client.send(Data(request.utf8))
        _ = String(decoding: try await withTimeout {
            try await client.read(until: Data("\r\n\r\n".utf8))
        }, as: UTF8.self)

        // filter 指令：合法值直传，非法值安全回退 none
        client.send(TestWS.maskedFrame(opcode: 0x1, payload: Data(#"{"type":"filter","filter":"vivid"}"#.utf8)))
        try await waitUntil { await box.all.count >= 1 }
        var all = await box.all
        XCTAssertEqual(all.first, .selectFilter(.vivid))

        client.send(TestWS.maskedFrame(opcode: 0x1, payload: Data(#"{"type":"filter","filter":"no-such"}"#.utf8)))
        try await waitUntil { await box.all.count >= 2 }
        all = await box.all
        XCTAssertEqual(all.count >= 2 ? all[1] : nil, .selectFilter(.none), "非法滤镜名应安全回退 .none")

        // mode 指令带 layout
        client.send(TestWS.maskedFrame(opcode: 0x1,
                                        payload: Data(#"{"type":"mode","kind":"collage","shots":4,"layout":"grid2x2"}"#.utf8)))
        try await waitUntil { await box.all.count >= 3 }
        all = await box.all
        XCTAssertEqual(all.count >= 3 ? all[2] : nil, .selectMode(.collage(4, layout: .grid2x2)))

        await server.stop()
    }

    /// /gallery /slideshow 页面 + review 状态广播携带 filters/showPrint
    func testGallerySlideshowPagesAndReviewPayload() async throws {
        var conf = makeConf()
        conf.printing.showPrintButton = false
        let server = BoothWebService(conf: conf)
        try await server.start()
        let port = server.port
        defer { Task { await server.stop() } }

        // /gallery：HTML 且带相册标题
        let (galleryData, galleryResp) = try await URLSession.shared.data(
            from: URL(string: "http://127.0.0.1:\(port)/gallery")!)
        XCTAssertEqual((galleryResp as? HTTPURLResponse)?.statusCode, 200)
        XCTAssertTrue(String(decoding: galleryData, as: UTF8.self).contains("相册"))

        // /slideshow：HTML 且注入了配置的轮播间隔
        let (slideshowData, slideshowResp) = try await URLSession.shared.data(
            from: URL(string: "http://127.0.0.1:\(port)/slideshow")!)
        XCTAssertEqual((slideshowResp as? HTTPURLResponse)?.statusCode, 200)
        let slideshowHTML = String(decoding: slideshowData, as: UTF8.self)
        XCTAssertTrue(slideshowHTML.contains("放映"))
        XCTAssertTrue(slideshowHTML.contains("INTERVAL"), "放映页应注入轮播间隔")

        // review 状态广播：带 showPrint=false + filters 列表
        let client = RawTCPClient(port: port)
        try await client.connect()
        let key = "dGhlIHNhbXBsZSBub25jZQ=="
        let request = "GET /ws HTTP/1.1\r\nHost: 127.0.0.1\r\nUpgrade: websocket\r\n"
            + "Connection: Upgrade\r\nSec-WebSocket-Key: \(key)\r\nSec-WebSocket-Version: 13\r\n\r\n"
        client.send(Data(request.utf8))
        _ = String(decoding: try await withTimeout {
            try await client.read(until: Data("\r\n\r\n".utf8))
        }, as: UTF8.self)

        let jpeg = try makeTempJPEG()
        defer { try? FileManager.default.removeItem(at: jpeg.url) }
        let photo = ProcessedPhoto(id: UUID(), printFile: jpeg.url, displayFile: jpeg.url, originals: [jpeg.url])
        await server.broadcast(state: .review(photo))
        let frame = try await withTimeout { try await TestWS.readServerFrame(client) }
        let obj = try XCTUnwrap(JSONSerialization.jsonObject(with: frame.payload) as? [String: Any])
        XCTAssertEqual(obj["showPrint"] as? Bool, false, "应携带打印按钮可见性开关")
        let filters = try XCTUnwrap(obj["filters"] as? [[String: Any]])
        XCTAssertFalse(filters.isEmpty, "filterSelection 默认开启应携带滤镜列表")
        XCTAssertTrue(filters.contains { ($0["id"] as? String) == "vivid" })

        client.send(TestWS.maskedFrame(opcode: 0x8, payload: Data([0x03, 0xE8])))
        await server.stop()
    }

    /// /api/photos 列表 + /photo/history/{date}/{session} 历史成片 + 路径穿越防护
    func testHistoryPhotosAPI() async throws {
        // 在真实 sessions 根下造一个临时会话（服务扫的就是 BoothPaths.sessionsDir）
        let fm = FileManager.default
        let day = "2099-12-31"
        let session = "235959-zztest"
        let sessionDir = BoothPaths.sessionsDir.appendingPathComponent(day, isDirectory: true)
            .appendingPathComponent(session, isDirectory: true)
        try fm.createDirectory(at: sessionDir, withIntermediateDirectories: true)
        defer { try? fm.removeItem(at: BoothPaths.sessionsDir.appendingPathComponent(day, isDirectory: true)) }
        // 历史成片展示图
        let jpeg = try makeTempJPEG()
        defer { try? fm.removeItem(at: jpeg.url) }
        try fm.copyItem(at: jpeg.url, to: sessionDir.appendingPathComponent("display.jpg"))

        let server = BoothWebService(conf: makeConf())
        try await server.start()
        let port = server.port
        defer { Task { await server.stop() } }

        // /api/photos：应列出刚造的会话
        let (listData, listResp) = try await URLSession.shared.data(
            from: URL(string: "http://127.0.0.1:\(port)/api/photos")!)
        XCTAssertEqual((listResp as? HTTPURLResponse)?.statusCode, 200)
        let obj = try XCTUnwrap(JSONSerialization.jsonObject(with: listData) as? [String: Any])
        let photos = try XCTUnwrap(obj["photos"] as? [[String: Any]])
        XCTAssertTrue(photos.contains {
            ($0["date"] as? String) == day && ($0["session"] as? String) == session
        }, "列表应包含测试会话，实际: \(photos)")

        // 历史成片下载：字节一致
        let (photoData, photoResp) = try await URLSession.shared.data(
            from: URL(string: "http://127.0.0.1:\(port)/photo/history/\(day)/\(session)")!)
        XCTAssertEqual((photoResp as? HTTPURLResponse)?.statusCode, 200)
        XCTAssertEqual((photoResp as? HTTPURLResponse)?.value(forHTTPHeaderField: "Content-Type"), "image/jpeg")
        XCTAssertEqual(photoData, jpeg.data, "历史成片字节应与磁盘一致")

        // 路径穿越防护：目录段带 .. 或多余段 → 404
        let (_, traversalResp) = try await URLSession.shared.data(
            from: URL(string: "http://127.0.0.1:\(port)/photo/history/..%2F..%2Fetc/passwd")!)
        XCTAssertEqual((traversalResp as? HTTPURLResponse)?.statusCode, 404, "路径穿越应被拒绝")
        let (_, extraResp) = try await URLSession.shared.data(
            from: URL(string: "http://127.0.0.1:\(port)/photo/history/\(day)/\(session)/extra")!)
        XCTAssertEqual((extraResp as? HTTPURLResponse)?.statusCode, 404, "多余路径段应被拒绝")

        await server.stop()
    }
}
