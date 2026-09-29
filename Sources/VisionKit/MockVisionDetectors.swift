import Foundation
import BoothCore

// ============================================================
// Mock 视觉检测器 — App -mock 演示 / UI 测试用
//  - MockCameraService 的合成渐变图里没有人和手，真实 Vision 检测器
//    永远检不出 → 自动触发链路（armed→gestureWait→countdown）走不通
//  - 这对可编程检测器按配置恒定返回，让演示模式能完整跑自动流程：
//    空格/点击开始 → 姿势"就绪"连续帧 → 手势"命中"连续帧 → 倒计时拍照
//  - 判定节奏（连续帧数防抖）仍由 SessionCoordinator 负责，这里只出单帧结果
// ============================================================

/// 手势 Mock：恒定返回配置的手势（默认 ✌️；置 nil 可演示手势超时路径）
public actor MockGestureDetector: GestureDetecting {

    /// 每帧恒定返回的手势结果
    public var gesture: DetectedGesture?

    public init(gesture: DetectedGesture? = .peace) {
        self.gesture = gesture
    }

    /// 运行期改演示行为（如改成 nil 演示手势超时）
    public func update(gesture: DetectedGesture?) {
        self.gesture = gesture
    }

    public func detectGesture(in jpeg: Data) async -> DetectedGesture? {
        gesture
    }
}

/// 姿势就绪 Mock：恒定返回配置的就绪状态（默认就绪；可置不就绪演示 armed 等待）
public struct MockReadinessDetector: PoseReadinessDetecting {

    /// 每帧恒定返回的就绪结果
    public var readiness: PoseReadiness

    public init(isReady: Bool = true) {
        self.readiness = PoseReadiness(
            humanPresent: isReady, facePresent: isReady,
            faceAreaRatio: isReady ? 0.05 : 0, isReady: isReady)
    }

    public init(readiness: PoseReadiness) {
        self.readiness = readiness
    }

    public func detectReadiness(in jpeg: Data) async -> PoseReadiness {
        readiness
    }
}
