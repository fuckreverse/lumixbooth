import BoothCore
import CoreGraphics
import Foundation
import Vision

// ============================================================
// FaceLandmarkDetector —— 人脸关键点检测（搞怪装饰用）
//  - VNDetectFaceLandmarksRequest：一次请求出全部人脸 + 76 点关键点
//  - 检测前降采样到 maxDetectionEdge（关键点用于贴纸/形变锚点，
//    960px 精度足够，6000px 成片原图直检太慢）
//  - 输出 FaceGeometry：原图像素坐标、原点左下、y 向上
//    （归一化坐标 × 原图尺寸，与分辨率无关，无需缩放回算）
//  - 无人脸：不抛错返回空数组（装饰算子自行降级）
//  - 仅在 PROCESSING 对成片跑一次，不在 LiveView 帧流中调用
//  - 说明：Vision 关键点以人脸框为基准（不含 roll 旋转修正），
//    倾斜头部时锚点有轻微偏差，贴纸级用途可接受
// ============================================================

public struct FaceLandmarkDetector: FaceLandmarking, Sendable {

    public init() {}

    // MARK: - FaceLandmarking

    public func detectFaces(in image: CGImage) async throws -> [FaceGeometry] {
        let start = CFAbsoluteTimeGetCurrent()

        // 降采样后检测（关键点精度足够锚点用途）
        let small = FrameImage.downscaleForDetection(image)
        let faces = try await Task.detached(priority: .userInitiated) {
            try Self.performDetection(small, fullWidth: image.width, fullHeight: image.height)
        }.value

        let total = CFAbsoluteTimeGetCurrent() - start
        Log.vision.debug("人脸关键点完成 检出\(faces.count)张脸，耗时 \(String(format: "%.0f", total * 1000))ms")
        return faces
    }

    // MARK: - Vision 请求（detached 线程）

    /// 同步执行关键点检测；归一化坐标直接乘原图尺寸换算回原像素
    private static func performDetection(_ image: CGImage, fullWidth: Int, fullHeight: Int) throws -> [FaceGeometry] {
        let request = VNDetectFaceLandmarksRequest()
        let handler = VNImageRequestHandler(cgImage: image, options: [:])
        try handler.perform([request])

        guard let observations = request.results, !observations.isEmpty else { return [] }

        let w = CGFloat(fullWidth)
        let h = CGFloat(fullHeight)
        return observations.map { obs in
            // 人脸框：归一化（原点左下）→ 原图像素
            let box = obs.boundingBox
            let rect = CGRect(
                x: box.origin.x * w, y: box.origin.y * h,
                width: box.width * w, height: box.height * h)

            // 关键点：以人脸框为基准的归一化坐标 → 框内偏移 → 原图像素
            func regionPoints(_ region: VNFaceLandmarkRegion2D?) -> [CGPoint]? {
                guard let region, !region.normalizedPoints.isEmpty else { return nil }
                return region.normalizedPoints.map {
                    CGPoint(x: (box.origin.x + $0.x * box.width) * w,
                            y: (box.origin.y + $0.y * box.height) * h)
                }
            }

            var points: [FaceGeometry.Region: [CGPoint]] = [:]
            let l = obs.landmarks
            points[.faceContour] = regionPoints(l?.faceContour)
            points[.leftEye] = regionPoints(l?.leftEye)
            points[.rightEye] = regionPoints(l?.rightEye)
            points[.leftEyebrow] = regionPoints(l?.leftEyebrow)
            points[.rightEyebrow] = regionPoints(l?.rightEyebrow)
            points[.nose] = regionPoints(l?.nose)
            points[.outerLips] = regionPoints(l?.outerLips)
            points[.innerLips] = regionPoints(l?.innerLips)

            // roll 角：Vision 给的是角度（度），统一转弧度
            let roll = (obs.roll?.doubleValue ?? 0) * .pi / 180

            return FaceGeometry(rect: rect, rollAngle: roll, points: points)
        }
    }
}
