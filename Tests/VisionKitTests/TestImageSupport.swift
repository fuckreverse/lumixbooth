import CoreGraphics
import Foundation
import ImageIO
import UniformTypeIdentifiers
@testable import VisionKit

// ============================================================
// 测试公用工具：程序合成 CGImage / JPEG，手工构造手部关键点字典
// （测试资源全部运行时生成，不依赖外置图片，测试不接相机也能全绿）
// ============================================================

/// 生成一张给定背景色、可叠画的 CGImage
func makeImage(width: Int, height: Int, background: (r: CGFloat, g: CGFloat, b: CGFloat),
               draw: ((CGContext, Int, Int) -> Void)? = nil) -> CGImage? {
    guard let ctx = CGContext(
        data: nil, width: width, height: height,
        bitsPerComponent: 8, bytesPerRow: 0,
        space: CGColorSpace(name: CGColorSpace.sRGB)!,
        bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue
    ) else { return nil }
    ctx.setFillColor(red: background.r, green: background.g, blue: background.b, alpha: 1)
    ctx.fill(CGRect(x: 0, y: 0, width: width, height: height))
    draw?(ctx, width, height)
    return ctx.makeImage()
}

/// CGImage → JPEG Data（与生产解码路径对称的编码工具）
func encodeJPEG(_ image: CGImage) -> Data {
    let data = NSMutableData()
    guard let dest = CGImageDestinationCreateWithData(
        data, UTType.jpeg.identifier as CFString, 1, nil
    ) else {
        fatalError("JPEG 编码器创建失败")
    }
    CGImageDestinationAddImage(dest, image, nil)
    guard CGImageDestinationFinalize(dest) else {
        fatalError("JPEG 编码失败")
    }
    return data as Data
}

// MARK: - 手部关键点构造（归一化坐标，原点左下，y 向上）

/// 构造一根伸直的手指：MCP→PIP→DIP→Tip 逐级远离腕部
/// - Parameters:
///   - baseX: MCP 的 x 坐标
///   - dx: 指尖相对 MCP 的 x 张开量（体现手指张开方向）
func extendedFinger(_ finger: Finger, baseX: CGFloat, dx: CGFloat) -> [HandJoint: CGPoint] {
    let mcp = CGPoint(x: baseX, y: 0.25)
    let pip = CGPoint(x: baseX + dx * 0.4, y: 0.40)
    let dip = CGPoint(x: baseX + dx * 0.7, y: 0.52)
    let tip = CGPoint(x: baseX + dx, y: 0.65)
    return [finger.mcp: mcp, joint(finger, "PIP"): pip, joint(finger, "DIP"): dip, finger.tip: tip]
}

/// 构造一根收拢的手指：指尖折回掌侧（tip 到 wrist 的距离 ≈ MCP 距离）
func foldedFinger(_ finger: Finger, baseX: CGFloat) -> [HandJoint: CGPoint] {
    let mcp = CGPoint(x: baseX, y: 0.25)
    let pip = CGPoint(x: baseX + 0.02, y: 0.30)
    let dip = CGPoint(x: baseX + 0.01, y: 0.24)
    let tip = CGPoint(x: baseX, y: 0.18)
    return [finger.mcp: mcp, joint(finger, "PIP"): pip, joint(finger, "DIP"): dip, finger.tip: tip]
}

/// 拇指（关节命名与四指不同：CMC/MP/IP/Tip）
func extendedThumb() -> [HandJoint: CGPoint] {
    [.thumbCMC: CGPoint(x: 0.53, y: 0.14),
     .thumbMP: CGPoint(x: 0.60, y: 0.22),
     .thumbIP: CGPoint(x: 0.68, y: 0.28),
     .thumbTip: CGPoint(x: 0.76, y: 0.32)]
}

func foldedThumb() -> [HandJoint: CGPoint] {
    [.thumbCMC: CGPoint(x: 0.53, y: 0.14),
     .thumbMP: CGPoint(x: 0.58, y: 0.18),
     .thumbIP: CGPoint(x: 0.55, y: 0.13),
     .thumbTip: CGPoint(x: 0.51, y: 0.10)]
}

/// 通用手腕点（其余手指张开/收拢的基准）
let wristPoint = CGPoint(x: 0.5, y: 0.10)

private func joint(_ finger: Finger, _ middle: String) -> HandJoint {
    // indexPIP / middlePIP / ringPIP / littlePIP（thumb 专用命名不走这里）
    let prefix: String
    switch finger {
    case .index: prefix = "index"
    case .middle: prefix = "middle"
    case .ring: prefix = "ring"
    case .little: prefix = "little"
    case .thumb: prefix = "thumb"
    }
    return HandJoint(rawValue: prefix + middle)!
}
