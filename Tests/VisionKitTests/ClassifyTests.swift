import BoothCore
import XCTest
@testable import VisionKit

// ============================================================
// classify 纯函数测试：手工构造关键点坐标，验证三类判定
// ============================================================

final class ClassifyTests: XCTestCase {

    // MARK: - peace ✌️

    func testPeaceGesture() {
        // 食指/中指伸直且张开成 V，无名指/小指收拢，拇指收拢（拇指任意）
        var joints: [HandJoint: CGPoint] = [.wrist: wristPoint]
        extendedFinger(.index, baseX: 0.45, dx: -0.02).forEach { joints[$0] = $1 }
        extendedFinger(.middle, baseX: 0.55, dx: 0.02).forEach { joints[$0] = $1 }
        foldedFinger(.ring, baseX: 0.62).forEach { joints[$0] = $1 }
        foldedFinger(.little, baseX: 0.68).forEach { joints[$0] = $1 }
        foldedThumb().forEach { joints[$0] = $1 }

        XCTAssertEqual(GestureDetector.classify(joints: joints), .peace)
    }

    func testPeaceWithoutThumbJoints() {
        // 拇指关节整体缺失（被遮挡/低置信度被过滤），peace 判定仍应成立
        var joints: [HandJoint: CGPoint] = [.wrist: wristPoint]
        extendedFinger(.index, baseX: 0.45, dx: -0.02).forEach { joints[$0] = $1 }
        extendedFinger(.middle, baseX: 0.55, dx: 0.02).forEach { joints[$0] = $1 }
        foldedFinger(.ring, baseX: 0.62).forEach { joints[$0] = $1 }
        foldedFinger(.little, baseX: 0.68).forEach { joints[$0] = $1 }

        XCTAssertEqual(GestureDetector.classify(joints: joints), .peace)
    }

    // MARK: - openPalm 张开手掌

    func testOpenPalmGesture() {
        // 四指 + 拇指全部伸直
        var joints: [HandJoint: CGPoint] = [.wrist: wristPoint]
        extendedFinger(.index, baseX: 0.42, dx: -0.03).forEach { joints[$0] = $1 }
        extendedFinger(.middle, baseX: 0.49, dx: 0).forEach { joints[$0] = $1 }
        extendedFinger(.ring, baseX: 0.55, dx: 0.03).forEach { joints[$0] = $1 }
        extendedFinger(.little, baseX: 0.61, dx: 0.05).forEach { joints[$0] = $1 }
        extendedThumb().forEach { joints[$0] = $1 }

        XCTAssertEqual(GestureDetector.classify(joints: joints), .openPalm)
    }

    // MARK: - 均不构成已知手势

    func testFistIsNothing() {
        // 握拳：五指全收拢
        var joints: [HandJoint: CGPoint] = [.wrist: wristPoint]
        foldedFinger(.index, baseX: 0.46).forEach { joints[$0] = $1 }
        foldedFinger(.middle, baseX: 0.52).forEach { joints[$0] = $1 }
        foldedFinger(.ring, baseX: 0.58).forEach { joints[$0] = $1 }
        foldedFinger(.little, baseX: 0.64).forEach { joints[$0] = $1 }
        foldedThumb().forEach { joints[$0] = $1 }

        XCTAssertNil(GestureDetector.classify(joints: joints))
    }

    func testPeaceWithFingersTouchingIsNothing() {
        // 食指/中指伸直但并拢（不成 V 字）→ 既非 peace 也非 openPalm
        var joints: [HandJoint: CGPoint] = [.wrist: wristPoint]
        extendedFinger(.index, baseX: 0.47, dx: 0).forEach { joints[$0] = $1 }
        extendedFinger(.middle, baseX: 0.53, dx: 0).forEach { joints[$0] = $1 }
        foldedFinger(.ring, baseX: 0.60).forEach { joints[$0] = $1 }
        foldedFinger(.little, baseX: 0.66).forEach { joints[$0] = $1 }

        XCTAssertNil(GestureDetector.classify(joints: joints))
    }

    func testFourFingersWithoutThumbIsNothing() {
        // 四指伸直但拇指收拢：不满足 peace（无名/小指伸直）也不满足 openPalm（拇指没伸）
        var joints: [HandJoint: CGPoint] = [.wrist: wristPoint]
        extendedFinger(.index, baseX: 0.44, dx: -0.02).forEach { joints[$0] = $1 }
        extendedFinger(.middle, baseX: 0.52, dx: 0).forEach { joints[$0] = $1 }
        extendedFinger(.ring, baseX: 0.58, dx: 0.03).forEach { joints[$0] = $1 }
        extendedFinger(.little, baseX: 0.64, dx: 0.05).forEach { joints[$0] = $1 }
        foldedThumb().forEach { joints[$0] = $1 }

        XCTAssertNil(GestureDetector.classify(joints: joints))
    }

    // MARK: - 关键点缺失

    func testMissingWristReturnsNil() {
        var joints: [HandJoint: CGPoint] = [:]
        extendedFinger(.index, baseX: 0.45, dx: 0).forEach { joints[$0] = $1 }
        extendedFinger(.middle, baseX: 0.55, dx: 0).forEach { joints[$0] = $1 }
        // 无 wrist
        XCTAssertNil(GestureDetector.classify(joints: joints))
    }

    func testMissingRequiredFingerJointsReturnsNil() {
        // 无名指/小指关键点缺失 → 无法确认收拢状态 → nil
        var joints: [HandJoint: CGPoint] = [.wrist: wristPoint]
        extendedFinger(.index, baseX: 0.45, dx: -0.02).forEach { joints[$0] = $1 }
        extendedFinger(.middle, baseX: 0.55, dx: 0.02).forEach { joints[$0] = $1 }

        XCTAssertNil(GestureDetector.classify(joints: joints))
    }

    func testEmptyJointsReturnsNil() {
        XCTAssertNil(GestureDetector.classify(joints: [:]))
    }

    // MARK: - 阈值参数

    func testExtendedRatioIsAdjustable() {
        // 同一组伸直手指：ratio 调到 4.0 后（0.55/0.15 ≈ 3.67）应判为不伸直
        var joints: [HandJoint: CGPoint] = [.wrist: wristPoint]
        extendedFinger(.index, baseX: 0.45, dx: -0.02).forEach { joints[$0] = $1 }
        extendedFinger(.middle, baseX: 0.55, dx: 0.02).forEach { joints[$0] = $1 }
        foldedFinger(.ring, baseX: 0.62).forEach { joints[$0] = $1 }
        foldedFinger(.little, baseX: 0.68).forEach { joints[$0] = $1 }

        XCTAssertEqual(GestureDetector.classify(joints: joints), .peace)   // 默认 1.5
        XCTAssertNil(GestureDetector.classify(joints: joints, extendedRatio: 4.0))
    }
}
