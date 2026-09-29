import Foundation

// ============================================================
// 邮箱采集（借鉴 Simplebooth 线索采集）：REVIEW 页宾客输邮箱领电子版。
// 仅落盘不发送（隐私友好）：
//   ~/Library/Application Support/Booth/emails.json  —— 追加式 JSON 数组
//   ~/Library/Application Support/Booth/emails-export/ —— 操作员一键导出 CSV
// ============================================================

/// 一条邮箱记录
public struct EmailRecord: Codable, Sendable, Equatable {
    public let email: String
    public let photoID: String?    // 关联成片 UUID（拍照当轮可选填）
    public let time: Date
    public init(email: String, photoID: String?, time: Date) {
        self.email = email; self.photoID = photoID; self.time = time
    }
}

/// 邮箱存储（actor：串行化落盘与去重判定）
public actor EmailStore {
    public static let shared = EmailStore()

    private let file: URL
    private var records: [EmailRecord] = []
    private var loaded = false

    public init(file: URL = BoothPaths.emailsFile) {
        self.file = file
    }

    /// 惰性加载落盘记录（首次访问时）
    private func loadIfNeeded() {
        guard !loaded else { return }
        loaded = true
        guard let data = try? Data(contentsOf: file),
              let list = try? JSONDecoder.booth.decode([EmailRecord].self, from: data) else { return }
        records = list
    }

    /// 宽松邮箱格式校验（宾客在 iPad 上手输，不能太苛刻）：
    /// 有且仅有一个 @，@ 前后各至少 1 个非空字符，域名含一个点
    public static func isValidEmail(_ s: String) -> Bool {
        let email = s.trimmingCharacters(in: .whitespaces).lowercased()
        let parts = email.split(separator: "@", omittingEmptySubsequences: false)
        guard parts.count == 2,
              !parts[0].isEmpty, parts[0].count <= 64,
              !parts[1].isEmpty, parts[1].count <= 190 else { return false }
        guard parts[1].contains("."), !parts[1].hasPrefix("."), !parts[1].hasSuffix(".") else { return false }
        return email.allSatisfy { c in
            c.isLetter || c.isNumber || "@._%+-".contains(c)
        }
    }

    /// 追加一条记录。自动去空白/小写化；同一邮箱已存在则只更新关联照片（不重复入列）。
    /// 返回 false = 格式非法被拒。
    @discardableResult
    public func append(email rawEmail: String, photoID: String?) async -> Bool {
        loadIfNeeded()
        let email = rawEmail.trimmingCharacters(in: .whitespaces).lowercased()
        guard Self.isValidEmail(email) else {
            Log.core.warn("邮箱格式非法，已拒绝: \(rawEmail.prefix(60))")
            return false
        }
        if let idx = records.firstIndex(where: { $0.email == email }) {
            // 已存在：只补关联照片（若原记录没有）
            if records[idx].photoID == nil, let photoID {
                records[idx] = EmailRecord(email: email, photoID: photoID, time: records[idx].time)
                persist()
                Log.core.info("邮箱已存在（补关联照片 \(photoID)）: \(email)")
            } else {
                Log.core.info("邮箱重复提交，忽略: \(email)")
            }
            return true
        }
        records.append(EmailRecord(email: email, photoID: photoID, time: Date()))
        persist()
        Log.core.info("邮箱采集成功: \(email)（累计 \(records.count) 条）")
        return true
    }

    /// 全量记录（新→旧）
    public func all() async -> [EmailRecord] {
        loadIfNeeded()
        return records.sorted { $0.time > $1.time }
    }

    /// 记录总数（健康面板 / UI 徽标用）
    public var count: Int {
        get async { loadIfNeeded(); return records.count }
    }

    /// 导出 CSV 到 emails-export 目录，返回文件 URL（文件名带当天日期）
    public func exportCSV(to dir: URL = BoothPaths.emailsExportDir) async throws -> URL {
        loadIfNeeded()
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        let iso = ISO8601DateFormatter()
        var csv = "email,photoID,time\n"
        for r in records.sorted(by: { $0.time < $1.time }) {
            // CSV 转义：邮箱本身不含逗号（字符白名单已限制），photoID 是 UUID，直接拼
            csv += "\(r.email),\(r.photoID ?? ""),\(iso.string(from: r.time))\n"
        }
        let url = dir.appendingPathComponent("emails-\(DateFormatter.boothDay.string(from: Date())).csv")
        try Data(csv.utf8).write(to: url, options: .atomic)
        Log.core.info("邮箱 CSV 已导出: \(url.path)（\(records.count) 条）")
        return url
    }

    /// 全量写盘（records 数量级为百~千，整写无压力）
    private func persist() {
        guard let data = try? JSONEncoder.booth.encode(records) else { return }
        try? data.write(to: file, options: .atomic)
    }
}

extension JSONEncoder {
    /// 项目统一编码器（iso8601 日期，与 ConfigStore 一致）
    public static var booth: JSONEncoder {
        let e = JSONEncoder()
        e.dateEncodingStrategy = .iso8601
        e.outputFormatting = [.sortedKeys]
        return e
    }
}

extension JSONDecoder {
    public static var booth: JSONDecoder {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .iso8601
        return d
    }
}
