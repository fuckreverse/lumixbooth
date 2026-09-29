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
}
