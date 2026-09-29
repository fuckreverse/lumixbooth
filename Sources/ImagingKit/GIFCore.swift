import Foundation
import CoreGraphics
import ImageIO
import UniformTypeIdentifiers
import BoothCore

// ============================================================
// GIF/Boomerang（借鉴 Simplebooth GIF / LumaBooth Boomerang）：
// 连拍原图（拼版模式 4-6 张）→ 等比缩到 ~360px → 正放+倒放循环
// → sessionDir/boomerang.gif（ImageIO kUTTypeGIF，零第三方依赖）。
// QR 链接指向 /photo/{id}.gif 时扫码直接看到动态图。
// ============================================================
enum GIFCore {

    /// boomerang 帧序列构造：正放 + 倒放（首尾帧不重复，循环无缝）
    /// 例：4 张原图 → [1,2,3,4,3,2] 共 6 帧
    static func boomerangIndices(count: Int) -> [Int] {
        guard count >= 2 else { return Array(0..<max(count, 0)) }
        return Array(0..<count) + Array((0..<count - 1).reversed().dropLast())
    }

    /// 编码 GIF（boomerang 循环）
    /// - Parameters:
    ///   - frames: 已解码的原图位图序列（按拍摄顺序）
    ///   - to: 输出路径（boomerang.gif）
    ///   - longEdge: 帧长边（360 平衡体积与清晰度）
    ///   - delaySec: 每帧延迟（0.25s 播放节奏轻快）
    static func encodeBoomerang(frames: [CGImage], to url: URL,
                                longEdge: Int = 360, delaySec: Double = 0.25) throws {
        guard !frames.isEmpty else {
            throw BoothError.imagingFailed("GIF 编码：无输入帧")
        }
        let order = boomerangIndices(count: frames.count)
        guard let dest = CGImageDestinationCreateWithURL(
            url as CFURL, UTType.gif.identifier as CFString, order.count, nil) else {
            throw BoothError.imagingFailed("GIF 目标文件创建失败")
        }
        // 循环播放（0 = 无限循环）
        let loopProps = [kCGImagePropertyGIFLoopCount as String: 0] as CFDictionary
        CGImageDestinationSetProperties(dest, loopProps)

        for idx in order {
            let frame = try scaled(frames[idx], longEdge: longEdge)
            let delay = [kCGImagePropertyGIFDelayTime as String: delaySec] as CFDictionary
            CGImageDestinationAddImage(dest, frame, delay)
        }
        guard CGImageDestinationFinalize(dest) else {
            throw BoothError.imagingFailed("GIF 编码收尾失败")
        }
    }

    /// 等比缩放（长边 longEdge；小图不放大）
    private static func scaled(_ image: CGImage, longEdge target: Int) throws -> CGImage {
        let w = image.width, h = image.height
        let longest = max(w, h)
        guard longest > target else { return image }   // 已够小，不放大
        let scale = CGFloat(target) / CGFloat(longest)
        let size = CGSize(width: max(1, Int(CGFloat(w) * scale)),
                          height: max(1, Int(CGFloat(h) * scale)))
        // 位图上下文手工缩放（避免 CoreImage 细节，GIF 帧小开销可忽略）
        let space = CGColorSpaceCreateDeviceRGB()
        guard let ctx = CGContext(data: nil, width: Int(size.width), height: Int(size.height),
                                  bitsPerComponent: 8, bytesPerRow: 0, space: space,
                                  bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue) else {
            throw BoothError.imagingFailed("GIF 帧缩放失败")
        }
        ctx.interpolationQuality = .high
        ctx.draw(image, in: CGRect(origin: .zero, size: size))
        guard let out = ctx.makeImage() else {
            throw BoothError.imagingFailed("GIF 帧缩放输出失败")
        }
        return out
    }
}
