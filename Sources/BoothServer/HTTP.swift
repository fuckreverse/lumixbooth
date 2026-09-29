import Foundation

// ============================================================
// 最小 HTTP/1.1 解析与响应构造（BoothServer 专用，零依赖）
//  - 只解析「请求行 + 头部 + Content-Length body」，够 iPad 用
//  - 不支持 chunked / keep-alive 复用（每个请求响应后即关连接或转入流模式）
// ============================================================

/// 一个已解析的 HTTP 请求
struct HTTPRequest: Sendable {
    let method: String          // GET / POST ...
    let path: String            // 不含 query，如 /photo/xxx
    let query: String?          // ? 后面的原始串
    /// 头部（键统一小写，便于查找）
    let headers: [String: String]
    let body: Data
}

/// 解析结果：不完整（继续收）/ 非法（回 400）/ 完整请求
enum HTTPParseResult {
    case incomplete
    case invalid
    case request(HTTPRequest, consumed: Int)   // consumed = 该请求在缓冲区中占用的字节数
}

enum HTTPParser {

    static let headerSeparator = Data("\r\n\r\n".utf8)
    /// 头部区大小上限（防恶意超大头部撑爆内存）
    static let maxHeaderSize = 64 * 1024

    /// 从缓冲区头部解析一个完整 HTTP 请求
    static func parse(_ buffer: Data) -> HTTPParseResult {
        guard let headerRange = buffer.range(of: headerSeparator) else {
            return buffer.count > maxHeaderSize ? .invalid : .incomplete
        }
        let headerData = buffer.subdata(in: buffer.startIndex..<headerRange.lowerBound)
        guard let headerText = String(data: headerData, encoding: .utf8) else { return .invalid }

        var lines = headerText.components(separatedBy: "\r\n")
        let requestLine = lines.removeFirst()
        let parts = requestLine.split(separator: " ")
        guard parts.count >= 3 else { return .invalid }
        let method = String(parts[0])
        let target = String(parts[1])

        var headers: [String: String] = [:]
        for line in lines where !line.isEmpty {
            guard let colon = line.firstIndex(of: ":") else { continue }
            let key = line[..<colon].trimmingCharacters(in: .whitespaces).lowercased()
            let value = line[line.index(after: colon)...].trimmingCharacters(in: .whitespaces)
            headers[key] = value
        }

        // body：按 Content-Length 截取（本项目 4 个端点其实都是 GET，这里兜底）
        let contentLength = Int(headers["content-length"] ?? "0") ?? 0
        let headerEndOffset = buffer.distance(from: buffer.startIndex, to: headerRange.upperBound)
        let available = buffer.count - headerEndOffset
        guard available >= contentLength, contentLength >= 0 else { return .incomplete }
        let bodyStart = buffer.index(buffer.startIndex, offsetBy: headerEndOffset)
        let bodyEnd = buffer.index(bodyStart, offsetBy: contentLength)
        let body = buffer.subdata(in: bodyStart..<bodyEnd)

        // 拆 query
        var path = target
        var query: String? = nil
        if let q = target.firstIndex(of: "?") {
            path = String(target[..<q])
            query = String(target[target.index(after: q)...])
        }

        return .request(
            HTTPRequest(method: method, path: path, query: query, headers: headers, body: body),
            consumed: headerEndOffset + contentLength
        )
    }
}

/// HTTP 响应构造器（全部返回完整可发送的字节）
enum HTTPResponse {

    static func build(status: String, headers: [(String, String)] = [], body: Data? = nil) -> Data {
        var head = "HTTP/1.1 \(status)\r\nServer: Booth/1.0\r\n"
        for (k, v) in headers { head += "\(k): \(v)\r\n" }
        if let body { head += "Content-Length: \(body.count)\r\n" }
        head += "\r\n"
        var out = Data(head.utf8)
        if let body { out.append(body) }
        return out
    }

    /// 200 + 内容（响应完由调用方关连接）
    static func ok(contentType: String, body: Data) -> Data {
        build(status: "200 OK", headers: [("Content-Type", contentType)], body: body)
    }

    /// 404
    static func notFound() -> Data {
        build(status: "404 Not Found",
              headers: [("Content-Type", "text/plain; charset=utf-8")],
              body: Data("没有找到你要的内容".utf8))
    }

    /// 400
    static func badRequest(_ message: String) -> Data {
        build(status: "400 Bad Request",
              headers: [("Content-Type", "text/plain; charset=utf-8")],
              body: Data(message.utf8))
    }

    /// 101 WebSocket 升级响应
    static func switchingProtocols(accept: String) -> Data {
        build(status: "101 Switching Protocols",
              headers: [
                  ("Upgrade", "websocket"),
                  ("Connection", "Upgrade"),
                  ("Sec-WebSocket-Accept", accept),
              ])
    }

    /// /live MJPEG 流的响应头（无 Content-Length，连接保持，后续追加 multipart 分片）
    static func liveStreamHead() -> Data {
        var head = "HTTP/1.1 200 OK\r\nServer: Booth/1.0\r\n"
        head += "Content-Type: multipart/x-mixed-replace; boundary=booth\r\n"
        head += "Cache-Control: no-store\r\nPragma: no-cache\r\n"
        head += "Connection: keep-alive\r\n\r\n"
        return Data(head.utf8)
    }
}
