import BoothCore
import CoreGraphics
import Foundation
import Vision

// ============================================================
// PoseReadinessDetector —— 姿势就绪检测（同帧人体 + 人脸）
//  - VNDetectHumanRectanglesRequest + VNDetectFaceRectanglesRequest
//    挂同一个 VNImageRequestHandler 一次 perform，保证同帧一致
//  - 输出 PoseReadiness：有人体 && 有人脸 && 最大人脸面积占比 >= 阈值
//  - 阈值走构造参数（默认与 VisionConf.minFaceAreaRatio 一致），
//    纯检测器不读 ConfigStore；连续 15 帧防抖由 SessionEngine 负责
//  - 并发：同 GestureDetector，Vision 放 Task.detached
// ============================================================

public struct PoseReadinessDetector: PoseReadinessDetecting, Sendable {

    /// 人脸最小面积占比阈值（面积/画面面积），默认 0.01
    public var minFaceAreaRatio: Double

    public init(minFaceAreaRatio: Double = 0.01) {
        self.minFaceAreaRatio = minFaceAreaRatio
    }

    // MARK: - PoseReadinessDetecting

    public func detectReadiness(in jpeg: Data) async -> PoseReadiness {
        let start = CFAbsoluteTimeGetCurrent()

        guard let raw = FrameImage.decode(jpeg: jpeg) else {
            Log.vision.debug("就绪：JPEG 解码失败，返回 not ready")
            return .empty
        }
        let image = FrameImage.downscaleForDetection(raw)

        let result = await Task.detached(priority: .userInitiated) {
            self.performReadiness(image: image)
        }.value

        let total = CFAbsoluteTimeGetCurrent() - start
        Log.vision.debug("就绪检测：human=\(result.humanPresent) face=\(result.facePresent) 占比=\(String(format: "%.4f", result.faceAreaRatio)) ready=\(result.isReady)，耗时 \(String(format: "%.1f", total * 1000))ms")
        return result
    }

    // MARK: - Vision 请求（detached 线程，返回 Sendable）

    private func performReadiness(image: CGImage) -> PoseReadiness {
        let humanRequest = VNDetectHumanRectanglesRequest()
        let faceRequest = VNDetectFaceRectanglesRequest()
        let handler = VNImageRequestHandler(cgImage: image, options: [:])
        do {
            try handler.perform([humanRequest, faceRequest])
        } catch {
            Log.vision.debug("就绪：Vision 请求失败 \(error.localizedDescription)")
            return .empty
        }

        let humanPresent = !(humanRequest.results ?? []).isEmpty
        let faces = faceRequest.results ?? []

        // boundingBox 为归一化（0...1，原点左下），w*h 直接就是面积占比
        var faceAreaRatio = 0.0
        if let largest = faces.map({ $0.boundingBox.width * $0.boundingBox.height }).max() {
            faceAreaRatio = Double(largest)
        }
        let facePresent = !faces.isEmpty
        let isReady = humanPresent && facePresent && faceAreaRatio >= minFaceAreaRatio

        return PoseReadiness(humanPresent: humanPresent,
                             facePresent: facePresent,
                             faceAreaRatio: faceAreaRatio,
                             isReady: isReady)
    }
}
