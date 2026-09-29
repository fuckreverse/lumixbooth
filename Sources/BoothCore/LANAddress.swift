import Foundation

/// 局域网地址工具：getifaddrs 枚举本机 IPv4。
/// 放在 BoothCore：App 二维码与 SessionEngine 打印 QR 链接共用。
public enum LANAddress {
    /// 本机局域网 IPv4 字符串：优先 en0（Wi-Fi），其次第一个非回环地址
    public static func localIPv4() -> String? {
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0, let first = ifaddr else { return nil }
        defer { freeifaddrs(ifaddr) }

        var fallback: String?
        for ptr in sequence(first: first, next: { $0.pointee.ifa_next }) {
            let iface = ptr.pointee
            guard let addr = iface.ifa_addr, addr.pointee.sa_family == UInt8(AF_INET) else { continue }
            var host = [CChar](repeating: 0, count: Int(NI_MAXHOST))
            let rc = getnameinfo(addr, socklen_t(addr.pointee.sa_len),
                                 &host, socklen_t(host.count), nil, 0, NI_NUMERICHOST)
            guard rc == 0 else { continue }
            // 手动截断 null 结尾再按 UTF-8 解码（String(cString:) 数组重载已废弃）
            let ip = String(decoding: host.prefix { $0 != 0 }.map { UInt8(bitPattern: $0) }, as: UTF8.self)
            guard !ip.hasPrefix("127.") else { continue }
            let name = String(cString: iface.ifa_name)
            if name == "en0" { return ip }
            if fallback == nil { fallback = ip }
        }
        return fallback
    }
}
