import AppKit
import CoreGraphics
import CoreImage
import Foundation
import BoothCore

// ============================================================
// DecorationCore — 搞怪大头贴装饰算子（管线可选阶段）
//
// 模板 = 数据（decorations/<name>/template.json + 贴纸 PNG），
// 运营加新模板不改代码。模板四要素：
//   warps    人脸形变（大头/小脸/大眼/凸嘴，软蒙版局部缩放）
//   stickers 贴纸（按人脸关键点锚定，随脸缩放/旋转）
//   filter   风格化滤镜（comic/crystallize/mono/…）
//   caption  底部搞笑字幕条
//
// 应用顺序：贴纸 → 形变 → 滤镜 → 字幕条
//   （贴纸先于形变：贴纸跟着脸一起被放大/扭曲，大头贴的猫耳
//    随大头同步放大是预期效果，且锚点无需做形变补偿换算）
//
// 坐标系：全链路统一"像素坐标、原点左下、y 向上"
// （Vision 归一化 × 尺寸 / CIImage extent / CGContext 三者天然一致）
//
// 降级策略：与管线其他步一致——单步失败由 ImagingService 捕获
// 降级跳过整段装饰不阻断出片；素材缺失/关键点缺失跳过单项。
// ============================================================

// MARK: - 模板模型（JSON 落盘格式）

/// 搞怪装饰模板。全部字段带默认值，老模板缺字段可解码。
struct DecorationTemplate: Codable, Equatable {

    /// 人脸形变项
    struct Warp: Codable, Equatable {
        /// 形变种类
        enum Kind: String, Codable, Equatable {
            case bigHead      // 大头：脸中心径向放大
            case slimFace     // 小脸：下颌区域径向收缩
            case bigEyes      // 大眼：两眼分别径向放大
            case poutyMouth   // 凸嘴：嘴部径向放大
        }
        var kind: Kind
        /// 强度 0~1（0.45 为适中的搞怪档）
        var strength: Double = 0.45

        init(kind: Kind, strength: Double = 0.45) {
            self.kind = kind
            self.strength = strength
        }

        init(from decoder: Decoder) throws {
            let c = try decoder.container(keyedBy: CodingKeys.self)
            kind = try c.decode(Kind.self, forKey: .kind)
            strength = try c.decodeIfPresent(Double.self, forKey: .strength) ?? 0.45
        }
    }

    /// 贴纸项
    struct Sticker: Codable, Equatable {
        /// 锚定的人脸关键点
        enum Anchor: String, Codable, Equatable {
            case leftEye, rightEye, eyeMidpoint
            case mouth, faceCenter, faceTop
        }
        /// 贴纸文件名（相对模板目录）
        var file: String
        var anchor: Anchor
        /// 贴纸高度 = scale × 两眼间距
        var scale: Double = 1.0
        /// 锚点偏移（单位：两眼间距，脸局部坐标系，随 roll 旋转）
        var offsetX: Double = 0
        var offsetY: Double = 0
        /// 是否跟随头部 roll 旋转
        var rotateWithFace: Bool = true

        init(file: String, anchor: Anchor, scale: Double = 1.0,
             offsetX: Double = 0, offsetY: Double = 0, rotateWithFace: Bool = true) {
            self.file = file
            self.anchor = anchor
            self.scale = scale
            self.offsetX = offsetX
            self.offsetY = offsetY
            self.rotateWithFace = rotateWithFace
        }

        init(from decoder: Decoder) throws {
            let c = try decoder.container(keyedBy: CodingKeys.self)
            file = try c.decode(String.self, forKey: .file)
            anchor = try c.decode(Anchor.self, forKey: .anchor)
            scale = try c.decodeIfPresent(Double.self, forKey: .scale) ?? 1.0
            offsetX = try c.decodeIfPresent(Double.self, forKey: .offsetX) ?? 0
            offsetY = try c.decodeIfPresent(Double.self, forKey: .offsetY) ?? 0
            rotateWithFace = try c.decodeIfPresent(Bool.self, forKey: .rotateWithFace) ?? true
        }
    }

    /// 底部字幕条
    struct Caption: Codable, Equatable {
        var text: String
        var colorHex: String = "#FFFFFF"
        /// 字号（像素，正对 1200×1800 成片量级）
        var size: Double = 64

        init(text: String, colorHex: String = "#FFFFFF", size: Double = 64) {
            self.text = text
            self.colorHex = colorHex
            self.size = size
        }

        init(from decoder: Decoder) throws {
            let c = try decoder.container(keyedBy: CodingKeys.self)
            text = try c.decode(String.self, forKey: .text)
            colorHex = try c.decodeIfPresent(String.self, forKey: .colorHex) ?? "#FFFFFF"
            size = try c.decodeIfPresent(Double.self, forKey: .size) ?? 64
        }
    }

    var warps: [Warp] = []
    var stickers: [Sticker] = []
    /// 风格化滤镜别名（comic/crystallize/mono/chrome/posterize）或原生 CIFilter 名
    var filter: String?
    var caption: Caption?

    // 老模板兼容：缺字段回退默认值
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        warps = try c.decodeIfPresent([Warp].self, forKey: .warps) ?? []
        stickers = try c.decodeIfPresent([Sticker].self, forKey: .stickers) ?? []
        filter = try c.decodeIfPresent(String.self, forKey: .filter)
        caption = try c.decodeIfPresent(Caption.self, forKey: .caption)
    }

    init(warps: [Warp] = [], stickers: [Sticker] = [], filter: String? = nil, caption: Caption? = nil) {
        self.warps = warps
        self.stickers = stickers
        self.filter = filter
        self.caption = caption
    }

    /// 无任何有效内容（服务层跳过用）
    var isEmpty: Bool { warps.isEmpty && stickers.isEmpty && filter == nil && caption == nil }
}

// MARK: - 装饰算子

enum DecorationCore {

    /// 模板目录（decorationsDir/<name>）下的模板文件名
    static let templateFileName = "template.json"

    // MARK: 模板加载

    /// 加载模板；目录或文件不存在 / JSON 损坏返回 nil（上层降级记日志）
    static func loadTemplate(named name: String, decorationsDir: URL) -> DecorationTemplate? {
        // 模板名拼路径，拒绝携带路径分隔符的名字
        guard !name.isEmpty, !name.contains("/") else { return nil }
        let url = decorationsDir
            .appendingPathComponent(name, isDirectory: true)
            .appendingPathComponent(templateFileName)
        guard let data = try? Data(contentsOf: url) else { return nil }
        guard let template = try? JSONDecoder().decode(DecorationTemplate.self, from: data) else {
            Log.imaging.warn("装饰模板[\(name)] JSON 解析失败，忽略")
            return nil
        }
        return template
    }

    /// 模板素材目录（贴纸 PNG 所在地）
    static func templateDir(named name: String, decorationsDir: URL) -> URL {
        decorationsDir.appendingPathComponent(name, isDirectory: true)
    }

    // MARK: 总入口

    /// 对单张照片应用完整装饰：贴纸 → 形变 → 滤镜 → 字幕条。
    /// faces 为空时跳过贴纸/形变（滤镜/字幕照常），不视为错误。
    static func apply(_ image: CGImage,
                      template: DecorationTemplate,
                      faces: [FaceGeometry],
                      templateDir: URL,
                      ctx: CIContext) throws -> CGImage {
        guard !template.isEmpty else { return image }
        var out = image
        if !template.stickers.isEmpty, !faces.isEmpty {
            out = drawStickers(out, stickers: template.stickers, faces: faces, templateDir: templateDir)
        }
        if !template.warps.isEmpty, !faces.isEmpty {
            out = try applyWarps(out, warps: template.warps, faces: faces, ctx: ctx)
        }
        if let filterName = template.filter {
            out = try applyFilter(out, name: filterName, ctx: ctx)
        }
        if let caption = template.caption {
            out = try drawCaption(out, caption: caption)
        }
        return out
    }

    // MARK: ① 贴纸（CoreGraphics 合成）

    /// 贴纸按人脸锚定绘制：高度 = scale × 两眼间距，随 roll 旋转，
    /// 偏移量以两眼间距为单位（模板跨照片尺寸通用）。
    static func drawStickers(_ image: CGImage,
                             stickers: [DecorationTemplate.Sticker],
                             faces: [FaceGeometry],
                             templateDir: URL) -> CGImage {
        let size = CGSize(width: image.width, height: image.height)
        let ctx = PipelineCore.makeBitmapContext(size: size)
        ctx.draw(image, in: CGRect(origin: .zero, size: size))

        for face in faces {
            // 眼距是贴纸缩放/偏移的基准长度，取不到该脸的跳过
            guard let eyeDist = face.eyeDistance, eyeDist > 1 else {
                Log.imaging.debug("装饰：该脸缺少双眼关键点，跳过贴纸")
                continue
            }
            for sticker in stickers {
                guard let stickerImage = PipelineCore.loadCGImage(templateDir.appendingPathComponent(sticker.file)) else {
                    Log.imaging.warn("装饰：贴纸素材[\(sticker.file)]缺失，跳过")
                    continue
                }
                guard let anchor = anchorPoint(sticker.anchor, face: face) else {
                    Log.imaging.debug("装饰：贴纸锚点关键点缺失(\(sticker.anchor.rawValue))，跳过")
                    continue
                }
                // 高度按眼距缩放，宽度保贴纸自身比例
                let height = CGFloat(sticker.scale) * eyeDist
                let aspect = CGFloat(stickerImage.width) / CGFloat(max(1, stickerImage.height))
                let width = height * aspect

                ctx.saveGState()
                ctx.translateBy(x: anchor.x, y: anchor.y)
                if sticker.rotateWithFace { ctx.rotate(by: face.rollAngle) }
                ctx.translateBy(x: CGFloat(sticker.offsetX) * eyeDist,
                                y: CGFloat(sticker.offsetY) * eyeDist)
                ctx.draw(stickerImage, in: CGRect(x: -width / 2, y: -height / 2, width: width, height: height))
                ctx.restoreGState()
            }
        }
        guard let out = ctx.makeImage() else { return image }
        return out
    }

    /// 锚点关键点解析（缺关键点返回 nil 由调用方跳过）
    private static func anchorPoint(_ anchor: DecorationTemplate.Sticker.Anchor,
                                    face: FaceGeometry) -> CGPoint? {
        switch anchor {
        case .leftEye: return face.leftEyeCenter
        case .rightEye: return face.rightEyeCenter
        case .eyeMidpoint: return face.eyeMidpoint
        case .mouth: return face.mouthCenter
        case .faceCenter: return face.faceCenter
        case .faceTop: return CGPoint(x: face.rect.midX, y: face.rect.maxY)
        }
    }

    // MARK: ② 形变（软蒙版局部缩放）

    /// 逐脸逐形变项应用局部缩放。
    ///
    /// 实现说明：经典做法是 CIWarpKernel 自定义 shader，但 GL 语法的
    /// kernel 在 Metal-only 渲染下 apply 已返回 nil（实测 macOS 26 SDK），
    /// 改用等效的软蒙版局部缩放：以形变中心缩放采样整图，用径向渐变
    /// 蒙版（中心白→边缘黑）与原图混合 —— 视觉上即平滑的径向 bloat/pinch。
    static func applyWarps(_ image: CGImage,
                           warps: [DecorationTemplate.Warp],
                           faces: [FaceGeometry],
                           ctx: CIContext) throws -> CGImage {
        var ci = CIImage(cgImage: image)
        let extent = ci.extent

        for face in faces {
            for warp in warps {
                for params in warpParameters(warp, face: face) {
                    ci = localZoom(ci, center: params.center, radius: params.radius, zoom: params.zoom)
                }
            }
        }
        return try PipelineCore.render(ci.cropped(to: extent), ctx: ctx)
    }

    /// 单次局部缩放参数
    private struct WarpParams {
        var center: CGPoint
        var radius: CGFloat
        /// 采样缩放：>1 = 放大（bloat），<1 = 收缩（pinch）
        var zoom: CGFloat
    }

    /// 形变种类 → (中心, 半径, 缩放倍数)。缺关键点的形变项跳过。
    private static func warpParameters(_ warp: DecorationTemplate.Warp,
                                       face: FaceGeometry) -> [WarpParams] {
        // 强度钳到有效区间：过强 (>0.85) 会把五官挤出脸框
        let strength = min(max(warp.strength, 0.05), 0.85)
        switch warp.kind {
        case .bigHead:
            // 脸中心放大，半径盖住整脸
            let radius = max(face.rect.width, face.rect.height) * 0.75
            return [WarpParams(center: face.faceCenter, radius: radius, zoom: 1 + strength * 0.6)]
        case .slimFace:
            // 下颌区域收缩（中心放脸下部，把下巴往脸心收）
            let center = CGPoint(x: face.rect.midX, y: face.rect.minY + face.rect.height * 0.30)
            return [WarpParams(center: center, radius: face.rect.width * 0.95, zoom: 1 - strength * 0.35)]
        case .bigEyes:
            // 双眼各自放大，半径约眼距一半
            guard let eyeDist = face.eyeDistance,
                  let left = face.leftEyeCenter, let right = face.rightEyeCenter else { return [] }
            let radius = eyeDist * 0.45
            let zoom = 1 + strength * 0.8
            return [WarpParams(center: left, radius: radius, zoom: zoom),
                    WarpParams(center: right, radius: radius, zoom: zoom)]
        case .poutyMouth:
            guard let mouth = face.mouthCenter else { return [] }
            return [WarpParams(center: mouth, radius: face.rect.width * 0.35, zoom: 1 + strength * 0.7)]
        }
    }

    /// 软蒙版局部缩放：以 center 为不动点缩放采样，径向渐变蒙版控制生效范围。
    /// zoom > 1 = 中心区域放大（bloat）；< 1 = 收缩（pinch）。
    private static func localZoom(_ input: CIImage, center: CGPoint, radius: CGFloat, zoom: CGFloat) -> CIImage {
        let extent = input.extent
        // 以 center 为不动点缩放内容：zoom>1 → 内容向外摊开 → 中心区域被放大
        // （transformed(by:) 作用在内容上：点 x 映射到 c + (x-c)·zoom）
        let transform = CGAffineTransform(translationX: center.x, y: center.y)
            .scaledBy(x: zoom, y: zoom)
            .translatedBy(x: -center.x, y: -center.y)
        let scaled = input.transformed(by: transform)

        // 径向软蒙版：内圈全白（全效）→ 半径处全黑（无效），中间线性过渡
        guard let gradient = CIFilter(name: "CIRadialGradient") else { return input }
        gradient.setValue(CIVector(x: center.x, y: center.y), forKey: "inputCenter")
        gradient.setValue(radius * 0.55, forKey: "inputRadius0")
        gradient.setValue(radius, forKey: "inputRadius1")
        gradient.setValue(CIColor(red: 1, green: 1, blue: 1), forKey: "inputColor0")
        gradient.setValue(CIColor(red: 0, green: 0, blue: 0), forKey: "inputColor1")
        guard let gradientOut = gradient.outputImage?.cropped(to: extent) else { return input }

        // 蒙版混合：白处用缩放图，黑处用原图
        guard let blend = CIFilter(name: "CIBlendWithMask") else { return input }
        blend.setValue(scaled, forKey: kCIInputImageKey)
        blend.setValue(input, forKey: kCIInputBackgroundImageKey)
        blend.setValue(gradientOut, forKey: kCIInputMaskImageKey)
        guard let out = blend.outputImage else { return input }
        return out.cropped(to: extent)
    }

    // MARK: ③ 风格化滤镜

    /// 滤镜别名 → (CIFilter 名, 保守参数)。函数体内构造，避开非 Sendable 的
    /// [String: Any] 全局静态（Swift 6 严格并发）。
    private static func resolveFilter(_ name: String) -> (name: String, params: [String: Any]) {
        switch name {
        case "comic": return ("CIComicEffect", [:])
        case "crystallize": return ("CICrystallize", ["inputRadius": 12.0])
        case "posterize": return ("CIColorPosterize", [:])
        case "mono": return ("CIPhotoEffectMono", [:])
        case "chrome": return ("CIPhotoEffectChrome", [:])
        default: return (name, [:])   // 原生 CIFilter 名直传
        }
    }

    /// 应用风格化滤镜。别名不认识时按原生 CIFilter 名尝试。
    static func applyFilter(_ image: CGImage, name: String, ctx: CIContext) throws -> CGImage {
        let resolved = resolveFilter(name)
        guard let filter = CIFilter(name: resolved.name),
              filter.inputKeys.contains(kCIInputImageKey) else {
            throw BoothError.imagingFailed("装饰滤镜[\(name)]不可用")
        }
        let input = CIImage(cgImage: image)
        filter.setValue(input, forKey: kCIInputImageKey)
        // 写参数前检查键名（CoreImage 错键抛 ObjC 异常，Swift 接不住）
        for (key, value) in resolved.params where filter.inputKeys.contains(key as String) {
            filter.setValue(value, forKey: key)
        }
        guard let output = filter.outputImage else {
            throw BoothError.imagingFailed("装饰滤镜[\(name)]输出为空")
        }
        return try PipelineCore.render(output.cropped(to: input.extent), ctx: ctx)
    }

    // MARK: ④ 字幕条（CoreGraphics 文字）

    /// 底部居中字幕条：主题色文字 + 深色描边（浅/深背景均可读）。
    static func drawCaption(_ image: CGImage, caption: DecorationTemplate.Caption) throws -> CGImage {
        let size = CGSize(width: image.width, height: image.height)
        let ctx = PipelineCore.makeBitmapContext(size: size)
        ctx.draw(image, in: CGRect(origin: .zero, size: size))

        // 字号按图片宽度相对 1200 基准等比伸缩（单张原图与成片都能用）
        let fontSize = CGFloat(caption.size) * (size.width / 1200.0)
        let font = NSFont.boothRoundedBold(size: fontSize)
        let attrs: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: NSColor(hexString: caption.colorHex) ?? .white,
            .strokeColor: NSColor.black,
            .strokeWidth: -4.0,   // 负值 = 描边 + 填充
        ]
        let text = NSAttributedString(string: caption.text, attributes: attrs)
        let textSize = text.size()
        let margin = size.height * 0.05
        // drawText 用顶部原点坐标：底部居中
        let point = CGPoint(x: (size.width - textSize.width) / 2,
                            y: size.height - margin - textSize.height)
        PipelineCore.drawText(text, topLeft: point, in: ctx, canvas: size)
        return try PipelineCore.makeImage(from: ctx)
    }
}
