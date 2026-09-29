import XCTest
@testable import BoothCore

final class BoothCoreTests: XCTestCase {
    func testShootMode() {
        XCTAssertEqual(ShootMode.single.shots, 1)
        XCTAssertEqual(ShootMode.collage().shots, 4)
    }

    func testConfigDefaultRoundTrip() throws {
        let cfg = BoothConfig()
        let data = try JSONEncoder().encode(cfg)
        let back = try JSONDecoder().decode(BoothConfig.self, from: data)
        XCTAssertEqual(cfg, back)
        XCTAssertEqual(back.printing.defaultCopies, 2)
        XCTAssertEqual(back.capture.defaultMode, .collage(4))
    }

    func testEventBusBroadcast() async {
        let bus = EventBus()
        let stream = await bus.stream(replayLatest: false)
        await bus.publish(.stateChanged(.idle))
        var it = stream.makeAsyncIterator()
        let e = await it.next()
        XCTAssertEqual(e, .stateChanged(.idle))
    }

    func testLogWritesFile() {
        Log.core.info("单测日志写入")
        XCTAssertTrue(FileManager.default.fileExists(atPath: LogStore.shared.currentLogFile.path))
    }

    /// 老 config.json（无 dryRun 等新字段）必须能解码，缺省字段回落默认值
    func testPrintConfLegacyDecoding() throws {
        let legacy = """
        {"printerName":"EPSON_L805","defaultCopies":3,"minCopies":1,"maxCopies":4,
         "paperWidthMM":101.6,"paperHeightMM":152.4,"borderless":false,"dedupeWindowSec":5}
        """.data(using: .utf8)!
        let conf = try JSONDecoder().decode(BoothConfig.PrintConf.self, from: legacy)
        XCTAssertEqual(conf.printerName, "EPSON_L805", "已有字段保留")
        XCTAssertEqual(conf.defaultCopies, 3)
        XCTAssertFalse(conf.borderless)
        XCTAssertFalse(conf.dryRun, "新增字段缺省回落默认值 false")
    }
}
