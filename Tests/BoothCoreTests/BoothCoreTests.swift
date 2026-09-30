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

    // MARK: - 新契约（PhotoBoothProject 借鉴）

    func testCollageLayoutMetadata() {
        XCTAssertEqual(CollageLayout.strip.columns, 1)
        XCTAssertEqual(CollageLayout.grid2x2.columns, 2)
        XCTAssertEqual(CollageLayout.duo.columns, 1)
        XCTAssertEqual(CollageLayout.trio.columns, 1)
        XCTAssertEqual(CollageLayout.onePlusThree.columns, 3)
        XCTAssertEqual(CollageLayout.strip.recommendedShots, 4)
        XCTAssertEqual(CollageLayout.grid2x2.recommendedShots, 4)
        XCTAssertEqual(CollageLayout.duo.recommendedShots, 2)
        XCTAssertEqual(CollageLayout.trio.recommendedShots, 3)
        XCTAssertEqual(CollageLayout.onePlusThree.recommendedShots, 4)
        XCTAssertEqual(CollageLayout.allCases.count, 5)
        // 拍后选片：新布局需选满张数，strip 全上
        XCTAssertNil(CollageLayout.strip.requiredShots)
        XCTAssertEqual(CollageLayout.grid2x2.requiredShots, 4)
        XCTAssertEqual(CollageLayout.onePlusThree.requiredShots, 4)
        XCTAssertEqual(CollageLayout.trio.requiredShots, 3)
        XCTAssertEqual(CollageLayout.duo.requiredShots, 2)
    }

    func testPhotoFilterParse() {
        XCTAssertEqual(PhotoFilter.parse("vivid"), .vivid)
        XCTAssertEqual(PhotoFilter.parse("warm"), .warm)
        XCTAssertEqual(PhotoFilter.parse(nil), .none)
        XCTAssertEqual(PhotoFilter.parse(""), .none)
        XCTAssertEqual(PhotoFilter.parse("no-such-filter"), .none, "非法值应安全回退 .none")
        XCTAssertEqual(PhotoFilter.parse("glam"), .glam, "新增 glam 档位应可解析")
        XCTAssertEqual(PhotoFilter.parse("vintage"), .vintage, "新增 vintage 档位应可解析")
        XCTAssertEqual(PhotoFilter.parse("fuji"), .fuji, "新增 fuji 档位应可解析")
        XCTAssertEqual(PhotoFilter.allCases.count, 9)
    }

    /// 旧版 config.json（v1 无任何新字段）：解码全部走默认值不崩
    func testLegacyConfigJSONDecodesWithDefaults() throws {
        // 一份旧 schema 的配置（只有最早版本就有的字段）
        let legacy = """
        {
          "capture": {
            "countdownSec": 5,
            "defaultMode": { "kind": "collage", "shots": 4 },
            "reviewTimeoutSec": 30,
            "autoPrintOnTimeout": true
          },
          "vision": { "gestureEnabled": true, "poseReadinessEnabled": true, "gestureHitFrames": 3,
                      "readyFrames": 5, "minFaceAreaRatio": 0.01, "detectEveryNFrames": 3 },
          "imaging": {
            "autoColor": true, "skinSmoothing": true, "replaceBackground": false,
            "frame": true, "dateWatermark": true, "themeName": "party"
          },
          "printing": {
            "printerName": "", "defaultCopies": 2, "minCopies": 1, "maxCopies": 4,
            "paperWidthMM": 101.6, "paperHeightMM": 152.4, "borderless": true, "dedupeWindowSec": 5
          },
          "server": { "enabled": true, "port": 8080, "liveViewToIpad": true, "ipadMaxFPS": 10 },
          "camera": { "dylibPath": "", "captureTimeoutSec": 10, "captureRetry": 1,
                      "reconnectBaseDelaySec": 1, "reconnectMaxDelaySec": 15, "liveViewBufferSize": 1048576 }
        }
        """
        let cfg = try JSONDecoder().decode(BoothConfig.self, from: Data(legacy.utf8))
        // 拍摄段新字段默认值
        XCTAssertEqual(cfg.capture.continuousCollage, false)
        XCTAssertEqual(cfg.capture.idleSlideshow, true)
        XCTAssertEqual(cfg.capture.idleSlideshowSec, 6)
        XCTAssertEqual(cfg.capture.defaultMode.layout, .strip, "旧 mode 无 layout 应回退 strip")
        // 视觉段：旧帧数字段（readyFrames/gestureHitFrames）已废弃，
        // 缺新时长字段应回落默认值
        XCTAssertEqual(cfg.vision.readyStableMs, 1200)
        XCTAssertEqual(cfg.vision.gestureStableMs, 350)
        XCTAssertEqual(cfg.vision.absentStableMs, 1000)
        // 修图段新字段默认值
        XCTAssertEqual(cfg.imaging.filterSelection, true)
        XCTAssertEqual(cfg.imaging.defaultFilter, .none)
        // 打印段新字段默认值
        XCTAssertEqual(cfg.printing.printQRCode, true)
        XCTAssertEqual(cfg.printing.autoPrintDelaySec, 0)
        XCTAssertEqual(cfg.printing.printingDwellSec, 3)
        XCTAssertEqual(cfg.printing.printKeyEnabled, true)
        XCTAssertEqual(cfg.printing.showPrintButton, true)
        // 旧字段读取正常
        XCTAssertEqual(cfg.capture.countdownSec, 5)
        XCTAssertEqual(cfg.imaging.themeName, "party")
        XCTAssertEqual(cfg.printing.defaultCopies, 2)
    }

    /// 新字段显式编码：round-trip 保持
    func testNewConfigFieldsRoundTrip() throws {
        var cfg = BoothConfig()
        cfg.capture.continuousCollage = true
        cfg.capture.idleSlideshowSec = 10
        cfg.capture.defaultMode = .collage(4, layout: .grid2x2)
        cfg.imaging.filterSelection = false
        cfg.imaging.defaultFilter = .nostalgia
        cfg.printing.printQRCode = false
        cfg.printing.autoPrintDelaySec = 5
        cfg.printing.printingDwellSec = 8
        cfg.printing.printKeyEnabled = false
        cfg.printing.showPrintButton = false
        cfg.vision.readyStableMs = 800
        cfg.vision.gestureStableMs = 200
        cfg.vision.absentStableMs = 600
        let data = try JSONEncoder().encode(cfg)
        let back = try JSONDecoder().decode(BoothConfig.self, from: data)
        XCTAssertEqual(back, cfg)
        XCTAssertEqual(back.capture.defaultMode.layout, .grid2x2)
        XCTAssertEqual(back.imaging.defaultFilter, .nostalgia)
        XCTAssertEqual(back.printing.printingDwellSec, 8)
        XCTAssertEqual(back.vision.readyStableMs, 800)
        XCTAssertEqual(back.vision.gestureStableMs, 200)
        XCTAssertEqual(back.vision.absentStableMs, 600)
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
