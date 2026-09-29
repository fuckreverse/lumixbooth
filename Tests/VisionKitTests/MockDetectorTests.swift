import XCTest
import BoothCore
@testable import VisionKit

// ============================================================
// Mock 视觉检测器单测（-mock 演示链路用）
// ============================================================

final class MockDetectorTests: XCTestCase {

    func testMockGestureReturnsConfiguredGesture() async {
        let peace = MockGestureDetector(gesture: .peace)
        let g1 = await peace.detectGesture(in: Data())
        XCTAssertEqual(g1, .peace)

        let none = MockGestureDetector(gesture: nil)
        let g2 = await none.detectGesture(in: Data())
        XCTAssertNil(g2, "置 nil 时应恒定检不出（演示手势超时路径）")

        // 可编程：运行期改配置即生效
        await peace.update(gesture: .openPalm)
        let g3 = await peace.detectGesture(in: Data())
        XCTAssertEqual(g3, .openPalm)
    }

    func testMockReadinessReturnsConfiguredState() async {
        let ready = MockReadinessDetector(isReady: true)
        let r1 = await ready.detectReadiness(in: Data())
        XCTAssertTrue(r1.isReady)
        XCTAssertTrue(r1.humanPresent)
        XCTAssertTrue(r1.facePresent)
        XCTAssertGreaterThan(r1.faceAreaRatio, 0)

        let notReady = MockReadinessDetector(isReady: false)
        let r2 = await notReady.detectReadiness(in: Data())
        XCTAssertFalse(r2.isReady)
        XCTAssertFalse(r2.humanPresent)
    }
}
