import AppKit
import CoreGraphics
import CoreImage
import Foundation
import ImageIO
import UniformTypeIdentifiers
import BoothCore

// ============================================================
// PipelineCore — 管线底层图像算子集合（SPEC §6）
// 全部为纯函数式静态方法、同步执行、不持有可变状态，
// 由 ImagingService 在后台（协作线程池）调用。
// 每个算子只负责一步，失败抛错由上层决定降级策略。
// ============================================================

enum PipelineCore {
    /// 打印成片规格：6 寸竖版 1200×1800 @300dpi（SPEC §7）
    static let printSize = CGSize(width: 1200, height: 1800)
    /// 展示位图长边
    static let displayLongEdge = 1600
    /// 打印 JPEG 质量
    static let printJPEGQuality: Double = 0.92
    /// 展示 JPEG 质量
    static let displayJPEGQuality: Double = 0.85

    // MARK: - ① 解码 + EXIF 定向

    /// 相机 JPEG Data → 已按 EXIF 方向转正的 CGImage。
    /// 相机横握/竖握会产生非 .up 的方向标记，直接拿原始像素排版会躺倒，
    /// 这里统一在管线入口处转正，后续算子无需关心方向。
    static func decodeOriented(_ data: Data) throws -> CGImage {
        guard let src = CGImageSourceCreateWithData(data as CFData, nil) else {
            throw BoothError.imagingFailed("无法创建图像源（数据可能不是 JPEG）")
        }
        guard let raw = CGImageSourceCreateImageAtIndex(src, 0, nil) else {
            throw BoothError.imagingFailed("图像解码失败")
        }
        let props = CGImageSourceCopyPropertiesAtIndex(src, 0, nil) as? [CFString: Any]
        let rawValue = (props?[kCGImagePropertyOrientation] as? NSNumber)?.uint32Value ?? 1
        let orientation = CGImagePropertyOrientation(rawValue: rawValue) ?? .up
        guard orientation != .up else { return raw }
        return try raw.orientedCopy(orientation)
    }

    // MARK: - ② 自动调色

    /// 自动调色：CIImage.autoAdjustmentFilters 自动增强（曝光/对比/红眼等），
    /// 再叠一层轻度 CIVibrance + 对比度，让活动现场照片更通透。
    static func autoColor(_ image: CGImage, ctx: CIContext) throws -> CGImage {
        let input = CIImage(cgImage: image)
        var output = input
        // 系统自动调整滤镜组（降噪、曝光、对比、饱和等启发式增强）。
        // 注意：返回的部分滤镜不接受 inputImage 键（直接 setValue 会抛 ObjC 异常崩溃，
        // Swift do/catch 接不住），必须先检查 inputKeys。
        let filters = input.autoAdjustmentFilters(options: [
            .redEye: false,   // 拍照亭闪光场景不强制去红眼，避免误伤
        ])
        for f in filters where f.inputKeys.contains(kCIInputImageKey) {
            f.setValue(output, forKey: kCIInputImageKey)
            if let out = f.outputImage { output = out }
        }
        // 轻度活力 + 对比：活动照偏灰时提气色，数值保守避免过饱和。
        // 所有 setValue 前先检查 inputKeys —— 写错键名 CoreImage 抛的是 ObjC 异常，
        // Swift do/catch 接不住会直接崩进程。
        if let vibrance = CIFilter(name: "CIVibrance"),
           vibrance.inputKeys.contains(kCIInputImageKey), vibrance.inputKeys.contains(kCIInputAmountKey) {
            vibrance.setValue(output, forKey: kCIInputImageKey)
            vibrance.setValue(0.25, forKey: kCIInputAmountKey)
            if let out = vibrance.outputImage { output = out }
        }
        if let controls = CIFilter(name: "CIColorControls"),
           controls.inputKeys.contains(kCIInputImageKey), controls.inputKeys.contains(kCIInputContrastKey) {
            controls.setValue(output, forKey: kCIInputImageKey)
            controls.setValue(1.06, forKey: kCIInputContrastKey)
            if let out = controls.outputImage { output = out }
        }
        // 滤镜链可能产生无限 extent，裁剪回原图范围再渲染
        return try render(output.cropped(to: input.extent), ctx: ctx)
    }

    // MARK: - ③ 美肤（轻量方案）

    /// 美肤磨皮：轻量方案 —— 整图轻度高斯模糊后与原图按强度做 Alpha 混合。
    /// 说明：没有做五官边缘保护蒙版（那需要人脸关键点 + 边缘保留滤波，成本高），
    /// 采用"低模糊半径 × 部分透明混合"的策略，在 0-100 强度下都不会糊掉细节，
    /// 视觉上接近轻度磨皮。简单稳定、无第三方依赖，满足拍照亭实时出片预算。
    static func skinSmooth(_ image: CGImage, strength: Int, ctx: CIContext) throws -> CGImage {
        let clamped = max(0, min(100, strength))
        guard clamped > 0 else { return image }
        let input = CIImage(cgImage: image)
        // 模糊半径随强度线性增长（6000px 大图 2~12px 足够轻）
        let radius = 2.0 + Double(clamped) / 100.0 * 10.0
        guard let blur = CIFilter(name: "CIGaussianBlur") else { return image }
        blur.setValue(input, forKey: kCIInputImageKey)
        blur.setValue(radius, forKey: kCIInputRadiusKey)
        guard let blurred = blur.outputImage?.cropped(to: input.extent) else { return image }
        // 按强度生成常数 Alpha 蒙版：强度 100 → 80% 模糊 + 20% 原图
        let mix = Double(clamped) / 100.0 * 0.8
        guard let blend = CIFilter(name: "CIBlendWithAlphaMask") else { return image }
        blend.setValue(blurred, forKey: kCIInputImageKey)
        blend.setValue(input, forKey: kCIInputBackgroundImageKey)
        let mask = CIImage(color: CIColor(red: 1, green: 1, blue: 1, alpha: mix)).cropped(to: input.extent)
        blend.setValue(mask, forKey: kCIInputMaskImageKey)
        guard let out = blend.outputImage else { return image }
        return try render(out.cropped(to: input.extent), ctx: ctx)
    }

    // MARK: - ④ 换背景

    /// 换背景：人像 matte（白=人）经 CIBlendWithMask 把人合成到背景图上。
    /// 背景图按"覆盖填充"（aspect-fill）缩放到当前照片尺寸，保证无黑边。
    static func replaceBackground(person: CGImage, mask: CGImage, background: CGImage, ctx: CIContext) throws -> CGImage {
        let extent = CGRect(x: 0, y: 0, width: person.width, height: person.height)
        var bg = CIImage(cgImage: background)
        // 背景覆盖填充到照片尺寸
        let scale = max(extent.width / bg.extent.width, extent.height / bg.extent.height)
        bg = bg.transformed(by: CGAffineTransform(scaleX: scale, y: scale))
        let dx = extent.midX - bg.extent.midX
        let dy = extent.midY - bg.extent.midY
        bg = bg.transformed(by: CGAffineTransform(translationX: dx, y: dy)).cropped(to: extent)
        // matte 契约要求与输入同尺寸，防御性处理尺寸不一致的实现
        var matte = CIImage(cgImage: mask)
        if matte.extent.size != extent.size {
            let ms = max(extent.width / matte.extent.width, extent.height / matte.extent.height)
            matte = matte.transformed(by: CGAffineTransform(scaleX: ms, y: ms)).cropped(to: extent)
        }
        guard let blend = CIFilter(name: "CIBlendWithMask") else {
            throw BoothError.imagingFailed("CIBlendWithMask 不可用")
        }
        blend.setValue(CIImage(cgImage: person), forKey: kCIInputImageKey)
        blend.setValue(bg, forKey: kCIInputBackgroundImageKey)
        blend.setValue(matte, forKey: kCIInputMaskImageKey)
        guard let out = blend.outputImage else {
            throw BoothError.imagingFailed("换背景合成失败")
        }
        return try render(out.cropped(to: extent), ctx: ctx)
    }

    // MARK: - ⑤ 排版输出

    /// 单张模式：横构图照片（3:2）裁切填充竖版 6 寸（2:3）。
    /// “智能居中裁切”：按覆盖缩放后取画面中心区域 —— 拍照亭场景人站画面中央，
    /// 中心裁切命中率最高；后续如接入人脸检测可在此微调裁切偏移。
    static func composeSingle(_ photo: CGImage) throws -> CGImage {
        let ctx = makeBitmapContext(size: printSize)
        ctx.setFillColor(CGColor(red: 1, green: 1, blue: 1, alpha: 1))
        ctx.fill(CGRect(origin: .zero, size: printSize))
        drawFill(photo, in: CGRect(origin: .zero, size: printSize), ctx: ctx)
        return try makeImage(from: ctx)
    }

    /// 拼版模式：多布局排版成 1200×1800 大头贴（PhotoBoothProject 经典 collage 形态）。
    /// 布局网格由 CollageLayout 决定：strip=N 格纵列（行数随张数）、grid2x2=2×2、duo=1×2。
    /// 布局：四周 40px 白边，格间距 24px，底部 160px 品牌条（mascot + 日期 + Photobooth 字样），
    /// 品牌条与最后一格之间留 24px。
    static func composeCollage(photos: [CGImage],
                               layout: CollageLayout,
                               themeDir: URL,
                               accent: NSColor?,
                               dateText: String) throws -> CGImage {
        let canvas = printSize
        let ctx = makeBitmapContext(size: canvas)
        // 白底
        ctx.setFillColor(CGColor(red: 1, green: 1, blue: 1, alpha: 1))
        ctx.fill(CGRect(origin: .zero, size: canvas))

        let n = max(1, photos.count)
        let outer: CGFloat = 40
        let gap: CGFloat = 24
        let brandH: CGFloat = 160
        let cols = max(1, layout.columns)
        let rows = layout == .strip ? n : max(1, (n + cols - 1) / cols)
        let cellW = (canvas.width - outer * 2 - gap * CGFloat(cols - 1)) / CGFloat(cols)
        let cellH = (canvas.height - outer * 2 - brandH - gap - gap * CGFloat(rows - 1)) / CGFloat(rows)

        // CGContext 原点在左下角，自上而下、从左到右排格需换算 y
        for (i, p) in photos.enumerated() {
            let col = CGFloat(i % cols)
            let row = CGFloat(i / cols)
            let topFromTop = outer + row * (cellH + gap)
            let x = outer + col * (cellW + gap)
            let y = canvas.height - topFromTop - cellH
            drawFill(p, in: CGRect(x: x, y: y, width: cellW, height: cellH), ctx: ctx)
        }

        // 品牌条背景：主题 accent 色，无主题素材则浅灰兜底
        let brandRect = CGRect(x: outer, y: outer, width: canvas.width - outer * 2, height: brandH)
        let barColor = accent ?? NSColor(calibratedWhite: 0.94, alpha: 1)
        ctx.setFillColor(barColor.cgColor)
        ctx.fill(brandRect)
        // 深色条用白字、浅色条用深灰字
        let textColor: NSColor = (accent != nil) ? .white : NSColor(calibratedWhite: 0.2, alpha: 1)

        // mascot（可选素材）：绘制在品牌条左侧，保持比例
        var textLeading = brandRect.minX + 24
        if let mascot = loadCGImage(themeDir.appendingPathComponent("mascot.png")) {
            let side = brandH - 24
            let scale = min(side / CGFloat(mascot.width), side / CGFloat(mascot.height))
            let dw = CGFloat(mascot.width) * scale
            let dh = CGFloat(mascot.height) * scale
            let rect = CGRect(x: brandRect.minX + 12, y: brandRect.midY - dh / 2, width: dw, height: dh)
            ctx.draw(mascot, in: rect)
            textLeading = rect.maxX + 12
        }

        // 品牌条文字（顶部原点坐标系绘制，避免文字颠倒）
        let titleFont = NSFont.boothRoundedBold(size: 56)
        let dateFont = NSFont.boothRoundedBold(size: 32)
        let title = NSAttributedString(string: "Photobooth", attributes: [
            .font: titleFont, .foregroundColor: textColor,
        ])
        let date = NSAttributedString(string: dateText, attributes: [
            .font: dateFont, .foregroundColor: textColor,
        ])
        // 顶部原点 y：品牌条上沿 = canvas.height - brandRect.maxY
        let barTopFromTop = canvas.height - brandRect.maxY
        let titlePoint = CGPoint(x: textLeading, y: barTopFromTop + (brandH - title.size().height) / 2)
        drawText(title, topLeft: titlePoint, in: ctx, canvas: canvas)
        let datePoint = CGPoint(x: brandRect.maxX - date.size().width - 24,
                                y: barTopFromTop + (brandH - date.size().height) / 2)
        drawText(date, topLeft: datePoint, in: ctx, canvas: canvas)

        return try makeImage(from: ctx)
    }

    // MARK: - ⑤b 拍后自选滤镜（PhotoBoothProject 借鉴）

    /// 风格化滤镜：全部基于系统 CoreImage 滤镜链，无第三方依赖。
    /// .none 直接返回原图（零拷贝路径）。
    /// 所有 setValue 前检查 inputKeys（写错键名 CoreImage 抛 ObjC 异常接不住）。
    static func applyStyleFilter(_ image: CGImage, filter: PhotoFilter, ctx: CIContext) throws -> CGImage {
        guard filter != .none else { return image }
        let input = CIImage(cgImage: image)
        var output = input

        func chain(_ name: String, _ apply: (CIFilter) -> Void) {
            guard let f = CIFilter(name: name), f.inputKeys.contains(kCIInputImageKey) else { return }
            f.setValue(output, forKey: kCIInputImageKey)
            apply(f)
            if let out = f.outputImage { output = out }
        }

        switch filter {
        case .none:
            return image
        case .vivid:
            chain("CIColorControls") { f in
                if f.inputKeys.contains("inputSaturation") { f.setValue(1.35, forKey: "inputSaturation") }
                if f.inputKeys.contains(kCIInputContrastKey) { f.setValue(1.08, forKey: kCIInputContrastKey) }
            }
            chain("CIVibrance") { f in
                if f.inputKeys.contains(kCIInputAmountKey) { f.setValue(0.6, forKey: kCIInputAmountKey) }
            }
        case .warm:
            chain("CITemperatureAndTint") { f in
                if f.inputKeys.contains("inputNeutral") {
                    f.setValue(CIVector(x: 6500, y: 3000), forKey: "inputNeutral")
                }
                if f.inputKeys.contains("inputTarget") {
                    f.setValue(CIVector(x: 7800, y: 3100), forKey: "inputTarget")
                }
            }
        case .cool:
            chain("CITemperatureAndTint") { f in
                if f.inputKeys.contains("inputNeutral") {
                    f.setValue(CIVector(x: 6500, y: 3000), forKey: "inputNeutral")
                }
                if f.inputKeys.contains("inputTarget") {
                    f.setValue(CIVector(x: 5200, y: 2900), forKey: "inputTarget")
                }
            }
        case .mono:
            chain("CIPhotoEffectMono") { _ in }
        case .nostalgia:
            chain("CIPhotoEffectTransfer") { _ in }
            chain("CIVignette") { f in
                if f.inputKeys.contains("inputIntensity") { f.setValue(0.35, forKey: "inputIntensity") }
                if f.inputKeys.contains("inputRadius") { f.setValue(1.2, forKey: "inputRadius") }
            }
        }
        return try render(output.cropped(to: input.extent), ctx: ctx)
    }

    // MARK: - ⑤c 打印 QR 叠印（PhotoBoothProject 借鉴：成片上印 QR 供扫码下载电子版）

    /// 在成片右缘垂直居中位置叠印 QR 码（白底圆角垫板 + 黑码点）。
    /// 避开右下角日期水印与拼版底部品牌条。
    static func overlayQRCode(on base: CGImage, content: String, side: CGFloat = 190, ctx: CIContext) throws -> CGImage {
        let size = CGSize(width: base.width, height: base.height)
        let c = makeBitmapContext(size: size)
        c.draw(base, in: CGRect(origin: .zero, size: size))

        // 生成 QR（CIQRCodeGenerator 输出小图，按目标边长等比放大）
        guard let qr = CIFilter(name: "CIQRCodeGenerator") else {
            throw BoothError.imagingFailed("CIQRCodeGenerator 不可用")
        }
        qr.setValue(Data(content.utf8), forKey: "inputMessage")
        guard let small = qr.outputImage else {
            throw BoothError.imagingFailed("QR 码生成失败（内容过长？）")
        }
        let scale = side / max(small.extent.width, 1)
        let scaled = small.transformed(by: CGAffineTransform(scaleX: scale, y: scale))
        guard let qrCG = ctx.createCGImage(scaled, from: scaled.extent) else {
            throw BoothError.imagingFailed("QR 码渲染失败")
        }

        // 白底圆角垫板（码点直接压照片可读性差）
        let pad: CGFloat = 14
        let margin: CGFloat = 26
        let total = side + pad * 2
        let rect = CGRect(x: size.width - total - margin, y: (size.height - total) / 2,
                          width: total, height: total)
        c.setFillColor(CGColor(red: 1, green: 1, blue: 1, alpha: 1))
        let path = CGPath(roundedRect: rect, cornerWidth: 16, cornerHeight: 16, transform: nil)
        c.addPath(path)
        c.fillPath()
        c.draw(qrCG, in: rect.insetBy(dx: pad, dy: pad))
        return try makeImage(from: c)
    }

    // MARK: - ⑥ 边框 / 水印

    /// 在成片上叠加主题边框（frame.png 拉伸到成片尺寸）与右下角日期水印。
    /// 说明：边框叠加放在排版之后，因为 frame.png 是按最终 1200×1800 成片尺寸设计的。
    /// 拼版模式不画右下角水印（底部品牌条已含日期，避免重复）。
    static func overlayFrameAndWatermark(on base: CGImage,
                                         frame: CGImage?,
                                         dateText: String,
                                         accent: NSColor?,
                                         drawWatermark: Bool) throws -> CGImage {
        let size = CGSize(width: base.width, height: base.height)
        let ctx = makeBitmapContext(size: size)
        ctx.draw(base, in: CGRect(origin: .zero, size: size))
        if let frame {
            // 拉伸铺满成片（素材按成片比例设计，拉伸不会变形）
            ctx.draw(frame, in: CGRect(origin: .zero, size: size))
        }
        if drawWatermark {
            let font = NSFont.boothRoundedBold(size: 40)
            let attrs: [NSAttributedString.Key: Any] = [
                .font: font,
                .foregroundColor: accent ?? NSColor.white,   // 主题色拿不到则白字
                .strokeColor: NSColor.black,
                .strokeWidth: -3.0,   // 负值 = 描边 + 填充，深色描边保证浅色背景下可读
            ]
            let str = NSAttributedString(string: dateText, attributes: attrs)
            let s = str.size()
            let margin: CGFloat = 36
            // 顶部原点坐标：右下角
            let point = CGPoint(x: size.width - s.width - margin, y: size.height - s.height - margin)
            drawText(str, topLeft: point, in: ctx, canvas: size)
        }
        return try makeImage(from: ctx)
    }

    // MARK: - 缩放与 JPEG 输出

    /// 等比缩放到长边上限（展示位图用）
    static func scaledToLongEdge(_ image: CGImage, _ longEdge: Int) throws -> CGImage {
        let w = CGFloat(image.width), h = CGFloat(image.height)
        let edge = max(w, h)
        guard edge > CGFloat(longEdge) else { return image }
        let scale = CGFloat(longEdge) / edge
        let size = CGSize(width: (w * scale).rounded(), height: (h * scale).rounded())
        let ctx = makeBitmapContext(size: size)
        ctx.draw(image, in: CGRect(origin: .zero, size: size))
        return try makeImage(from: ctx)
    }

    /// 写 JPEG 文件；dpi 非空时写入分辨率元数据（打印位图需 300dpi）
    static func writeJPEG(_ image: CGImage, to url: URL, quality: Double, dpi: Double?) throws {
        guard let dest = CGImageDestinationCreateWithURL(url as CFURL, UTType.jpeg.identifier as CFString, 1, nil) else {
            throw BoothError.imagingFailed("无法创建 JPEG 目标: \(url.lastPathComponent)")
        }
        var props: [CFString: Any] = [kCGImageDestinationLossyCompressionQuality: quality]
        if let dpi {
            props[kCGImagePropertyDPIWidth] = dpi
            props[kCGImagePropertyDPIHeight] = dpi
        }
        CGImageDestinationAddImage(dest, image, props as CFDictionary)
        guard CGImageDestinationFinalize(dest) else {
            throw BoothError.imagingFailed("JPEG 编码失败: \(url.lastPathComponent)")
        }
    }

    // MARK: - 主题素材

    /// 加载 PNG 素材；不存在返回 nil（由上层决定降级，记日志）
    static func loadCGImage(_ url: URL) -> CGImage? {
        guard FileManager.default.fileExists(atPath: url.path),
              let src = CGImageSourceCreateWithURL(url as CFURL, nil) else { return nil }
        return CGImageSourceCreateImageAtIndex(src, 0, nil)
    }

    /// 从主题 config.json 读取 accent 色（"accent": "#RRGGBB"）；拿不到返回 nil，上层用白色兜底
    static func themeAccent(themeDir: URL) -> NSColor? {
        let url = themeDir.appendingPathComponent("config.json")
        guard let data = try? Data(contentsOf: url),
              let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let hex = obj["accent"] as? String else { return nil }
        return NSColor(hexString: hex)
    }

    // MARK: - 基础工具

    /// 8bit sRGB RGBA 位图上下文（参数固定，创建失败属编程错误）
    static func makeBitmapContext(size: CGSize) -> CGContext {
        let w = Int(size.width), h = Int(size.height)
        let ctx = CGContext(
            data: nil, width: w, height: h,
            bitsPerComponent: 8, bytesPerRow: 0,
            space: CGColorSpace(name: CGColorSpace.sRGB)!,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        )
        guard let ctx else { fatalError("无法创建位图上下文 \(w)x\(h)") }
        ctx.interpolationQuality = .high
        return ctx
    }

    static func makeImage(from ctx: CGContext) throws -> CGImage {
        guard let img = ctx.makeImage() else {
            throw BoothError.imagingFailed("位图合成失败")
        }
        return img
    }

    /// CoreImage 滤镜链渲染回 CGImage
    static func render(_ image: CIImage, ctx: CIContext) throws -> CGImage {
        guard let out = ctx.createCGImage(image, from: image.extent) else {
            throw BoothError.imagingFailed("CoreImage 渲染失败")
        }
        return out
    }

    /// 覆盖填充绘制（aspect-fill）：缩放铺满目标矩形，居中，超出部分裁掉
    static func drawFill(_ image: CGImage, in rect: CGRect, ctx: CGContext) {
        ctx.saveGState()
        ctx.clip(to: rect)
        let scale = max(rect.width / CGFloat(image.width), rect.height / CGFloat(image.height))
        let dw = CGFloat(image.width) * scale
        let dh = CGFloat(image.height) * scale
        ctx.draw(image, in: CGRect(x: rect.midX - dw / 2, y: rect.midY - dh / 2, width: dw, height: dh))
        ctx.restoreGState()
    }

    /// 绘制文字。调用方一律使用"左上角原点"的坐标。
    /// 实测：CGBitmapContext→CGImage→JPEG→显示 保持 CG y-up 方向，
    /// NSString 在 unflipped 上下文中直接画即为正立；
    /// 历史上"翻转 CTM 再画"的做法与上下文假设叠加，产出的是倒立文字（mock 演示暴露）。
    static func drawText(_ text: NSAttributedString, topLeft point: CGPoint, in ctx: CGContext, canvas: CGSize) {
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = NSGraphicsContext(cgContext: ctx, flipped: false)
        // NSString.draw(at:) 在 y-up 空间以文字矩形左下角为锚点，换算出 y-up 坐标
        let yUp = canvas.height - point.y - text.size().height
        text.draw(at: CGPoint(x: point.x, y: yUp))
        NSGraphicsContext.restoreGraphicsState()
    }
}

// MARK: - CGImage EXIF 定向

extension CGImage {
    /// 按 EXIF 方向重绘为正向像素（Apple 官方变换表）
    func orientedCopy(_ orientation: CGImagePropertyOrientation) throws -> CGImage {
        let w = CGFloat(width), h = CGFloat(height)
        var dstSize = CGSize(width: w, height: h)
        var transform = CGAffineTransform.identity
        switch orientation {
        case .up:
            return self
        case .upMirrored:
            transform = CGAffineTransform(translationX: w, y: 0).scaledBy(x: -1, y: 1)
        case .down:
            transform = CGAffineTransform(translationX: w, y: h).rotated(by: .pi)
        case .downMirrored:
            transform = CGAffineTransform(translationX: 0, y: h).scaledBy(x: 1, y: -1)
        case .leftMirrored:
            dstSize = CGSize(width: h, height: w)
            transform = CGAffineTransform(translationX: h, y: w).scaledBy(x: -1, y: 1).rotated(by: 3 * .pi / 2)
        case .left:
            dstSize = CGSize(width: h, height: w)
            transform = CGAffineTransform(translationX: 0, y: h).rotated(by: 3 * .pi / 2)
        case .rightMirrored:
            dstSize = CGSize(width: h, height: w)
            transform = CGAffineTransform(scaleX: -1, y: 1).rotated(by: .pi / 2)
        case .right:
            dstSize = CGSize(width: h, height: w)
            transform = CGAffineTransform(translationX: w, y: 0).rotated(by: .pi / 2)
        @unknown default:
            return self
        }
        let ctx = PipelineCore.makeBitmapContext(size: dstSize)
        ctx.concatenate(transform)
        ctx.draw(self, in: CGRect(x: 0, y: 0, width: w, height: h))
        return try PipelineCore.makeImage(from: ctx)
    }
}

// MARK: - 圆润粗体字体 / 十六进制颜色

extension NSFont {
    /// 圆润风格粗体（.rounded design），水印与品牌条统一使用
    static func boothRoundedBold(size: CGFloat) -> NSFont {
        let base = NSFont.systemFont(ofSize: size, weight: .bold)
        if let rounded = base.fontDescriptor.withDesign(.rounded),
           let font = NSFont(descriptor: rounded, size: size) {
            return font
        }
        return base
    }
}

extension NSColor {
    /// "#RRGGBB" / "RRGGBB" 解析
    convenience init?(hexString: String) {
        var hex = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
        if hex.hasPrefix("#") { hex.removeFirst() }
        guard hex.count == 6, let value = UInt32(hex, radix: 16) else { return nil }
        self.init(
            calibratedRed: CGFloat((value >> 16) & 0xFF) / 255,
            green: CGFloat((value >> 8) & 0xFF) / 255,
            blue: CGFloat(value & 0xFF) / 255,
            alpha: 1
        )
    }
}
