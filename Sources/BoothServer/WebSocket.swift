import Foundation
import CryptoKit

// ============================================================
// RFC6455 WebSocket 最小实现（服务端侧）
//  - 帧编解码：fin / opcode / mask / 7bit+16bit+64bit 长度
//  - 客户端→服务端帧必须掩码（协议规定），服务端→客户端帧不掩码
//  - 握手：Sec-WebSocket-Accept = base64(SHA1(key + 固定 GUID))
//  - 控制帧：ping→pong；close→回 close 后断开
// ============================================================

/// 帧操作码（RFC6455 §5.1）
enum WSOpcode {
    static let continuation: UInt8 = 0x0   // 分片延续
    static let text: UInt8         = 0x1   // 文本（JSON 消息）
    static let binary: UInt8       = 0x2
    static let close: UInt8        = 0x8
    static let ping: UInt8         = 0x9
    static let pong: UInt8         = 0xA
}

/// 一帧解出的结果
struct WSFrame: Sendable {
    let fin: Bool
    let opcode: UInt8
    let payload: Data
}

enum WSError: Error {
    /// 数据不够一帧，等下一包再试（正常情况，不是错误）
    case incomplete
    /// 协议违规（如客户端帧未掩码），应回 1002 关闭
    case protocolViolation(String)
}

enum WSCodec {

    /// RFC6455 §1.3 固定 GUID
    static let guid = "258EAFA5-E914-47DA-95CA-C5AB0DC85B11"

    /// 握手 Accept 值：base64(SHA1(Sec-WebSocket-Key + GUID))
    static func acceptValue(for key: String) -> String {
        let digest = Insecure.SHA1.hash(data: Data((key + guid).utf8))
        return Data(digest).base64EncodedString()
    }

    /// 服务端→客户端帧（不掩码）
    static func encode(fin: Bool = true, opcode: UInt8, payload: Data = Data()) -> Data {
        var out = Data()
        out.append((fin ? 0x80 : 0x00) | opcode)
        let len = payload.count
        if len < 126 {
            out.append(UInt8(len))
        } else if len <= 0xFFFF {
            out.append(126)
            out.append(UInt8((len >> 8) & 0xFF))
            out.append(UInt8(len & 0xFF))
        } else {
            out.append(127)
            for shift in stride(from: 56, through: 0, by: -8) {
                out.append(UInt8((len >> shift) & 0xFF))
            }
        }
        out.append(payload)
        return out
    }

    /// 从缓冲区头部解一帧。
    /// - Parameters:
    ///   - requireMask: 客户端方向必须为 true（RFC 规定客户端帧必掩码）
    /// - Throws: `.incomplete` 数据不足；`.protocolViolation` 协议违规
    static func decode(_ data: Data, requireMask: Bool) throws -> (frame: WSFrame, consumed: Int) {
        let bytes = [UInt8](data)
        guard bytes.count >= 2 else { throw WSError.incomplete }

        let fin = bytes[0] & 0x80 != 0
        let opcode = bytes[0] & 0x0F
        let masked = bytes[1] & 0x80 != 0
        var length = Int(bytes[1] & 0x7F)
        var offset = 2

        // 扩展长度：126 → 后 2 字节；127 → 后 8 字节
        if length == 126 {
            guard bytes.count >= offset + 2 else { throw WSError.incomplete }
            length = (Int(bytes[2]) << 8) | Int(bytes[3])
            offset = 4
        } else if length == 127 {
            guard bytes.count >= offset + 8 else { throw WSError.incomplete }
            var v = 0
            for i in 0..<8 { v = (v << 8) | Int(bytes[offset + i]) }
            guard v >= 0, v < Int.max else { throw WSError.protocolViolation("帧长度非法") }
            length = v
            offset += 8
        }

        // 掩码键（客户端帧必带）
        var mask = [UInt8]()
        if masked {
            guard bytes.count >= offset + 4 else { throw WSError.incomplete }
            mask = Array(bytes[offset..<(offset + 4)])
            offset += 4
        } else if requireMask {
            throw WSError.protocolViolation("客户端帧未掩码")
        }

        guard bytes.count >= offset + length else { throw WSError.incomplete }

        var payload = Array(bytes[offset..<(offset + length)])
        if masked {
            for i in 0..<payload.count { payload[i] ^= mask[i & 3] }
        }
        return (WSFrame(fin: fin, opcode: opcode, payload: Data(payload)), offset + length)
    }
}
