import AppKit
import CoreGraphics
import Foundation
import ImageIO
import UniformTypeIdentifiers

// ============================================================
// MakeWeddingStickers — 婚礼贴纸起步包生成器
//
// 用 CoreGraphics 程序绘制一套婚礼主题贴纸（透明 PNG）+
// 搞怪装饰模板 template.json，输出到指定目录。
//
// 用法：swift tools/MakeWeddingStickers.swift <输出目录>
//   输出目录下直接生成 5 个模板目录（含 template.json + 贴纸 PNG）
//
// 版权：全部图形为本脚本程序绘制（圆/贝塞尔/文字），无第三方素材，
//       可任意商用。想换风格改本脚本重跑即可。
// ============================================================

let outDir = URL(fileURLWithPath: CommandLine.arguments.count > 1
    ? CommandLine.arguments[1] : "assets/decorations")
try? FileManager.default.createDirectory(at: outDir, withIntermediateDirectories: true)
print("输出目录: \(outDir.path)")

// MARK: - 基础工具

/// RGBA 透明底画布（CG 坐标原点左下、y 向上，与装饰管线的坐标系一致）
func makeCtx(_ w: Int, _ h: Int) -> CGContext {
    guard let ctx = CGContext(
        data: nil, width: w, height: h,
        bitsPerComponent: 8, bytesPerRow: 0,
        space: CGColorSpace(name: CGColorSpace.sRGB)!,
        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
    ) else { fatalError("画布创建失败") }
    ctx.setAllowsAntialiasing(true)
    ctx.setShouldAntialias(true)
    ctx.interpolationQuality = .high
    return ctx
}

/// 存 PNG 到输出目录
func savePNG(_ ctx: CGContext, _ name: String) {
    guard let img = ctx.makeImage() else { fatalError("\(name) 出图失败") }
    let url = outDir.appendingPathComponent(name)
    let data = NSMutableData()
    guard let dest = CGImageDestinationCreateWithData(
        data, UTType.png.identifier as CFString, 1, nil) else { fatalError("PNG 编码器创建失败") }
    CGImageDestinationAddImage(dest, img, nil)
    guard CGImageDestinationFinalize(dest) else { fatalError("\(name) PNG 写入失败") }
    try! (data as Data).write(to: url)
    print("  ✓ \(name) (\(ctx.width)x\(ctx.height))")
}

/// 像素颜色
func rgb(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat, _ a: CGFloat = 1) -> CGColor {
    CGColor(red: r / 255, green: g / 255, blue: b / 255, alpha: a)
}

let gold = rgb(212, 175, 55)
let goldLight = rgb(245, 220, 130)
let red = rgb(220, 45, 85)
let redDeep = rgb(178, 24, 60)
let black = rgb(28, 26, 30)
let chinaRed = rgb(196, 32, 40)

/// 画布内以单位坐标（0~1）取值
func u(_ v: CGFloat, _ canvas: CGFloat) -> CGFloat { v * canvas }

/// 顶部原点文字绘制（CG 画布内画 NSString 需翻转坐标系）
func drawTextCentered(_ text: NSAttributedString, ctx: CGContext, canvas: CGSize, centerFromTop: CGPoint) {
    let size = text.size()
    ctx.saveGState()
    ctx.translateBy(x: 0, y: canvas.height)
    ctx.scaleBy(x: 1, y: -1)
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(cgContext: ctx, flipped: false)
    text.draw(at: CGPoint(x: centerFromTop.x - size.width / 2,
                          y: centerFromTop.y - size.height / 2))
    NSGraphicsContext.restoreGraphicsState()
    ctx.restoreGState()
}

func roundedBold(_ size: CGFloat) -> NSFont {
    let base = NSFont.systemFont(ofSize: size, weight: .bold)
    if let d = base.fontDescriptor.withDesign(.rounded), let f = NSFont(descriptor: d, size: size) {
        return f
    }
    return base
}

// MARK: - ① 爱心 heart.png（512）

do {
    let S: CGFloat = 512
    let ctx = makeCtx(512, 512)
    // 心形 = 双圆 + 下三角
    ctx.setFillColor(red)
    ctx.fillEllipse(in: CGRect(x: u(0.05, S), y: u(0.60, S), width: u(0.42, S), height: u(0.42, S)))
    ctx.fillEllipse(in: CGRect(x: u(0.53, S), y: u(0.60, S), width: u(0.42, S), height: u(0.42, S)))
    ctx.move(to: CGPoint(x: u(0.05, S), y: u(0.81, S)))
    ctx.addLine(to: CGPoint(x: u(0.95, S), y: u(0.81, S)))
    ctx.addLine(to: CGPoint(x: u(0.50, S), y: u(0.06, S)))
    ctx.closePath()
    ctx.fillPath()
    // 高光
    ctx.setFillColor(rgb(255, 255, 255, 0.35))
    ctx.fillEllipse(in: CGRect(x: u(0.16, S), y: u(0.72, S), width: u(0.13, S), height: u(0.09, S)))
    savePNG(ctx, "heart.png")
}

// MARK: - ② 戒指 rings.png（512）

do {
    let S: CGFloat = 512
    let ctx = makeCtx(512, 512)
    let d = u(1, S)
    ctx.setLineWidth(u(0.055, S))
    ctx.setLineCap(.round)
    // 两枚交扣的圆环
    ctx.setStrokeColor(gold)
    ctx.strokeEllipse(in: CGRect(x: 0.17 * d, y: 0.20 * d, width: 0.44 * d, height: 0.44 * d))
    ctx.setStrokeColor(goldLight)
    ctx.strokeEllipse(in: CGRect(x: 0.39 * d, y: 0.20 * d, width: 0.44 * d, height: 0.44 * d))
    // 右环上的钻石（梯形冠 + 尖底）
    ctx.setFillColor(rgb(235, 245, 255))
    ctx.move(to: CGPoint(x: 0.55 * d, y: 0.68 * d))
    ctx.addLine(to: CGPoint(x: 0.79 * d, y: 0.68 * d))
    ctx.addLine(to: CGPoint(x: 0.745 * d, y: 0.76 * d))
    ctx.addLine(to: CGPoint(x: 0.67 * d, y: 0.90 * d))
    ctx.addLine(to: CGPoint(x: 0.595 * d, y: 0.76 * d))
    ctx.closePath()
    ctx.fillPath()
    // 钻石切面线
    ctx.setStrokeColor(rgb(160, 190, 220))
    ctx.setLineWidth(u(0.012, S))
    ctx.strokeLineSegments(between: [
        CGPoint(x: 0.55 * d, y: 0.68 * d), CGPoint(x: 0.595 * d, y: 0.76 * d),
        CGPoint(x: 0.79 * d, y: 0.68 * d), CGPoint(x: 0.745 * d, y: 0.76 * d),
        CGPoint(x: 0.595 * d, y: 0.76 * d), CGPoint(x: 0.745 * d, y: 0.76 * d),
    ])
    savePNG(ctx, "rings.png")
}

// MARK: - ③ 领结 bowtie.png（512）

do {
    let S: CGFloat = 512
    let ctx = makeCtx(512, 512)
    let d = u(1, S)
    ctx.setFillColor(black)
    // 左右翼
    ctx.move(to: CGPoint(x: 0.42 * d, y: 0.50 * d))
    ctx.addLine(to: CGPoint(x: 0.06 * d, y: 0.26 * d))
    ctx.addLine(to: CGPoint(x: 0.06 * d, y: 0.74 * d))
    ctx.closePath()
    ctx.fillPath()
    ctx.move(to: CGPoint(x: 0.58 * d, y: 0.50 * d))
    ctx.addLine(to: CGPoint(x: 0.94 * d, y: 0.26 * d))
    ctx.addLine(to: CGPoint(x: 0.94 * d, y: 0.74 * d))
    ctx.closePath()
    ctx.fillPath()
    // 中结
    ctx.fill(CGRect(x: 0.40 * d, y: 0.40 * d, width: 0.20 * d, height: 0.20 * d))
    // 白点花纹
    ctx.setFillColor(rgb(255, 255, 255, 0.85))
    let dots: [(CGFloat, CGFloat)] = [(0.18, 0.40), (0.28, 0.55), (0.16, 0.60),
                                       (0.82, 0.40), (0.72, 0.55), (0.84, 0.60)]
    for (x, y) in dots {
        ctx.fillEllipse(in: CGRect(x: (x - 0.025) * d, y: (y - 0.025) * d,
                                   width: 0.05 * d, height: 0.05 * d))
    }
    savePNG(ctx, "bowtie.png")
}

// MARK: - ④ 礼帽 tophat.png（512）

do {
    let S: CGFloat = 512
    let ctx = makeCtx(512, 512)
    let d = u(1, S)
    // 帽檐（椭圆）
    ctx.setFillColor(black)
    ctx.fillEllipse(in: CGRect(x: 0.08 * d, y: 0.22 * d, width: 0.84 * d, height: 0.16 * d))
    // 帽筒
    ctx.fill(CGRect(x: 0.26 * d, y: 0.30 * d, width: 0.48 * d, height: 0.58 * d))
    // 帽顶（椭圆收口）
    ctx.fillEllipse(in: CGRect(x: 0.26 * d, y: 0.84 * d, width: 0.48 * d, height: 0.10 * d))
    // 红色帽带
    ctx.setFillColor(red)
    ctx.fill(CGRect(x: 0.26 * d, y: 0.40 * d, width: 0.48 * d, height: 0.13 * d))
    // 帽带在筒面上的接缝修正（左右小块补齐）
    ctx.fill(CGRect(x: 0.26 * d, y: 0.40 * d, width: 0.48 * d, height: 0.13 * d))
    savePNG(ctx, "tophat.png")
}

// MARK: - ⑤ 头纱 veil.png（512×560）

do {
    let W: CGFloat = 512, H: CGFloat = 560
    let ctx = makeCtx(512, 560)
    // 半透明白纱主体：顶部圆弧 + 底部扇贝花边
    ctx.setFillColor(rgb(255, 255, 255, 0.42))
    ctx.move(to: CGPoint(x: 0.5 * W, y: 0.98 * H))
    ctx.addCurve(to: CGPoint(x: 0.05 * W, y: 0.55 * H),
                 control1: CGPoint(x: 0.15 * W, y: 0.95 * H),
                 control2: CGPoint(x: 0.05 * W, y: 0.78 * H))
    ctx.addLine(to: CGPoint(x: 0.05 * W, y: 0.10 * H))
    // 底部扇贝（5 个下垂圆弧）
    let scallops = 5
    let segW = 0.9 * W / CGFloat(scallops)
    for i in 0..<scallops {
        let x0 = 0.05 * W + CGFloat(i) * segW
        ctx.addArc(center: CGPoint(x: x0 + segW / 2, y: 0.10 * H),
                   radius: segW / 2,
                   startAngle: .pi, endAngle: 0, clockwise: true)
    }
    ctx.addLine(to: CGPoint(x: 0.95 * W, y: 0.55 * H))
    ctx.addCurve(to: CGPoint(x: 0.5 * W, y: 0.98 * H),
                 control1: CGPoint(x: 0.95 * W, y: 0.78 * H),
                 control2: CGPoint(x: 0.85 * W, y: 0.95 * H))
    ctx.closePath()
    ctx.fillPath()
    // 蕾丝点缀（花边上方小圆点串）
    ctx.setFillColor(rgb(255, 255, 255, 0.65))
    for i in 0...10 {
        let x = 0.10 * W + CGFloat(i) * 0.08 * W
        let y = 0.22 * H + (i % 2 == 0 ? 0 : 0.04 * H)
        ctx.fillEllipse(in: CGRect(x: x - 4, y: y - 4, width: 8, height: 8))
    }
    // 顶部小皇冠点缀
    ctx.setFillColor(rgb(255, 255, 255, 0.8))
    ctx.fillEllipse(in: CGRect(x: 0.5 * W - 26, y: 0.94 * H, width: 52, height: 26))
    savePNG(ctx, "veil.png")
}

// MARK: - ⑥ 皇冠 tiara.png（512）

do {
    let S: CGFloat = 512
    let ctx = makeCtx(512, 512)
    let d = u(1, S)
    // 底带（弧形）
    ctx.setStrokeColor(gold)
    ctx.setLineWidth(u(0.07, S))
    ctx.addArc(center: CGPoint(x: 0.5 * d, y: 0.28 * d), radius: 0.34 * d,
               startAngle: .pi * 0.15, endAngle: .pi * 0.85, clockwise: false)
    ctx.strokePath()
    // 三尖
    ctx.setFillColor(gold)
    func spike(x: CGFloat, topY: CGFloat, baseW: CGFloat) {
        ctx.move(to: CGPoint(x: (x - baseW / 2) * d, y: 0.34 * d))
        ctx.addLine(to: CGPoint(x: x * d, y: topY * d))
        ctx.addLine(to: CGPoint(x: (x + baseW / 2) * d, y: 0.34 * d))
        ctx.closePath()
        ctx.fillPath()
    }
    spike(x: 0.5, topY: 0.90, baseW: 0.13)
    spike(x: 0.30, topY: 0.62, baseW: 0.11)
    spike(x: 0.70, topY: 0.62, baseW: 0.11)
    // 尖顶宝石
    ctx.setFillColor(red)
    ctx.fillEllipse(in: CGRect(x: 0.5 * d - 0.045 * d, y: 0.86 * d, width: 0.09 * d, height: 0.09 * d))
    ctx.setFillColor(rgb(120, 180, 255))
    ctx.fillEllipse(in: CGRect(x: 0.30 * d - 0.035 * d, y: 0.58 * d, width: 0.07 * d, height: 0.07 * d))
    ctx.fillEllipse(in: CGRect(x: 0.70 * d - 0.035 * d, y: 0.58 * d, width: 0.07 * d, height: 0.07 * d))
    savePNG(ctx, "tiara.png")
}

// MARK: - ⑦ 胡子 mustache.png（512）

do {
    let S: CGFloat = 512
    let ctx = makeCtx(512, 512)
    let d = u(1, S)
    ctx.setStrokeColor(black)
    ctx.setLineWidth(u(0.10, S))
    ctx.setLineCap(.round)
    // 左半（两段贝塞尔出卷曲）
    ctx.move(to: CGPoint(x: 0.50 * d, y: 0.55 * d))
    ctx.addCurve(to: CGPoint(x: 0.16 * d, y: 0.60 * d),
                 control1: CGPoint(x: 0.34 * d, y: 0.70 * d),
                 control2: CGPoint(x: 0.22 * d, y: 0.72 * d))
    ctx.strokePath()
    ctx.move(to: CGPoint(x: 0.16 * d, y: 0.60 * d))
    ctx.addQuadCurve(to: CGPoint(x: 0.14 * d, y: 0.38 * d),
                     control: CGPoint(x: 0.02 * d, y: 0.52 * d))
    ctx.strokePath()
    // 右半（镜像）
    ctx.move(to: CGPoint(x: 0.50 * d, y: 0.55 * d))
    ctx.addCurve(to: CGPoint(x: 0.84 * d, y: 0.60 * d),
                 control1: CGPoint(x: 0.66 * d, y: 0.70 * d),
                 control2: CGPoint(x: 0.78 * d, y: 0.72 * d))
    ctx.strokePath()
    ctx.move(to: CGPoint(x: 0.84 * d, y: 0.60 * d))
    ctx.addQuadCurve(to: CGPoint(x: 0.86 * d, y: 0.38 * d),
                     control: CGPoint(x: 0.98 * d, y: 0.52 * d))
    ctx.strokePath()
    savePNG(ctx, "mustache.png")
}

// MARK: - ⑧ 圆眼镜 glasses.png（512）

do {
    let S: CGFloat = 512
    let ctx = makeCtx(512, 512)
    let d = u(1, S)
    ctx.setStrokeColor(black)
    ctx.setLineWidth(u(0.045, S))
    ctx.strokeEllipse(in: CGRect(x: 0.11 * d, y: 0.32 * d, width: 0.34 * d, height: 0.34 * d))
    ctx.strokeEllipse(in: CGRect(x: 0.55 * d, y: 0.32 * d, width: 0.34 * d, height: 0.34 * d))
    // 鼻梁
    ctx.move(to: CGPoint(x: 0.45 * d, y: 0.49 * d))
    ctx.addQuadCurve(to: CGPoint(x: 0.55 * d, y: 0.49 * d),
                     control: CGPoint(x: 0.50 * d, y: 0.44 * d))
    ctx.strokePath()
    // 镜腿
    ctx.strokeLineSegments(between: [
        CGPoint(x: 0.11 * d, y: 0.49 * d), CGPoint(x: 0.02 * d, y: 0.52 * d),
        CGPoint(x: 0.89 * d, y: 0.49 * d), CGPoint(x: 0.98 * d, y: 0.52 * d),
    ])
    savePNG(ctx, "glasses.png")
}

// MARK: - ⑨ 红唇 lips.png（512）

do {
    let S: CGFloat = 512
    let ctx = makeCtx(512, 512)
    let d = u(1, S)
    // 上唇（唇峰）+ 下唇（饱满）一笔连成
    ctx.setFillColor(red)
    ctx.move(to: CGPoint(x: 0.08 * d, y: 0.45 * d))
    ctx.addCurve(to: CGPoint(x: 0.5 * d, y: 0.40 * d),
                 control1: CGPoint(x: 0.22 * d, y: 0.30 * d),
                 control2: CGPoint(x: 0.38 * d, y: 0.30 * d))
    ctx.addCurve(to: CGPoint(x: 0.92 * d, y: 0.45 * d),
                 control1: CGPoint(x: 0.62 * d, y: 0.30 * d),
                 control2: CGPoint(x: 0.78 * d, y: 0.30 * d))
    ctx.addCurve(to: CGPoint(x: 0.08 * d, y: 0.45 * d),
                 control1: CGPoint(x: 0.78 * d, y: 0.12 * d),
                 control2: CGPoint(x: 0.22 * d, y: 0.12 * d))
    ctx.closePath()
    ctx.fillPath()
    // 中缝
    ctx.setStrokeColor(redDeep)
    ctx.setLineWidth(u(0.025, S))
    ctx.move(to: CGPoint(x: 0.10 * d, y: 0.45 * d))
    ctx.addQuadCurve(to: CGPoint(x: 0.90 * d, y: 0.45 * d),
                     control: CGPoint(x: 0.5 * d, y: 0.40 * d))
    ctx.strokePath()
    // 高光
    ctx.setFillColor(rgb(255, 255, 255, 0.30))
    ctx.fillEllipse(in: CGRect(x: 0.55 * d, y: 0.17 * d, width: 0.16 * d, height: 0.08 * d))
    savePNG(ctx, "lips.png")
}

// MARK: - ⑩ 小花 flower.png（512）

do {
    let S: CGFloat = 512
    let ctx = makeCtx(512, 512)
    let d = u(1, S)
    // 六片花瓣
    ctx.setFillColor(rgb(255, 205, 220))
    for i in 0..<6 {
        let angle = CGFloat(i) * .pi / 3
        let cx = 0.5 * S + cos(angle) * 0.185 * S
        let cy = 0.5 * S + sin(angle) * 0.185 * S
        ctx.saveGState()
        ctx.translateBy(x: cx, y: cy)
        ctx.rotate(by: angle)
        ctx.fillEllipse(in: CGRect(x: -0.085 * d, y: -0.13 * d, width: 0.17 * d, height: 0.26 * d))
        ctx.restoreGState()
    }
    // 花芯
    ctx.setFillColor(rgb(255, 215, 90))
    ctx.fillEllipse(in: CGRect(x: 0.5 * S - 0.105 * d, y: 0.5 * S - 0.105 * d,
                               width: 0.21 * d, height: 0.21 * d))
    ctx.setStrokeColor(rgb(240, 160, 60))
    ctx.setLineWidth(u(0.02, S))
    ctx.strokeEllipse(in: CGRect(x: 0.5 * S - 0.105 * d, y: 0.5 * S - 0.105 * d,
                                 width: 0.21 * d, height: 0.21 * d))
    savePNG(ctx, "flower.png")
}

// MARK: - ⑪ 闪光 sparkle.png（512）

do {
    let S: CGFloat = 512
    let ctx = makeCtx(512, 512)
    let d = u(1, S)
    func star(cx: CGFloat, cy: CGFloat, r: CGFloat, color: CGColor) {
        ctx.setFillColor(color)
        ctx.move(to: CGPoint(x: cx * d, y: (cy + r) * d))
        ctx.addLine(to: CGPoint(x: (cx + r * 0.22) * d, y: (cy + r * 0.22) * d))
        ctx.addLine(to: CGPoint(x: (cx + r) * d, y: cy * d))
        ctx.addLine(to: CGPoint(x: (cx + r * 0.22) * d, y: (cy - r * 0.22) * d))
        ctx.addLine(to: CGPoint(x: cx * d, y: (cy - r) * d))
        ctx.addLine(to: CGPoint(x: (cx - r * 0.22) * d, y: (cy - r * 0.22) * d))
        ctx.addLine(to: CGPoint(x: (cx - r) * d, y: cy * d))
        ctx.addLine(to: CGPoint(x: (cx - r * 0.22) * d, y: (cy + r * 0.22) * d))
        ctx.closePath()
        ctx.fillPath()
    }
    star(cx: 0.35, cy: 0.62, r: 0.30, color: goldLight)
    star(cx: 0.68, cy: 0.35, r: 0.20, color: gold)
    star(cx: 0.62, cy: 0.80, r: 0.12, color: gold)
    savePNG(ctx, "sparkle.png")
}

// MARK: - ⑫ 双喜 shuangxi.png（512）

do {
    let S: CGFloat = 512
    let ctx = makeCtx(512, 512)
    let d = u(1, S)
    // 红底圆角方块
    let rect = CGRect(x: 0.05 * d, y: 0.05 * d, width: 0.90 * d, height: 0.90 * d)
    let path = CGPath(roundedRect: rect, cornerWidth: 0.10 * d, cornerHeight: 0.10 * d, transform: nil)
    ctx.addPath(path)
    ctx.setFillColor(chinaRed)
    ctx.fillPath()
    // 金边
    ctx.addPath(path)
    ctx.setStrokeColor(gold)
    ctx.setLineWidth(u(0.025, S))
    ctx.strokePath()
    // 囍字（白色居中）
    let font = NSFont.systemFont(ofSize: 0.52 * S, weight: .bold)
    let text = NSAttributedString(string: "囍", attributes: [
        .font: font, .foregroundColor: NSColor.white,
    ])
    drawTextCentered(text, ctx: ctx, canvas: CGSize(width: S, height: S),
                     centerFromTop: CGPoint(x: 0.5 * S, y: 0.52 * S))
    savePNG(ctx, "shuangxi.png")
}

// MARK: - ⑬ 横幅 banner.png（768×256）

do {
    let W: CGFloat = 768, H: CGFloat = 256
    let ctx = makeCtx(768, 256)
    // 白底圆角横幅
    let rect = CGRect(x: 0.03 * W, y: 0.10 * H, width: 0.94 * W, height: 0.80 * H)
    let path = CGPath(roundedRect: rect, cornerWidth: 0.30 * H, cornerHeight: 0.30 * H, transform: nil)
    ctx.addPath(path)
    ctx.setFillColor(rgb(255, 250, 245))
    ctx.fillPath()
    ctx.addPath(path)
    ctx.setStrokeColor(red)
    ctx.setLineWidth(6)
    ctx.strokePath()
    // 文字（缩小字号，给两端爱心留出空间）
    let font = roundedBold(0.26 * H)
    let text = NSAttributedString(string: "JUST MARRIED", attributes: [
        .font: font, .foregroundColor: NSColor(calibratedRed: 0.45, green: 0.12, blue: 0.2, alpha: 1),
    ])
    drawTextCentered(text, ctx: ctx, canvas: CGSize(width: W, height: H),
                     centerFromTop: CGPoint(x: 0.5 * W, y: 0.5 * H))
    // 两端小爱心（贴边放置，不压文字）
    for x in [0.07, 0.93] {
        let c = CGFloat(x) * W
        let s: CGFloat = 0.07 * H
        ctx.setFillColor(red)
        ctx.fillEllipse(in: CGRect(x: c - s * 1.05, y: 0.5 * H - s * 0.05, width: s * 1.1, height: s * 1.1))
        ctx.fillEllipse(in: CGRect(x: c - s * 0.05, y: 0.5 * H - s * 0.05, width: s * 1.1, height: s * 1.1))
        ctx.move(to: CGPoint(x: c - s * 1.05, y: 0.5 * H + s * 0.45))
        ctx.addLine(to: CGPoint(x: c + s * 1.05, y: 0.5 * H + s * 0.45))
        ctx.addLine(to: CGPoint(x: c, y: 0.5 * H - s * 0.9))
        ctx.closePath()
        ctx.fillPath()
    }
    savePNG(ctx, "banner.png")
}

// MARK: - 模板 template.json（5 个婚礼模板）

func writeTemplate(_ dirName: String, _ json: String) {
    let dir = outDir.appendingPathComponent(dirName, isDirectory: true)
    try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
    try! json.data(using: .utf8)!.write(to: dir.appendingPathComponent("template.json"))
    // 把模板引用到的贴纸复制进模板目录（DecorationCore 约定：贴纸与 template.json 同目录），
    // 使素材包自包含，可直接被 loadTemplate / 安装脚本使用
    let regex = try! NSRegularExpression(pattern: "\"file\"\\s*:\\s*\"([^\"]+\\.png)\"")
    let range = NSRange(json.startIndex..., in: json)
    for m in regex.matches(in: json, range: range) {
        let file = String(json[Range(m.range(at: 1), in: json)!])
        let src = outDir.appendingPathComponent(file)
        let dst = dir.appendingPathComponent(file)
        if FileManager.default.fileExists(atPath: src.path) {
            try? FileManager.default.removeItem(at: dst)
            try! FileManager.default.copyItem(at: src, to: dst)
        } else {
            print("  ⚠️ \(dirName): 贴纸 \(file) 不存在")
        }
    }
    print("  ✓ \(dirName)/template.json")
}

print("\n生成模板:")

// ① 优雅新娘：头纱 + 两侧小花 + 粉色字幕（无形变无滤镜，全脸可用）
writeTemplate("wedding-elegant", """
{
  "stickers": [
    {"file": "veil.png", "anchor": "faceTop", "scale": 2.8, "offsetY": 1.1},
    {"file": "flower.png", "anchor": "faceTop", "scale": 0.6, "offsetX": -0.95, "offsetY": 0.05},
    {"file": "flower.png", "anchor": "faceTop", "scale": 0.6, "offsetX": 0.95, "offsetY": 0.05}
  ],
  "caption": {"text": "我们结婚啦", "colorHex": "#D4476B", "size": 72}
}
""")

// ② 搞怪新郎：大头 + 礼帽 + 胡子 + 领结
writeTemplate("wedding-fun", """
{
  "warps": [{"kind": "bigHead", "strength": 0.45}],
  "stickers": [
    {"file": "tophat.png", "anchor": "faceTop", "scale": 1.7, "offsetY": 0.75},
    {"file": "mustache.png", "anchor": "mouth", "scale": 1.0, "offsetY": 0.22},
    {"file": "bowtie.png", "anchor": "mouth", "scale": 1.2, "offsetY": 0.85}
  ],
  "caption": {"text": "余生请多指教！", "colorHex": "#FFFFFF", "size": 64}
}
""")

// ③ 爱情上头：大眼 + 漫画滤镜 + 头顶爱心 + 眼镜
writeTemplate("wedding-comic", """
{
  "warps": [{"kind": "bigEyes", "strength": 0.5}],
  "stickers": [
    {"file": "heart.png", "anchor": "faceTop", "scale": 0.8, "offsetX": -0.9, "offsetY": 0.55},
    {"file": "heart.png", "anchor": "faceTop", "scale": 0.55, "offsetX": 0.85, "offsetY": 0.95},
    {"file": "glasses.png", "anchor": "eyeMidpoint", "scale": 2.3, "offsetY": 0.05}
  ],
  "filter": "comic",
  "caption": {"text": "爱情使人上头", "colorHex": "#FFD700", "size": 64}
}
""")

// ④ 中式喜庆：头顶双喜 + 红唇 + 闪光 + 百年好合
writeTemplate("wedding-chinese", """
{
  "stickers": [
    {"file": "shuangxi.png", "anchor": "faceTop", "scale": 1.5, "offsetY": 1.7},
    {"file": "lips.png", "anchor": "mouth", "scale": 0.95},
    {"file": "sparkle.png", "anchor": "faceTop", "scale": 0.7, "offsetX": -1.3, "offsetY": 0.9},
    {"file": "sparkle.png", "anchor": "faceTop", "scale": 0.55, "offsetX": 1.3, "offsetY": 1.1}
  ],
  "caption": {"text": "百年好合 · 永结同心", "colorHex": "#E02020", "size": 64}
}
""")

// ⑤ 甜蜜合影（双人多用）：横幅 + 戒指 + 大头微形变
writeTemplate("wedding-sweet", """
{
  "warps": [{"kind": "bigHead", "strength": 0.3}],
  "stickers": [
    {"file": "banner.png", "anchor": "faceTop", "scale": 1.9, "offsetY": 1.8},
    {"file": "rings.png", "anchor": "mouth", "scale": 0.9, "offsetX": 1.6, "offsetY": -0.9}
  ],
  "caption": {"text": "❤ 甜甜蜜蜜 ❤", "colorHex": "#FFFFFF", "size": 64}
}
""")

print("\n完成：贴纸 13 张 + 模板 5 个")
