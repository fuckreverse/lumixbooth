import XCTest
@testable import BoothCore

// ============================================================
// 防呆保护单测：PINStore / 配置净化 / 容错加载 / 备份恢复重置
// 全部走临时目录，不污染真实 ~/Library/Application Support/Booth
// ============================================================

final class GuardAndConfigTests: XCTestCase {

    /// 每个测试独立临时目录
    private var tmp: URL!

    override func setUpWithError() throws {
        tmp = FileManager.default.temporaryDirectory
            .appendingPathComponent("booth-tests-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: tmp, withIntermediateDirectories: true)
    }

    override func tearDownWithError() throws {
        try? FileManager.default.removeItem(at: tmp)
    }

    // MARK: - PIN 格式

    func testPINFormatValidation() {
        XCTAssertTrue(isValidPINFormat("1234"))
        XCTAssertTrue(isValidPINFormat("123456"))
        XCTAssertTrue(isValidPINFormat("12345"))
        XCTAssertFalse(isValidPINFormat("123"))        // 太短
        XCTAssertFalse(isValidPINFormat("1234567"))    // 太长
        XCTAssertFalse(isValidPINFormat("12a4"))      // 非数字
        XCTAssertFalse(isValidPINFormat("12 4"))      // 含空格
        XCTAssertFalse(isValidPINFormat(""))          // 空
        XCTAssertFalse(isValidPINFormat("１２３４"))    // 全角数字不算
    }

    // MARK: - PINStore

    func testPINSetAndVerify() async throws {
        let store = PINStore(fileURL: tmp.appendingPathComponent("guard.json"))
        XCTAssertFalse(store === PINStore.shared)   // 独立实例，不碰单例

        try await store.setPIN("1234", oldPIN: nil)
        let has = await store.hasPIN
        XCTAssertTrue(has)
        let ok = await store.verify("1234")
        XCTAssertTrue(ok)
        let bad = await store.verify("4321")
        XCTAssertFalse(bad)
        let fmtBad = await store.verify("999")       // 格式不合法
        XCTAssertFalse(fmtBad)
    }

    func testPINChangeRequiresOldPIN() async throws {
        let store = PINStore(fileURL: tmp.appendingPathComponent("guard.json"))
        try await store.setPIN("1111", oldPIN: nil)

        // 错旧 PIN 改不了
        do {
            try await store.setPIN("2222", oldPIN: "0000")
            XCTFail("错误旧 PIN 应当抛错")
        } catch let e as PINError {
            XCTAssertEqual(e, .wrongOldPIN)
        }

        // 正确旧 PIN 可改
        try await store.setPIN("2222", oldPIN: "1111")
        let ok = await store.verify("2222")
        XCTAssertTrue(ok)
        let old = await store.verify("1111")
        XCTAssertFalse(old)
    }

    func testPINOptOutAndRestore() async throws {
        let store = PINStore(fileURL: tmp.appendingPathComponent("guard.json"))

        // 无 PIN 时可直接放弃保护（首次引导跳过）
        try await store.disableProtection(oldPIN: nil)
        var optOut = await store.protectionOptOut
        XCTAssertTrue(optOut)

        // 有 PIN 时放弃保护必须验旧 PIN
        try await store.setPIN("3333", oldPIN: nil)
        do {
            try await store.disableProtection(oldPIN: "0000")
            XCTFail("错误旧 PIN 应当抛错")
        } catch { /* expected */ }
        try await store.disableProtection(oldPIN: "3333")
        optOut = await store.protectionOptOut
        XCTAssertTrue(optOut)

        // 设置 PIN 恢复保护
        try await store.setPIN("4444", oldPIN: nil)
        optOut = await store.protectionOptOut
        XCTAssertFalse(optOut)
    }

    func testPINPersistence() async throws {
        let url = tmp.appendingPathComponent("guard.json")
        let store = PINStore(fileURL: url)
        try await store.setPIN("9876", oldPIN: nil)

        // 新实例从磁盘加载（验证哈希落盘 + 加载路径）
        let store2 = PINStore(fileURL: url)
        let has = await store2.hasPIN
        XCTAssertTrue(has)
        let ok = await store2.verify("9876")
        XCTAssertTrue(ok)
    }

    func testPINHashNotPlaintextOnDisk() async throws {
        let url = tmp.appendingPathComponent("guard.json")
        let store = PINStore(fileURL: url)
        try await store.setPIN("9876", oldPIN: nil)
        let raw = try String(contentsOf: url, encoding: .utf8)
        XCTAssertFalse(raw.contains("9876"), "落盘文件不得含明文 PIN")
    }

    func testVerifyWithoutPINAlwaysFalseAndUniform() async throws {
        let store = PINStore(fileURL: tmp.appendingPathComponent("guard.json"))
        // 未设置 PIN：任何输入恒 false（且跑满 PBKDF2 不炸）
        let r = await store.verify("1234")
        XCTAssertFalse(r)
        let r2 = await store.verify("000000")
        XCTAssertFalse(r2)
    }

    // MARK: - 配置净化

    func testSanitizeClampsBadValues() {
        var cfg = BoothConfig()
        cfg.capture.countdownSec = -3           // 负倒计时 → 下限 0（立即拍）
        cfg.capture.reviewTimeoutSec = 0        // 零超时 → 下限 1
        cfg.printing.defaultCopies = 99         // 份数爆炸 → 4
        cfg.printing.printQuotaPerHour = 9999   // 配额 → 1000
        cfg.imaging.skinStrength = -20          // 美肤强度 → 0
        cfg.vision.detectEveryNFrames = 0       // 帧间隔 → 1
        // 注：port 是 UInt16，类型本身即约束 0...65535，无法构造非法值

        let s = cfg.sanitized()
        XCTAssertEqual(s.capture.countdownSec, 0)
        XCTAssertEqual(s.capture.reviewTimeoutSec, 1)
        XCTAssertEqual(s.printing.defaultCopies, 4)
        XCTAssertEqual(s.printing.printQuotaPerHour, 1000)
        XCTAssertEqual(s.imaging.skinStrength, 0)
        XCTAssertEqual(s.vision.detectEveryNFrames, 1)
    }

    func testSanitizeKeepsValidValues() {
        var cfg = BoothConfig()
        cfg.capture.countdownSec = 10
        cfg.printing.defaultCopies = 3
        cfg.imaging.skinStrength = 65
        cfg.server.port = 9090
        let s = cfg.sanitized()
        XCTAssertEqual(s.capture.countdownSec, 10)
        XCTAssertEqual(s.printing.defaultCopies, 3)
        XCTAssertEqual(s.imaging.skinStrength, 65)
        XCTAssertEqual(s.server.port, 9090)   // 合法端口不受影响
    }

    // MARK: - 容错加载（老配置兼容 / 损坏文件）

    func testLoadLegacyConfigMissingNewFields() throws {
        // 模拟 v1 老配置：没有 security / printQuotaPerHour 字段
        let legacy: [String: Any] = [
            "capture": ["countdownSec": 5, "defaultMode": ["kind": "single", "shots": 1],
                        "reviewTimeoutSec": 90, "autoPrintOnTimeout": false,
                        "gestureTimeoutSec": 20, "armedTimeoutSec": 8],
            "printing": ["defaultCopies": 1]
        ]
        let data = try JSONSerialization.data(withJSONObject: legacy)
        let cfg = BoothConfig.load(from: data)
        // 老字段保留
        XCTAssertEqual(cfg.capture.countdownSec, 5)
        XCTAssertEqual(cfg.capture.reviewTimeoutSec, 90)
        XCTAssertFalse(cfg.capture.autoPrintOnTimeout)
        XCTAssertEqual(cfg.printing.defaultCopies, 1)
        XCTAssertEqual(cfg.capture.defaultMode, .single)
        // 新字段补默认
        XCTAssertEqual(cfg.printing.printQuotaPerHour, 0)
        XCTAssertTrue(cfg.security.quitProtection)
        XCTAssertEqual(cfg.printing.maxCopies, 4)
    }

    func testLoadEmptyJSONFallsBackToDefaults() throws {
        // 空对象 / 缺失大部分段：全部回默认
        let data = try JSONSerialization.data(withJSONObject: [String: Any]())
        let cfg = BoothConfig.load(from: data)
        XCTAssertEqual(cfg, BoothConfig())
    }

    func testLoadBadlyTypedSectionIsolatesDamage() throws {
        // capture 段字段类型损坏；其余段应当完好
        let obj: [String: Any] = [
            "capture": ["countdownSec": "五秒"],      // 类型坏
            "printing": ["defaultCopies": 3]           // 正常
        ]
        let data = try JSONSerialization.data(withJSONObject: obj)
        let cfg = BoothConfig.load(from: data)
        XCTAssertEqual(cfg.capture.countdownSec, BoothConfig().capture.countdownSec)  // 坏段回默认
        XCTAssertEqual(cfg.printing.defaultCopies, 3)                                 // 好段保留
    }

    // MARK: - ConfigStore 备份 / 恢复 / 重置（临时目录）

    private func makeStore() -> ConfigStore {
        ConfigStore(fileURL: tmp.appendingPathComponent("config.json"),
                   backupsDir: tmp.appendingPathComponent("backups"))
    }

    func testConfigStoreUpdateCreatesBackup() async throws {
        let store = makeStore()
        // 先落一份初始配置（写盘）
        await store.update { $0.capture.countdownSec = 5 }

        // 再改一次 → 上次的配置应产生备份
        await store.update { $0.capture.countdownSec = 10 }
        let backups = await store.listBackups()
        XCTAssertEqual(backups.count, 1)
        let cfg = await store.config
        XCTAssertEqual(cfg.capture.countdownSec, 10)
    }

    func testRestoreBackupUndoesChange() async throws {
        let store = makeStore()
        await store.update { $0.printing.defaultCopies = 2 }
        await store.update { $0.printing.defaultCopies = 4 }

        let backups = await store.listBackups()
        XCTAssertEqual(backups.count, 1)
        guard let backup = backups.first else {
            XCTFail("应存在自动备份")
            return
        }
        let ok = await store.restoreBackup(named: backup.name)
        XCTAssertTrue(ok)
        let cfg = await store.config
        XCTAssertEqual(cfg.printing.defaultCopies, 2)   // 回到改之前
    }

    func testResetToDefaultsMakesBackupAndResets() async throws {
        let store = makeStore()
        await store.update { $0.imaging.themeName = "wedding"; $0.capture.countdownSec = 10 }

        await store.resetToDefaults()
        let cfg = await store.config
        XCTAssertEqual(cfg, BoothConfig())              // 已回默认

        // 重置前的配置可从备份恢复
        let backups = await store.listBackups()
        XCTAssertEqual(backups.count, 1, "重置前应自动备份一份")
        guard let backup = backups.first else { return }
        let restored = await store.restoreBackup(named: backup.name)
        XCTAssertTrue(restored)
        let after = await store.config
        XCTAssertEqual(after.imaging.themeName, "wedding")
        XCTAssertEqual(after.capture.countdownSec, 10)
    }

    func testResetDoesNotTouchPINFile() async throws {
        // 一键重置只动 config.json，PIN 独立文件不受影响
        let pinURL = tmp.appendingPathComponent("guard.json")
        let pinStore = PINStore(fileURL: pinURL)
        try await pinStore.setPIN("1234", oldPIN: nil)

        let store = makeStore()
        await store.update { $0.capture.countdownSec = 3 }
        await store.resetToDefaults()

        let pinStore2 = PINStore(fileURL: pinURL)
        let ok = await pinStore2.verify("1234")
        XCTAssertTrue(ok, "重置配置不应影响 PIN")
    }

    func testBackupPruneKeepsTen() async throws {
        let store = makeStore()
        // 12 次改动（同秒会覆盖同名备份，强制不同文件名场景由 sleep 处理）
        for i in 0..<12 {
            await store.update { $0.capture.countdownSec = [3, 5, 10][i % 3] }
            try await Task.sleep(nanoseconds: 1_100_000_000)   // 保证秒级时间戳不同
        }
        let backups = await store.listBackups()
        XCTAssertLessThanOrEqual(backups.count, 10, "备份应保留最近 10 份")
        XCTAssertGreaterThanOrEqual(backups.count, 9, "至少保留接近 10 份")
    }

    func testRestoreRejectsPathInjection() async {
        let store = makeStore()
        let ok = await store.restoreBackup(named: "../../etc/passwd")
        XCTAssertFalse(ok)
        let ok2 = await store.restoreBackup(named: "nonexistent.json")
        XCTAssertFalse(ok2)
    }

    func testImportExportRoundTrip() async throws {
        let store = makeStore()
        await store.update { $0.imaging.themeName = "party"; $0.printing.defaultCopies = 3 }

        let exportURL = tmp.appendingPathComponent("export.json")
        try await store.exportConfig(to: exportURL)

        // 改坏配置后导入导出的文件恢复
        await store.update { $0.imaging.themeName = "broken"; $0.printing.defaultCopies = 1 }
        try await store.importConfig(from: exportURL)
        let cfg = await store.config
        XCTAssertEqual(cfg.imaging.themeName, "party")
        XCTAssertEqual(cfg.printing.defaultCopies, 3)
    }
}
