import BoothCore
import CoreGraphics
import CoreVideo
import Foundation
import Vision

// ============================================================
// PersonSegmenter —— 人像分割（成片换背景用）
//  - VNGeneratePersonSegmentationRequest：qualityLevel=.accurate，
//    outputPixelFormat=kCVPixelFormatType_OneComponent8（8bit 灰度）
//  - 输入 CGImage，输出与输入同尺寸的 8bit 灰度 matte CGImage
//    （Vision 返回的 matte 分辨率低于原图，统一用 CoreGraphics 重绘放大）
//  - 画面无人：不抛错，返回同尺寸全黑 matte（记 debug 日志）
//  - 仅在 PROCESSING 对成片跑一次，不在 LiveView 帧流中调用
// ============================================================

public struct PersonSegmenter: PersonSegmenting, Sendable {

    /// matte 像素噪声底：最大值不高于该阈值判为"画面无人"，输出全黑
    /// （实测 Vision 对纯色空场景会返回最大值个位数的噪声 matte，不能原样当人像）
    public var noiseFloor: UInt8

    public init(noiseFloor: UInt8 = 16) {
        self.noiseFloor = noiseFloor
    }

    // MARK: - PersonSegmenting

    public func segmentationMask(for image: CGImage) async throws -> CGImage {
        let start = CFAbsoluteTimeGetCurrent()

        // 分割针对成片原图，不做降采样（保 matte 细节）
        let mask = try await Task.detached(priority: .userInitiated) {
            try self.performSegmentation(image)
        }.value

        let total = CFAbsoluteTimeGetCurrent() - start
        Log.vision.debug("分割完成 \(mask.width)×\(mask.height)，耗时 \(String(format: "%.0f", total * 1000))ms")
        return mask
    }

    // MARK: - Vision 请求（detached 线程）

    /// 同步执行分割请求；VNDetectHumanRectanglesRequest 无人体/无观察结果不抛错
    private func performSegmentation(_ image: CGImage) throws -> CGImage {
        let request = VNGeneratePersonSegmentationRequest()
        request.qualityLevel = .accurate
        request.outputPixelFormat = kCVPixelFormatType_OneComponent8

        let handler = VNImageRequestHandler(cgImage: image, options: [:])
        try handler.perform([request])

        guard let observation = request.results?.first else {
            // 无人：不报错，输出全黑 matte
            Log.vision.debug("分割：画面未检出人物，输出全黑 matte")
            return Self.blackMatte(width: image.width, height: image.height)
        }

        let buffer = observation.pixelBuffer
        let maxValue = Self.scanMaxValue(buffer)
        if maxValue <= noiseFloor {
            // 无人 / 只有模型噪声：不报错，输出全黑 matte
            Log.vision.debug("分割：matte 最大像素值 \(maxValue) 不高于噪声底 \(noiseFloor)，判为画面无人，输出全黑")
            return Self.blackMatte(width: image.width, height: image.height)
        }

        guard let scaled = Self.scaleMatte(buffer, toWidth: image.width, height: image.height) else {
            // 兜底：matte 像素缓冲转 CGImage 失败时给全黑（换背景管线自身有降级逻辑）
            Log.vision.debug("分割：matte 缩放失败，兜底输出全黑")
            return Self.blackMatte(width: image.width, height: image.height)
        }
        return scaled
    }

    // MARK: - 像素缓冲工具

    /// OneComponent8 像素缓冲 → 同目标尺寸灰度 CGImage（重绘等比缩放）
    private static func scaleMatte(_ buffer: CVPixelBuffer, toWidth w: Int, height h: Int) -> CGImage? {
        CVPixelBufferLockBaseAddress(buffer, .readOnly)
        defer { CVPixelBufferUnlockBaseAddress(buffer, .readOnly) }

        guard let base = CVPixelBufferGetBaseAddress(buffer) else { return nil }
        let bw = CVPixelBufferGetWidth(buffer)
        let bh = CVPixelBufferGetHeight(buffer)
        let rowBytes = CVPixelBufferGetBytesPerRow(buffer)
        guard bw > 0, bh > 0 else { return nil }

        // 像素缓冲内存第 0 行即画面顶部，直接包成 CGContext 不会上下翻转
        guard let graySpace = CGColorSpace(name: CGColorSpace.genericGrayGamma2_2) else { return nil }
        guard let srcCtx = CGContext(
            data: base,
            width: bw, height: bh,
            bitsPerComponent: 8, bytesPerRow: rowBytes,
            space: graySpace,
            bitmapInfo: CGImageAlphaInfo.none.rawValue
        ), let src = srcCtx.makeImage() else { return nil }

        // 缩放到与输入原图同尺寸（Vision matte 通常小于原图）
        guard let dstCtx = FrameImage.makeGrayContext(width: w, height: h) else { return nil }
        dstCtx.interpolationQuality = .high   // 成片用，matte 边缘放大要平滑
        dstCtx.draw(src, in: CGRect(x: 0, y: 0, width: CGFloat(w), height: CGFloat(h)))
        return dstCtx.makeImage()
    }

    /// 扫描 matte 像素最大值（0 = 全黑，用于"无人"日志判定）
    private static func scanMaxValue(_ buffer: CVPixelBuffer) -> UInt8 {
        CVPixelBufferLockBaseAddress(buffer, .readOnly)
        defer { CVPixelBufferUnlockBaseAddress(buffer, .readOnly) }
        guard let base = CVPixelBufferGetBaseAddress(buffer)?.assumingMemoryBound(to: UInt8.self) else { return 0 }
        let height = CVPixelBufferGetHeight(buffer)
        let rowBytes = CVPixelBufferGetBytesPerRow(buffer)
        var maxValue: UInt8 = 0
        for row in 0..<height {
            let line = base + row * rowBytes
            for col in 0..<CVPixelBufferGetWidth(buffer) {
                let v = line[col]
                if v > maxValue { maxValue = v }
                if maxValue == 255 { return 255 }   // 提前退出
            }
        }
        return maxValue
    }

    /// 同尺寸全黑 matte（画面无人时的合法输出）
    private static func blackMatte(width: Int, height: Int) -> CGImage {
        // makeGrayContext 默认像素清零，直接出图
        if let ctx = FrameImage.makeGrayContext(width: width, height: height),
           let img = ctx.makeImage() {
            return img
        }
        // 理论不可达兜底：1×1 黑像素
        return blackFallback
    }

    private static let blackFallback: CGImage = {
        let ctx = CGContext(
            data: nil, width: 1, height: 1,
            bitsPerComponent: 8, bytesPerRow: 0,
            space: CGColorSpace(name: CGColorSpace.genericGrayGamma2_2)!,
            bitmapInfo: CGImageAlphaInfo.none.rawValue
        )!
        return ctx.makeImage()!
    }()
}
