import Foundation
import CommonCrypto

// ============================================================
// PINStore — 操作员 PIN（防呆/无人值守保护，SPEC §9 扩展）
//  - PIN 规则：4-6 位数字
//  - 存储：PBKDF2-HMAC-SHA256 加盐哈希，独立文件 guard.json
//    （与 config.json 分离：一键重置配置不会把密码冲掉）
//  - 支持「放弃保护」标记（DIY 用户跳过 PIN，进入操作员页不再拦截）
//  - 哈希校验恒定耗时（无论 PIN 长短都跑满 PBKDF2 轮数）
// ============================================================

public enum PINError: Error, Equatable {
    case invalidFormat          // 不是 4-6 位数字
    case wrongOldPIN            // 旧 PIN 验证失败
    case protectionActive       // 已设置 PIN 时不能直接放弃保护
}

/// PIN 格式校验：4-6 位数字
public func isValidPINFormat(_ pin: String) -> Bool {
    (4...6).contains(pin.count) && pin.allSatisfy { $0.isNumber && $0.isASCII }
}

/// PBKDF2-HMAC-SHA256（CommonCrypto）
func pbkdf2Hash(password: String, salt: Data, rounds: UInt32) -> Data {
    let pw = Data(password.utf8)
    var derived = Data(repeating: 0, count: 32)
    let status = derived.withUnsafeMutableBytes { derivedPtr -> Int32 in
        salt.withUnsafeBytes { saltPtr -> Int32 in
            pw.withUnsafeBytes { pwPtr -> Int32 in
                CCKeyDerivationPBKDF(
                    CCPBKDFAlgorithm(kCCPBKDF2),
                    pwPtr.baseAddress?.assumingMemoryBound(to: Int8.self), pw.count,
                    saltPtr.baseAddress?.assumingMemoryBound(to: UInt8.self), salt.count,
                    CCPseudoRandomAlgorithm(kCCPRFHmacAlgSHA256), rounds,
                    derivedPtr.baseAddress?.assumingMemoryBound(to: UInt8.self), 32)
            }
        }
    }
    precondition(status == kCCSuccess, "PBKDF2 派生失败: \(status)")
    return derived
}

/// guard.json 落盘结构（字段全可选，向后兼容）
struct GuardFile: Codable, Sendable {
    var pinHash: Data?
    var salt: Data?
    var rounds: Int?
    var protectionOptOut: Bool?

    static func load(from url: URL) -> GuardFile {
        guard let data = try? Data(contentsOf: url),
              let obj = try? JSONDecoder().decode(GuardFile.self, from: data) else {
            return GuardFile()
        }
        return obj
    }

    func save(to url: URL) throws {
        let enc = JSONEncoder()
        enc.outputFormatting = [.prettyPrinted, .sortedKeys]
        try enc.encode(self).write(to: url, options: .atomic)
    }
}

/// 操作员 PIN 存取（actor 串行；UI 侧的防爆破退避在 OperatorGate）
public actor PINStore {
    public static let shared = PINStore(fileURL: BoothPaths.guardFile)

    private let fileURL: URL
    private var record: GuardFile

    /// 迭代轮数（登录场景每次校验跑一遍，~几十毫秒可接受）
    private static let rounds: UInt32 = 120_000

    public init(fileURL: URL) {
        self.fileURL = fileURL
        self.record = GuardFile.load(from: fileURL)
    }

    // MARK: - 状态

    public var hasPIN: Bool { record.pinHash != nil }
    public var protectionOptOut: Bool { record.protectionOptOut == true }

    // MARK: - 设置 / 修改

    /// 设置或修改 PIN。已有 PIN 时必须提供正确的旧 PIN。
    public func setPIN(_ newPIN: String, oldPIN: String?) throws {
        guard isValidPINFormat(newPIN) else { throw PINError.invalidFormat }
        if record.pinHash != nil {
            guard let oldPIN, verifyHash(oldPIN) else { throw PINError.wrongOldPIN }
        }
        var salt = Data(count: 16)
        _ = salt.withUnsafeMutableBytes { SecRandomCopyBytes(kSecRandomDefault, 16, $0.baseAddress!) }
        record.pinHash = pbkdf2Hash(password: newPIN, salt: salt, rounds: Self.rounds)
        record.salt = salt
        record.rounds = Int(Self.rounds)
        record.protectionOptOut = false     // 设置了 PIN 即恢复保护
        try record.save(to: fileURL)
        Log.core.info("操作员 PIN 已设置/更新（PBKDF2 加盐哈希落盘 guard.json）")
    }

    /// 放弃保护（清除 PIN + 标记 optOut）。已有 PIN 时必须提供正确的旧 PIN。
    public func disableProtection(oldPIN: String?) throws {
        if record.pinHash != nil {
            guard let oldPIN, verifyHash(oldPIN) else { throw PINError.wrongOldPIN }
        }
        record = GuardFile(pinHash: nil, salt: nil, rounds: nil, protectionOptOut: true)
        try record.save(to: fileURL)
        Log.core.warn("操作员 PIN 保护已放弃（DIY 模式：进入操作员页不再验证）")
    }

    // MARK: - 校验

    /// 校验 PIN；未设置 PIN 时恒返回 false（恒跑一轮 PBKDF2 防时序探测）
    public func verify(_ pin: String) -> Bool {
        guard let stored = record.pinHash, let salt = record.salt else {
            _ = pbkdf2Hash(password: pin, salt: Data(repeating: 0, count: 16), rounds: Self.rounds)
            return false
        }
        let rounds = UInt32(record.rounds ?? Int(Self.rounds))
        let candidate = pbkdf2Hash(password: pin, salt: salt, rounds: rounds)
        // 常数时间比较
        guard candidate.count == stored.count else { return false }
        var diff: UInt8 = 0
        for (a, b) in zip(candidate, stored) { diff |= a ^ b }
        return diff == 0
    }

    private func verifyHash(_ pin: String) -> Bool {
        guard let stored = record.pinHash, let salt = record.salt else { return false }
        let rounds = UInt32(record.rounds ?? Int(Self.rounds))
        return constantTimeEqual(pbkdf2Hash(password: pin, salt: salt, rounds: rounds), stored)
    }

    private func constantTimeEqual(_ a: Data, _ b: Data) -> Bool {
        guard a.count == b.count else { return false }
        var diff: UInt8 = 0
        for (x, y) in zip(a, b) { diff |= x ^ y }
        return diff == 0
    }
}
