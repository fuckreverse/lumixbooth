import XCTest
import BoothCore
@testable import BoothCore

// ============================================================
// 本轮新增功能测试：提示音 WAV 合成 / 邮箱采集存储 /
// 留言簿与提示音配置段 / 新旧配置向后兼容。
// ============================================================
final class FeatureAdditionsTests: XCTestCase {

    // MARK: - 提示音 WAV 合成（纯函数）

    /// 三种效果音都能合成合法 WAV（RIFF 头 + 长度一致）
    func testSoundEffectWAVSynthesis() throws {
        for effect in SoundEffect.allCases {
            let samples = SoundEffects.pcmSamples(effect)
            XCTAssertFalse(samples.isEmpty, "\(effect) 采样序列不应为空")
            XCTAssertTrue(samples.allSatisfy { $0 >= -1 && $0 <= 1 }, "\(effect) 采样值必须归一化")

            let wav = try SoundEffects.synthesizeWAV(effect)
            XCTAssertEqual(String(data: wav.prefix(4), encoding: .ascii), "RIFF")
            XCTAssertEqual(String(data: wav.subdata(in: 8..<12), encoding: .ascii), "WAVE")
            XCTAssertEqual(String(data: wav.subdata(in: 36..<40), encoding: .ascii), "data")
            // 总长 = 44 字节头 + 采样数 × 2（16-bit 单声道）
            XCTAssertEqual(wav.count, 44 + samples.count * 2)
        }
    }

    /// WAV 容器：16-bit 单声道头字段正确
    func testWAVContainerHeader() {
        let wav = SoundEffects.wavContainer(samples: [0, 0.5, -0.5, 1, -1], sampleRate: 44_100)
        // fmt 段：PCM=1、声道=1、采样率、byteRate=sampleRate*2、blockAlign=2、位深=16
        func u16(_ o: Int) -> Int {
            let b = [UInt8](wav.subdata(in: o..<o+2))
            return Int(b[0]) | Int(b[1]) << 8
        }
        func u32(_ o: Int) -> Int {
            let b = [UInt8](wav.subdata(in: o..<o+4))
            return Int(b[0]) | Int(b[1]) << 8 | Int(b[2]) << 16 | Int(b[3]) << 24
        }
        XCTAssertEqual(u16(20), 1, "编码格式应为 PCM")
        XCTAssertEqual(u16(22), 1, "应为单声道")
        XCTAssertEqual(u32(24), 44_100, "采样率 44.1kHz")
        XCTAssertEqual(u32(28), 88_200, "byteRate = 采样率 × blockAlign")
        XCTAssertEqual(u16(32), 2, "blockAlign = 2 字节")
        XCTAssertEqual(u16(34), 16, "位深 16-bit")
        XCTAssertEqual(u32(40), 10, "data 段长度 = 5 采样 × 2 字节")
    }

    // MARK: - 邮箱采集

    /// 宽松邮箱校验：合法/非法边界
    func testEmailValidation() {
        XCTAssertTrue(EmailStore.isValidEmail("guest@example.com"))
        XCTAssertTrue(EmailStore.isValidEmail("  Guest@Example.COM "), "应自动去空白 + 小写化")
        XCTAssertTrue(EmailStore.isValidEmail("a+b-c_d%e.f@example.co"))
        XCTAssertFalse(EmailStore.isValidEmail(""), "空串拒绝")
        XCTAssertFalse(EmailStore.isValidEmail("no-at-sign"), "缺 @ 拒绝")
        XCTAssertFalse(EmailStore.isValidEmail("a@b@c.com"), "多 @ 拒绝")
        XCTAssertFalse(EmailStore.isValidEmail("@example.com"), "@ 前空拒绝")
        XCTAssertFalse(EmailStore.isValidEmail("user@"), "域名空拒绝")
        XCTAssertFalse(EmailStore.isValidEmail("user@example"), "域名无点拒绝")
        XCTAssertFalse(EmailStore.isValidEmail("user@.com"), "域名字首为点拒绝")
        XCTAssertFalse(EmailStore.isValidEmail("user name@example.com"), "含空格拒绝")
        XCTAssertFalse(EmailStore.isValidEmail("user@example.com\nX"), "非法字符拒绝")
    }

    /// EmailStore：追加/去重/补关联照片/落盘重载/CSV 导出
    func testEmailStoreAppendDedupAndCSV() async throws {
        let dir = FileManager.default.temporaryDirectory
            .appendingPathComponent("booth-test-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        let file = dir.appendingPathComponent("emails.json")
        defer { try? FileManager.default.removeItem(at: dir) }
        let store = EmailStore(file: file)

        // 非法邮箱被拒（不落盘）
        let okBad = await store.append(email: "not-an-email", photoID: nil)
        XCTAssertFalse(okBad)
        // 首次提交成功
        let okFirst = await store.append(email: "Guest@Example.COM", photoID: "p1")
        XCTAssertTrue(okFirst)
        var all = await store.all()
        XCTAssertEqual(all.count, 1)
        XCTAssertEqual(all[0].email, "guest@example.com", "应小写化归一")
        // 重复提交：只补关联照片不重复入列
        let okDup = await store.append(email: "guest@example.com", photoID: "p2")
        XCTAssertTrue(okDup)
        all = await store.all()
        XCTAssertEqual(all.count, 1, "同一邮箱去重")
        XCTAssertEqual(all[0].photoID, "p1", "已有关联不覆盖")

        // 第二个邮箱（首次不关联照片）
        let okSecond = await store.append(email: "second@ex.org", photoID: nil)
        XCTAssertTrue(okSecond)
        // 重新加载（新实例读同一文件）：验证落盘持久化
        let reloaded = EmailStore(file: file)
        let reloadedCount = await reloaded.count
        XCTAssertEqual(reloadedCount, 2, "落盘重载应一致")
        let okPatch = await reloaded.append(email: "second@ex.org", photoID: "px")
        XCTAssertTrue(okPatch)
        let finalAll = await reloaded.all()
        XCTAssertEqual(finalAll.count, 2)
        XCTAssertEqual(finalAll.first { $0.email == "second@ex.org" }?.photoID, "px",
                       "重载后补关联照片生效")

        // CSV 导出
        let csvURL = try await reloaded.exportCSV(to: dir.appendingPathComponent("export"))
        let csv = try String(contentsOf: csvURL, encoding: .utf8)
        XCTAssertTrue(csv.hasPrefix("email,photoID,time\n"), "表头固定")
        XCTAssertTrue(csv.contains("guest@example.com,p1,"), "行内容含邮箱+关联")
        XCTAssertTrue(csv.contains("second@ex.org,px,"), "补关联后导出最新值")
    }

    // MARK: - 配置新段（sounds / share / guestbook）

    /// 老配置缺 sounds/share/guestbook/reprintCode/idleDimAfterMin/generateGIF 全部走默认值
    func testLegacyConfigNewSectionsDefault() throws {
        let legacy = """
        { "capture": {}, "imaging": {}, "security": {} }
        """.data(using: .utf8)!
        let cfg = try JSONDecoder().decode(BoothConfig.self, from: legacy)
        XCTAssertTrue(cfg.sounds.enabled, "提示音默认开")
        XCTAssertTrue(cfg.sounds.countdownBeep)
        XCTAssertEqual(cfg.sounds.volume, 0.8)
        XCTAssertTrue(cfg.share.emailCapture, "邮箱采集默认开")
        XCTAssertFalse(cfg.guestbook.enabled, "留言簿默认关（需摄像头）")
        XCTAssertEqual(cfg.guestbook.maxDurationSec, 15)
        XCTAssertEqual(cfg.guestbook.overlayText, "新婚快乐")
        XCTAssertEqual(cfg.security.reprintCode, "1234", "重打口令默认值")
        XCTAssertEqual(cfg.capture.idleDimAfterMin, 10, "省电调暗默认 10 分钟")
        XCTAssertTrue(cfg.imaging.generateGIF, "GIF 生成默认开")
    }

    /// 新段 round-trip：编码再解码不丢字段
    func testNewSectionsRoundTrip() throws {
        var cfg = BoothConfig()
        cfg.sounds.enabled = false
        cfg.sounds.volume = 0.3
        cfg.sounds.shutterSound = false
        cfg.share.emailCapture = false
        cfg.guestbook.enabled = true
        cfg.guestbook.maxDurationSec = 30
        cfg.guestbook.overlayText = "百年好合"
        cfg.security.reprintCode = "8888"
        cfg.capture.idleDimAfterMin = 20
        cfg.imaging.generateGIF = false
        let back = try JSONDecoder().decode(BoothConfig.self, from: JSONEncoder().encode(cfg))
        XCTAssertEqual(back, cfg)
        XCTAssertEqual(back.sounds.volume, 0.3)
        XCTAssertEqual(back.guestbook.overlayText, "百年好合")
        XCTAssertEqual(back.security.reprintCode, "8888")
        XCTAssertEqual(back.capture.idleDimAfterMin, 20)
        XCTAssertFalse(back.imaging.generateGIF)
    }

    /// 净化：留言簿时长/祝福语、省电分钟数被夹取
    func testSanitizedClampsNewFields() {
        var cfg = BoothConfig()
        cfg.guestbook.maxDurationSec = 999
        cfg.guestbook.overlayText = String(repeating: "福", count: 40)
        cfg.capture.idleDimAfterMin = -5
        let clean = cfg.sanitized()
        XCTAssertEqual(clean.guestbook.maxDurationSec, 120, "时长上限 120s")
        XCTAssertEqual(clean.guestbook.overlayText.count, 20, "祝福语最长 20 字")
        XCTAssertEqual(clean.capture.idleDimAfterMin, 0, "负数夹为 0（0 = 不启用）")
    }

    // MARK: - 留言簿指令桥

    /// 未装配 / 未启用时 start/stop 返回失败；install+enabled 后闭包生效
    func testGuestbookCommandBridge() async {
        // 桥是进程级单例：先装配成 disabled 验证拒绝路径
        GuestbookCommandBridge.shared.install(enabled: false, start: { _, done in
            done(GuestbookResult(ok: true, fileName: "guestbook-x.mov"))
        }, stop: { done in
            done(GuestbookResult(ok: true))
        })
        let refusedStart = expectation(description: "disabled start 回失败")
        GuestbookCommandBridge.shared.start(maxSec: 10) { result in
            XCTAssertFalse(result.ok)
            XCTAssertEqual(result.error, "留言簿未启用")
            refusedStart.fulfill()
        }
        await fulfillment(of: [refusedStart], timeout: 2)

        // 启用后闭包被真实调用
        GuestbookCommandBridge.shared.setEnabled(true)
        let okStart = expectation(description: "enabled start 走注入闭包")
        GuestbookCommandBridge.shared.start(maxSec: 10) { result in
            XCTAssertTrue(result.ok)
            XCTAssertEqual(result.fileName, "guestbook-x.mov")
            okStart.fulfill()
        }
        await fulfillment(of: [okStart], timeout: 2)

        let okStop = expectation(description: "stop 走注入闭包")
        GuestbookCommandBridge.shared.stop { result in
            XCTAssertTrue(result.ok)
            okStop.fulfill()
        }
        await fulfillment(of: [okStop], timeout: 2)

        // 还原（不污染其他测试）
        GuestbookCommandBridge.shared.setEnabled(false)
    }
}
