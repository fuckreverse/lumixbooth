import BoothCore
import CoreGraphics
import Foundation
import ImageIO

// ============================================================
// 图像解码与降采样（LiveView 帧进入 Vision 前的统一预处理）
//  - JPEG Data → CGImage：只依赖系统框架（ImageIO 属 CoreGraphics 解码栈）
//  - 方向：LiveView 帧由相机端已转正，按 .up 处理，不应用 EXIF 旋转
//  - 性能：检测前降采样到最长边 maxDetectionEdge（默认 960），
//    用 CoreGraphics 重绘（kCGImageSourceShouldCache=false 避免缓存抖动）
// ============================================================

enum FrameImage {

    /// LiveView 帧检测前的最长边上限（控 Vision 推理耗时）
    static let maxDetectionEdge: CGFloat = 960

    /// JPEG Data → CGImage。
    /// 解码返回原始像素（macOS ImageIO 默认不应用 EXIF 方向），
    /// 再读元数据里的 kCGImagePropertyOrientation，非 .up 的帧手动旋转/镜像归一化。
    /// 相机 LiveView 帧本身已是 .up，归一化步骤通常为空操作。
    static func decode(jpeg: Data) -> CGImage? {
        guard let src = CGImageSourceCreateWithData(
            jpeg as CFData,
            [kCGImageSourceShouldCache: false] as CFDictionary
        ) else { return nil }
        guard let img = CGImageSourceCreateImageAtIndex(src, 0, [kCGImageSourceShouldCacheImmediately: true] as CFDictionary) else {
            return nil
        }
        let props = CGImageSourceCopyPropertiesAtIndex(src, 0, nil) as? [CFString: Any]
        let rawOrientation = props?[kCGImagePropertyOrientation] as? UInt32 ?? 1
        let orientation = CGImagePropertyOrientation(rawValue: rawOrientation) ?? .up
        return normalizeOrientation(img, orientation: orientation)
    }

    /// 把任意 EXIF 方向的像素重绘为 .up（LiveView 帧为 .up 时直接原样返回）
    private static func normalizeOrientation(_ image: CGImage, orientation: CGImagePropertyOrientation) -> CGImage {
        guard orientation != .up else { return image }
        Log.vision.debug("解码：帧 EXIF 方向为 \(orientation.rawValue)，重绘归一化到 .up")

        // 交换宽高的旋转方向
        let swapped: [CGImagePropertyOrientation] = [.right, .left, .rightMirrored, .leftMirrored]
        let w = swapped.contains(orientation) ? image.height : image.width
        let h = swapped.contains(orientation) ? image.width : image.height

        guard let ctx = CGContext(
            data: nil, width: w, height: h,
            bitsPerComponent: 8, bytesPerRow: 0,
            space: CGColorSpace(name: CGColorSpace.sRGB)!,
            bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue
        ) else { return image }

        // CGContext 原点在左下，直接用 transform 重放 EXIF 八方向
        ctx.translateBy(x: CGFloat(w) / 2, y: CGFloat(h) / 2)
        switch orientation {
        case .up: break
        case .upMirrored: ctx.scaleBy(x: -1, y: 1)
        case .down: ctx.rotate(by: .pi)
        case .downMirrored: ctx.scaleBy(x: -1, y: 1); ctx.rotate(by: .pi)
        case .left: ctx.rotate(by: .pi / 2)
        case .leftMirrored: ctx.scaleBy(x: -1, y: 1); ctx.rotate(by: .pi / 2)
        case .right: ctx.rotate(by: -.pi / 2)
        case .rightMirrored: ctx.scaleBy(x: -1, y: 1); ctx.rotate(by: -.pi / 2)
        }
        ctx.draw(image, in: CGRect(x: -CGFloat(image.width) / 2, y: -CGFloat(image.height) / 2,
                                  width: CGFloat(image.width), height: CGFloat(image.height)))
        return ctx.makeImage() ?? image
    }

    /// 检测前降采样：最长边 > maxEdge 时用 CoreGraphics 重绘缩放。
    /// 等比缩放不改方向、不改纵横比，直接缩放不裁剪。
    static func downscaleForDetection(_ image: CGImage, maxEdge: CGFloat = FrameImage.maxDetectionEdge) -> CGImage {
        let w = CGFloat(image.width)
        let h = CGFloat(image.height)
        guard w > 0, h > 0, max(w, h) > maxEdge else { return image }

        let scale = maxEdge / max(w, h)
        let nw = max(1, Int((w * scale).rounded()))
        let nh = max(1, Int((h * scale).rounded()))

        guard let ctx = CGContext(
            data: nil,
            width: nw, height: nh,
            bitsPerComponent: 8, bytesPerRow: 0,
            space: CGColorSpace(name: CGColorSpace.sRGB)!,
            bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue   // 等效 BGRA
        ) else { return image }

        ctx.interpolationQuality = .medium   // 降采样用中等质量即可，速度优先
        ctx.draw(image, in: CGRect(x: 0, y: 0, width: CGFloat(nw), height: CGFloat(nh)))
        return ctx.makeImage() ?? image
    }

    /// 生成一张与指定尺寸相同的纯灰度上下文（matte 缩放/兜底用）
    static func makeGrayContext(width: Int, height: Int) -> CGContext? {
        CGContext(
            data: nil,
            width: width, height: height,
            bitsPerComponent: 8, bytesPerRow: 0,
            space: CGColorSpace(name: CGColorSpace.genericGrayGamma2_2)!,
            bitmapInfo: CGImageAlphaInfo.none.rawValue
        )
    }
}
