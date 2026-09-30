import AppKit
import CoreGraphics
import Foundation
import ImageIO
import UniformTypeIdentifiers

// ============================================================
// MakeWeddingFrames — 婚礼主题边框（frame.png）生成器
//
// 用 CoreGraphics 程序绘制多套婚礼相框（中间透明、四边装饰的
// 叠加层 PNG），输出到指定目录，每种风格一张 <风格>.png。
//
// 用法：swift tools/MakeWeddingFrames.swift <输出目录>
//
// 尺寸约定：与 PipelineCore.overlayFrameAndWatermark 一致 ——
//   按最终 1200×1800 成片尺寸设计，使用时拉伸铺满成片。
//   安装方式：把某张 PNG 重命名为 frame.png 放进主题目录
//   （如 assets/themes/cream-wedding/frame.png）即可生效。
//
// 版权：全部图形为本脚本程序绘制，无第三方素材，可任意商用。
// ============================================================

let outDir = URL(fileURLWithPath: CommandLine.arguments.count > 1
    ? CommandLine.arguments[1] : "assets/frames")
try? FileManager.default.createDirectory(at: outDir, withIntermediateDirectories: true)
print("输出目录: \(outDir.path)")

// MARK: - 基础工具

let W = 1200, H = 1800
let FW: CGFloat = 1200, FH: CGFloat = 1800

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

func rgb(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat, _ a: CGFloat = 1) -> CGColor {
    CGColor(red: r / 255, green: g / 255, blue: b / 255, alpha: a)
}

// 与 cream-wedding 主题一致的色板
let gold = rgb(212, 175, 55)
let goldLight = rgb(245, 220, 130)
let pink = rgb(255, 143, 171)       // theme accent #FF8FAB
let pinkLight = rgb(255, 194, 212)  // #FFC2D4
let pinkDeep = rgb(212, 71, 107)    // #D4476B
let cream = rgb(255, 247, 240)      // #FFF7F0
let chinaRed = rgb(196, 32, 40)
let leafGreen = rgb(125, 201, 143)  // theme success #7DC98F

/// CG 画布 y 向上；本脚本全部用"距顶边"的坐标思考，画前统一翻转。
func withTopDown(_ ctx: CGContext, _ body: () -> Void) {
    ctx.saveGState()
    ctx.translateBy(x: 0, y: FH)
    ctx.scaleBy(x: 1, y: -1)
    body()
    ctx.restoreGState()
}

/// 偶奇填充：外框矩形 - 内镂空矩形 → 中间透明的边带
func fillBand(_ ctx: CGContext, outer: CGRect, inner: CGRect,
              outerRadius: CGFloat, innerRadius: CGFloat, color: CGColor) {
    let p = CGMutablePath()
    p.addPath(CGPath(roundedRect: outer, cornerWidth: outerRadius, cornerHeight: outerRadius, transform: nil))
    p.addPath(CGPath(roundedRect: inner, cornerWidth: innerRadius, cornerHeight: innerRadius, transform: nil))
    ctx.saveGState()
    ctx.addPath(p)
    ctx.setFillColor(color)
    ctx.fillPath(using: .evenOdd)
    ctx.restoreGState()
}

/// 填充爱心（cx, cy 为心形中心，s 为半径尺度；坐标系已翻转为顶部原点）
func fillHeart(_ ctx: CGContext, _ cx: CGFloat, _ cy: CGFloat, _ s: CGFloat, _ color: CGColor) {
    ctx.setFillColor(color)
    ctx.fillEllipse(in: CGRect(x: cx - s, y: cy - s * 0.55, width: s * 1.05, height: s * 1.05))
    ctx.fillEllipse(in: CGRect(x: cx - s * 0.05, y: cy - s * 0.55, width: s * 1.05, height: s * 1.05))
    ctx.move(to: CGPoint(x: cx - s * 0.95, y: cy + s * 0.05))
    ctx.addLine(to: CGPoint(x: cx + s * 0.95, y: cy + s * 0.05))
    ctx.addLine(to: CGPoint(x: cx, y: cy + s * 1.35))
    ctx.closePath()
    ctx.fillPath()
}

/// 六瓣小花（与贴纸 flower.png 同款）
func fillFlower(_ ctx: CGContext, _ cx: CGFloat, _ cy: CGFloat, _ r: CGFloat,
                petal: CGColor, core: CGColor) {
    ctx.setFillColor(petal)
    for i in 0..<6 {
        let angle = CGFloat(i) * .pi / 3
        let px = cx + cos(angle) * r * 0.62
        let py = cy + sin(angle) * r * 0.62
        ctx.saveGState()
        ctx.translateBy(x: px, y: py)
        ctx.rotate(by: angle)
        ctx.fillEllipse(in: CGRect(x: -r * 0.30, y: -r * 0.44, width: r * 0.60, height: r * 0.88))
        ctx.restoreGState()
    }
    ctx.setFillColor(core)
    ctx.fillEllipse(in: CGRect(x: cx - r * 0.34, y: cy - r * 0.34, width: r * 0.68, height: r * 0.68))
}

/// 四角星闪光（与贴纸 sparkle.png 同款）
func fillSparkle(_ ctx: CGContext, _ cx: CGFloat, _ cy: CGFloat, _ r: CGFloat, _ color: CGColor) {
    ctx.setFillColor(color)
    ctx.move(to: CGPoint(x: cx, y: cy - r))
    ctx.addLine(to: CGPoint(x: cx + r * 0.22, y: cy - r * 0.22))
    ctx.addLine(to: CGPoint(x: cx + r, y: cy))
    ctx.addLine(to: CGPoint(x: cx + r * 0.22, y: cy + r * 0.22))
    ctx.addLine(to: CGPoint(x: cx, y: cy + r))
    ctx.addLine(to: CGPoint(x: cx - r * 0.22, y: cy + r * 0.22))
    ctx.addLine(to: CGPoint(x: cx - r, y: cy))
    ctx.addLine(to: CGPoint(x: cx - r * 0.22, y: cy - r * 0.22))
    ctx.closePath()
    ctx.fillPath()
}

/// 叶子（旋转椭圆）
func fillLeaf(_ ctx: CGContext, _ cx: CGFloat, _ cy: CGFloat, _ r: CGFloat,
              angle: CGFloat, _ color: CGColor) {
    ctx.saveGState()
    ctx.translateBy(x: cx, y: cy)
    ctx.rotate(by: angle)
    ctx.setFillColor(color)
    ctx.move(to: CGPoint(x: 0, y: 0))
    ctx.addQuadCurve(to: CGPoint(x: 0, y: r * 2.2), control: CGPoint(x: r * 0.9, y: r * 1.1))
    ctx.addQuadCurve(to: CGPoint(x: 0, y: 0), control: CGPoint(x: -r * 0.9, y: r * 1.1))
    ctx.closePath()
    ctx.fillPath()
    ctx.restoreGState()
}

/// 在 withTopDown 已翻转的坐标系内绘制居中文字（局部再翻一次让字形立正）
func drawTextCentered(_ text: NSAttributedString, ctx: CGContext,
                      centerFromTop: CGPoint) {
    let size = text.size()
    ctx.saveGState()
    ctx.translateBy(x: centerFromTop.x - size.width / 2,
                    y: centerFromTop.y + size.height / 2)
    ctx.scaleBy(x: 1, y: -1)
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(cgContext: ctx, flipped: false)
    text.draw(at: .zero)
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

// 统一的外框/镂空几何（四边留白，中间全透明露出照片）
let margin: CGFloat = 36
let bandW: CGFloat = 96
let outerRect = CGRect(x: margin, y: margin, width: FW - margin * 2, height: FH - margin * 2)
let innerRect = outerRect.insetBy(dx: bandW, dy: bandW)

print("\n生成相框:")

// MARK: - ① 优雅花环 frame-floral-elegant.png（奶油底 + 金线 + 四角花束）

do {
    let ctx = makeCtx(W, H)
    withTopDown(ctx) {
        // 奶油色边带
        fillBand(ctx, outer: outerRect, inner: innerRect,
                 outerRadius: 44, innerRadius: 30, color: cream)
        // 内缘金色细线
        ctx.addPath(CGPath(roundedRect: innerRect, cornerWidth: 30, cornerHeight: 30, transform: nil))
        ctx.setStrokeColor(gold)
        ctx.setLineWidth(4)
        ctx.strokePath()
        // 四角花束：上两角大、下两角小（内收避免出画布）
        let corners: [(CGFloat, CGFloat, CGFloat)] = [
            (outerRect.minX + 78, outerRect.minY + 78, 82),   // 左上
            (outerRect.maxX - 78, outerRect.minY + 78, 82),   // 右上
            (outerRect.minX + 60, outerRect.maxY - 60, 58),   // 左下
            (outerRect.maxX - 60, outerRect.maxY - 60, 58),   // 右下
        ]
        for (cx, cy, r) in corners {
            fillLeaf(ctx, cx - r * 0.8, cy - r * 0.4, r * 0.42, angle: -.pi / 4, leafGreen)
            fillLeaf(ctx, cx + r * 0.8, cy - r * 0.4, r * 0.42, angle: -.pi * 3 / 4, leafGreen)
            fillFlower(ctx, cx, cy, r, petal: pinkLight, core: rgb(255, 215, 90))
            fillFlower(ctx, cx - r * 1.0, cy + r * 0.5, r * 0.45, petal: pink, core: rgb(255, 215, 90))
            fillFlower(ctx, cx + r * 1.0, cy + r * 0.5, r * 0.45, petal: pink, core: rgb(255, 215, 90))
        }
        // 上下边中央小爱心点缀
        fillHeart(ctx, FW / 2, outerRect.minY + bandW / 2, 26, pink)
        fillHeart(ctx, FW / 2, outerRect.maxY - bandW / 2, 26, pink)
        // 两侧边中央闪光
        fillSparkle(ctx, outerRect.minX + bandW / 2, FH / 2, 22, gold)
        fillSparkle(ctx, outerRect.maxX - bandW / 2, FH / 2, 22, gold)
    }
    savePNG(ctx, "frame-floral-elegant.png")
}

// MARK: - ② 中式红金 frame-chinese-red.png（红边 + 金线 + 囍 + 金角）

do {
    let ctx = makeCtx(W, H)
    withTopDown(ctx) {
        // 中国红边带
        fillBand(ctx, outer: outerRect, inner: innerRect,
                 outerRadius: 40, innerRadius: 26, color: chinaRed)
        // 内外金线
        for rect in [outerRect.insetBy(dx: 8, dy: 8), innerRect.insetBy(dx: -6, dy: -6)] {
            ctx.addPath(CGPath(roundedRect: rect, cornerWidth: 30, cornerHeight: 30, transform: nil))
            ctx.setStrokeColor(gold)
            ctx.setLineWidth(5)
            ctx.strokePath()
        }
        // 顶部中央：金色圆 + 囍
        let cx = FW / 2, cy = outerRect.minY + bandW / 2
        ctx.setFillColor(gold)
        ctx.fillEllipse(in: CGRect(x: cx - 58, y: cy - 58, width: 116, height: 116))
        ctx.setStrokeColor(chinaRed)
        ctx.setLineWidth(4)
        ctx.strokeEllipse(in: CGRect(x: cx - 58, y: cy - 58, width: 116, height: 116))
        let text = NSAttributedString(string: "囍", attributes: [
            .font: NSFont.systemFont(ofSize: 62, weight: .bold),
            .foregroundColor: NSColor(calibratedRed: 196 / 255, green: 32 / 255, blue: 40 / 255, alpha: 1),
        ])
        drawTextCentered(text, ctx: ctx, centerFromTop: CGPoint(x: cx, y: cy + 1))
        // 四角金色角花（L 形双线包角）
        ctx.setStrokeColor(gold)
        ctx.setLineWidth(6)
        ctx.setLineCap(.round)
        let arm: CGFloat = 56
        let insets: [(CGFloat, CGFloat, CGFloat, CGFloat)] = [
            (outerRect.minX + bandW / 2, outerRect.minY + bandW / 2, 1, 1),   // 左上 → 向右向下伸
            (outerRect.maxX - bandW / 2, outerRect.minY + bandW / 2, -1, 1),  // 右上
            (outerRect.minX + bandW / 2, outerRect.maxY - bandW / 2, 1, -1),  // 左下
            (outerRect.maxX - bandW / 2, outerRect.maxY - bandW / 2, -1, -1), // 右下
        ]
        for (x, y, sx, sy) in insets {
            ctx.move(to: CGPoint(x: x + sx * arm, y: y))
            ctx.addLine(to: CGPoint(x: x, y: y))
            ctx.addLine(to: CGPoint(x: x, y: y + sy * arm))
            ctx.strokePath()
        }
        // 底部中央双环戒指
        let by = outerRect.maxY - bandW / 2
        ctx.setLineWidth(10)
        ctx.setStrokeColor(gold)
        ctx.strokeEllipse(in: CGRect(x: FW / 2 - 52, y: by - 30, width: 60, height: 60))
        ctx.setStrokeColor(goldLight)
        ctx.strokeEllipse(in: CGRect(x: FW / 2 - 8, y: by - 30, width: 60, height: 60))
    }
    savePNG(ctx, "frame-chinese-red.png")
}

// MARK: - ③ 拍立得 frame-polaroid.png（白边 + 底部宽边 + 字）

do {
    let ctx = makeCtx(W, H)
    withTopDown(ctx) {
        // 白色边带（上左右窄、底部宽 —— 用非对称镂空实现）
        let inner = CGRect(x: margin + 60, y: margin + 60,
                           width: FW - (margin + 60) * 2,
                           height: FH - margin * 2 - 60 - 240)
        fillBand(ctx, outer: outerRect, inner: inner,
                 outerRadius: 26, innerRadius: 8, color: rgb(255, 255, 255))
        // 内缘浅灰细线
        ctx.addPath(CGPath(roundedRect: inner, cornerWidth: 8, cornerHeight: 8, transform: nil))
        ctx.setStrokeColor(rgb(220, 214, 210))
        ctx.setLineWidth(3)
        ctx.strokePath()
        // 底部宽边：文字 + 两颗小爱心
        let stripMid = inner.maxY + (outerRect.maxY - inner.maxY) / 2
        let text = NSAttributedString(string: "JUST MARRIED", attributes: [
            .font: roundedBold(64),
            .foregroundColor: NSColor(calibratedRed: 0.55, green: 0.25, blue: 0.3, alpha: 1),
        ])
        drawTextCentered(text, ctx: ctx, centerFromTop: CGPoint(x: FW / 2, y: stripMid))
        fillHeart(ctx, FW / 2 - 330, stripMid, 22, pinkDeep)
        fillHeart(ctx, FW / 2 + 330, stripMid, 22, pinkDeep)
        // 上边两个小夹子感闪光
        fillSparkle(ctx, outerRect.minX + 90, outerRect.minY + 48, 20, gold)
        fillSparkle(ctx, outerRect.maxX - 90, outerRect.minY + 48, 20, gold)
    }
    savePNG(ctx, "frame-polaroid.png")
}

// MARK: - ④ 极简金线 frame-minimal-gold.png（透明感细双线 + 角部点缀）

do {
    let ctx = makeCtx(W, H)
    withTopDown(ctx) {
        // 不用实心底，纯线条 —— 细双线
        let line1 = outerRect.insetBy(dx: 26, dy: 26)
        let line2 = outerRect.insetBy(dx: 40, dy: 40)
        for (rect, w) in [(line1, 5.0), (line2, 2.5)] as [(CGRect, CGFloat)] {
            ctx.addPath(CGPath(roundedRect: rect, cornerWidth: 34, cornerHeight: 34, transform: nil))
            ctx.setStrokeColor(gold)
            ctx.setLineWidth(w)
            ctx.strokePath()
        }
        // 顶部中央：交扣戒指 + 钻石
        let cy = (line1.minY + line2.minY) / 2
        ctx.setLineWidth(7)
        ctx.setStrokeColor(gold)
        ctx.strokeEllipse(in: CGRect(x: FW / 2 - 46, y: cy - 24, width: 48, height: 48))
        ctx.setStrokeColor(goldLight)
        ctx.strokeEllipse(in: CGRect(x: FW / 2 - 2, y: cy - 24, width: 48, height: 48))
        fillSparkle(ctx, FW / 2 + 23, cy - 40, 16, rgb(235, 245, 255))
        // 四角小钻石（菱形）
        ctx.setFillColor(goldLight)
        for (x, y) in [(line2.minX, line2.minY), (line2.maxX, line2.minY),
                       (line2.minX, line2.maxY), (line2.maxX, line2.maxY)] {
            ctx.move(to: CGPoint(x: x, y: y - 16))
            ctx.addLine(to: CGPoint(x: x + 11, y: y))
            ctx.addLine(to: CGPoint(x: x, y: y + 16))
            ctx.addLine(to: CGPoint(x: x - 11, y: y))
            ctx.closePath()
            ctx.fillPath()
        }
        // 底部中央小爱心
        fillHeart(ctx, FW / 2, (line1.maxY + line2.maxY) / 2, 18, gold)
    }
    savePNG(ctx, "frame-minimal-gold.png")
}

// MARK: - ⑤ 奶油甜心 frame-cream-sweet.png（粉边 + 圆点 + 蝴蝶结 + 爱心）

do {
    let ctx = makeCtx(W, H)
    withTopDown(ctx) {
        // 粉色边带
        fillBand(ctx, outer: outerRect, inner: innerRect,
                 outerRadius: 44, innerRadius: 30, color: pink)
        // 内缘白色细线
        ctx.addPath(CGPath(roundedRect: innerRect.insetBy(dx: -8, dy: -8),
                           cornerWidth: 30, cornerHeight: 30, transform: nil))
        ctx.setStrokeColor(rgb(255, 255, 255))
        ctx.setLineWidth(4)
        ctx.strokePath()
        // 边带上的奶油色圆点（沿四边中轴排布）
        ctx.setFillColor(cream)
        let mid = bandW / 2
        var dots: [(CGFloat, CGFloat)] = []
        for i in 0..<6 {
            let x = outerRect.minX + 140 + CGFloat(i) * (outerRect.width - 280) / 5
            dots.append((x, outerRect.minY + mid))
            dots.append((x, outerRect.maxY - mid))
        }
        for i in 0..<9 {
            let y = outerRect.minY + 200 + CGFloat(i) * (outerRect.height - 400) / 8
            dots.append((outerRect.minX + mid, y))
            dots.append((outerRect.maxX - mid, y))
        }
        for (x, y) in dots {
            ctx.fillEllipse(in: CGRect(x: x - 12, y: y - 12, width: 24, height: 24))
        }
        // 顶部中央蝴蝶结（两翼 + 中结 + 飘带）
        let bx = FW / 2, by = outerRect.minY + mid
        ctx.setFillColor(pinkDeep)
        ctx.move(to: CGPoint(x: bx - 8, y: by))
        ctx.addLine(to: CGPoint(x: bx - 74, y: by - 38))
        ctx.addLine(to: CGPoint(x: bx - 74, y: by + 38))
        ctx.closePath()
        ctx.fillPath()
        ctx.move(to: CGPoint(x: bx + 8, y: by))
        ctx.addLine(to: CGPoint(x: bx + 74, y: by - 38))
        ctx.addLine(to: CGPoint(x: bx + 74, y: by + 38))
        ctx.closePath()
        ctx.fillPath()
        ctx.fillEllipse(in: CGRect(x: bx - 16, y: by - 16, width: 32, height: 32))
        // 底部中央双爱心
        fillHeart(ctx, FW / 2 - 30, outerRect.maxY - mid, 22, cream)
        fillHeart(ctx, FW / 2 + 30, outerRect.maxY - mid, 22, pinkLight)
        // 两侧边中央小爱心
        fillHeart(ctx, outerRect.minX + mid, FH / 2, 20, cream)
        fillHeart(ctx, outerRect.maxX - mid, FH / 2, 20, cream)
    }
    savePNG(ctx, "frame-cream-sweet.png")
}

// MARK: - ⑥ 花藤缠绕 frame-vine.png（透明感藤蔓 + 小花，四角对缠）

do {
    let ctx = makeCtx(W, H)
    withTopDown(ctx) {
        // 极浅奶油半透明边带，保证打印可读性
        fillBand(ctx, outer: outerRect, inner: innerRect,
                 outerRadius: 44, innerRadius: 30, color: rgb(255, 247, 240, 0.55))
        // 四角藤蔓：弧线 + 叶子 + 小花，沿边向中部延伸
        func vine(from start: CGPoint, to end: CGPoint, bulge: CGPoint, flowers: Int) {
            ctx.setStrokeColor(leafGreen)
            ctx.setLineWidth(9)
            ctx.setLineCap(.round)
            ctx.move(to: start)
            ctx.addQuadCurve(to: end, control: bulge)
            ctx.strokePath()
            for i in 0..<flowers {
                let t = (CGFloat(i) + 0.6) / CGFloat(flowers + 1)
                // 二次贝塞尔取点
                let x = (1 - t) * (1 - t) * start.x + 2 * (1 - t) * t * bulge.x + t * t * end.x
                let y = (1 - t) * (1 - t) * start.y + 2 * (1 - t) * t * bulge.y + t * t * end.y
                fillLeaf(ctx, x + 12, y + 12, 20, angle: .pi / 5, leafGreen)
                fillFlower(ctx, x, y, i % 2 == 0 ? 34 : 26,
                           petal: i % 2 == 0 ? pink : pinkLight, core: rgb(255, 215, 90))
            }
        }
        let m: CGFloat = margin + bandW / 2
        // 左上角：沿顶边向右 + 沿左边向下
        vine(from: CGPoint(x: m + 10, y: m + 10), to: CGPoint(x: m + 420, y: m),
             bulge: CGPoint(x: m + 220, y: m - 26), flowers: 3)
        vine(from: CGPoint(x: m + 10, y: m + 10), to: CGPoint(x: m, y: m + 560),
             bulge: CGPoint(x: m - 26, y: m + 300), flowers: 4)
        // 右上角
        vine(from: CGPoint(x: FW - m - 10, y: m + 10), to: CGPoint(x: FW - m - 420, y: m),
             bulge: CGPoint(x: FW - m - 220, y: m - 26), flowers: 3)
        vine(from: CGPoint(x: FW - m - 10, y: m + 10), to: CGPoint(x: FW - m, y: m + 560),
             bulge: CGPoint(x: FW - m + 26, y: m + 300), flowers: 4)
        // 左下角
        vine(from: CGPoint(x: m + 10, y: FH - m - 10), to: CGPoint(x: m + 360, y: FH - m),
             bulge: CGPoint(x: m + 200, y: FH - m + 26), flowers: 2)
        vine(from: CGPoint(x: m + 10, y: FH - m - 10), to: CGPoint(x: m, y: FH - m - 560),
             bulge: CGPoint(x: m - 26, y: FH - m - 300), flowers: 4)
        // 右下角
        vine(from: CGPoint(x: FW - m - 10, y: FH - m - 10), to: CGPoint(x: FW - m - 360, y: FH - m),
             bulge: CGPoint(x: FW - m - 200, y: FH - m + 26), flowers: 2)
        vine(from: CGPoint(x: FW - m - 10, y: FH - m - 10), to: CGPoint(x: FW - m, y: FH - m - 560),
             bulge: CGPoint(x: FW - m + 26, y: FH - m - 300), flowers: 4)
    }
    savePNG(ctx, "frame-vine.png")
}

print("\n完成：6 种婚礼相框 → \(outDir.path)")
print("安装：cp <风格>.png assets/themes/<主题>/frame.png")
