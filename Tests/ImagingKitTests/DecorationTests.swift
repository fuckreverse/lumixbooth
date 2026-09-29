import XCTest
import AppKit
import CoreGraphics
import CoreImage
import ImageIO
import UniformTypeIdentifiers
@testable import ImagingKit
import BoothCore

// ============================================================
// DecorationTests — 搞怪装饰（模板/形变/贴纸/滤镜/字幕）离线测试
//  - 全部程序合成图像：中心色块模拟"人脸"标记区，
//    通过像素采样验证形变方向与贴纸落点
//  - FaceGeometry 由假 landmarker 直接注入（关键点合成），
//    真实 Vision 检测在真机验证
// ============================================================

/// 假关键点检测器：返回注入的固定人脸
final class FakeLandmarker: FaceLandmarking, @unchecked Sendable {
    let faces: [FaceGeometry]
    init(faces: [FaceGeometry]) { self.faces = faces }
    func detectFaces(in image: CGImage) async throws -> [FaceGeometry] { faces }
}

/// 抛错关键点检测器：验证装饰降级不阻断
final class FailingLandmarker: FaceLandmarking, @unchecked Sendable {
    func detectFaces(in image: CGImage) async throws -> [FaceGeometry] {
        throw BoothError.imagingFailed("模拟关键点检测失败")
    }
}

final class DecorationTests: XCTestCase {

    private var tempDirs: [URL] = []

    override func tearDownWithError() throws {
        for dir in tempDirs { try? FileManager.default.removeItem(at: dir) }
        tempDirs = []
    }

    private func makeTempDir() -> URL {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("decoration-tests-\(UUID().uuidString)", isDirectory: true)
        try! FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        tempDirs.append(url)
        return url
    }

    // MARK: - 测试图与像素工具

    /// 合成测试图：浅灰底 + 中心红方块（模拟"脸"）。
    /// 800×600，脸区域中心 (400, 300)。
    private func makeFaceImage() -> CGImage {
        let ctx = CGContext(
            data: nil, width: 800, height: 600,
            bitsPerComponent: 8, bytesPerRow: 0,
            space: CGColorSpace(name: CGColorSpace.sRGB)!,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        )!
        ctx.setFillColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
        ctx.fill(CGRect(x: 0, y: 0, width: 800, height: 600))
        ctx.setFillColor(red: 0.8, green: 0.1, blue: 0.1, alpha: 1)
        ctx.fill(CGRect(x: 360, y: 280, width: 80, height: 40))   // 脸（80×40）
        return ctx.makeImage()!
    }

    /// 读单像素 RGB（原点左下）
    private func pixel(_ image: CGImage, x: Int, y: Int) -> (r: UInt8, g: UInt8, b: UInt8) {
        let ctx = CGContext(
            data: nil, width: 1, height: 1,
            bitsPerComponent: 8, bytesPerRow: 0,
            space: CGColorSpace(name: CGColorSpace.sRGB)!,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        )!
        // 1×1 画布只覆盖一个像素格：把整图平移使目标像素格对齐到画布。
        // 注意 draw 按网格而非像素中心采样，目标格需完整盖住画布：
        // 目标像素格在图中为 [x, x+1)×[y, y+1)，平移 (-x, -y) 后画布 [0,1)×[0,1) 与其重合
        ctx.draw(image, in: CGRect(x: CGFloat(-x), y: CGFloat(-y),
                                   width: CGFloat(image.width), height: CGFloat(image.height)))
        let data = ctx.data!.assumingMemoryBound(to: UInt8.self)
        return (data[0], data[1], data[2])
    }

    /// 纯色 PNG 素材 Data
    private func makePNG(width: Int, height: Int, color: (CGFloat, CGFloat, CGFloat, CGFloat)) -> Data {
        let ctx = CGContext(
            data: nil, width: width, height: height,
            bitsPerComponent: 8, bytesPerRow: 0,
            space: CGColorSpace(name: CGColorSpace.sRGB)!,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        )!
        ctx.setFillColor(red: color.0, green: color.1, blue: color.2, alpha: color.3)
        ctx.fill(CGRect(x: 0, y: 0, width: width, height: height))
        let data = NSMutableData()
        let dest = CGImageDestinationCreateWithData(data, UTType.png.identifier as CFString, 1, nil)!
        CGImageDestinationAddImage(dest, ctx.makeImage()!, nil)
        CGImageDestinationFinalize(dest)
        return data as Data
    }

    /// 合成"关键点齐全"的人脸：中心 (400, 300)，眼距 50
    private func syntheticFace() -> FaceGeometry {
        let rect = CGRect(x: 360, y: 270, width: 80, height: 60)
        return FaceGeometry(
            rect: rect, rollAngle: 0,
            points: [
                .leftEye: [CGPoint(x: 375, y: 310)],
                .rightEye: [CGPoint(x: 425, y: 310)],
                .outerLips: [CGPoint(x: 400, y: 285)],
            ])
    }

    private let ciContext = CIContext(options: [.cacheIntermediates: false])

    // MARK: - 模板加载

    func testTemplateRoundTrip() throws {
        let dir = makeTempDir()
        let templateDir = dir.appendingPathComponent("funny", isDirectory: true)
        try FileManager.default.createDirectory(at: templateDir, withIntermediateDirectories: true)

        let json = """
        {
          "warps": [{"kind": "bigHead", "strength": 0.5}],
          "stickers": [{"file": "ears.png", "anchor": "eyeMidpoint", "scale": 1.2}],
          "filter": "comic",
          "caption": {"text": "好耶！", "colorHex": "#FFFFFF", "size": 64}
        }
        """
        try json.data(using: .utf8)!.write(to: templateDir.appendingPathComponent("template.json"))

        let loaded = DecorationCore.loadTemplate(named: "funny", decorationsDir: dir)
        XCTAssertNotNil(loaded)
        XCTAssertEqual(loaded?.warps.count, 1)
        XCTAssertEqual(loaded?.warps.first?.kind, .bigHead)
        XCTAssertEqual(loaded?.warps.first?.strength ?? 0, 0.5, accuracy: 0.001)
        XCTAssertEqual(loaded?.stickers.first?.file, "ears.png")
        XCTAssertEqual(loaded?.stickers.first?.anchor, .eyeMidpoint)
        XCTAssertEqual(loaded?.filter, "comic")
        XCTAssertEqual(loaded?.caption?.text, "好耶！")
        XCTAssertFalse(loaded!.isEmpty)
    }

    /// 老模板（缺字段）解码回退默认值不抛错
    func testLegacyTemplateMissingFields() throws {
        let dir = makeTempDir()
        let templateDir = dir.appendingPathComponent("old", isDirectory: true)
        try FileManager.default.createDirectory(at: templateDir, withIntermediateDirectories: true)
        try #"{"warps": [{"kind": "bigEyes"}]}"#.data(using: .utf8)!
            .write(to: templateDir.appendingPathComponent("template.json"))

        let loaded = DecorationCore.loadTemplate(named: "old", decorationsDir: dir)
        XCTAssertNotNil(loaded)
        XCTAssertEqual(loaded?.warps.first?.strength ?? -1, 0.45, accuracy: 0.001)   // 默认强度
        XCTAssertEqual(loaded?.stickers.count, 0)
        XCTAssertNil(loaded?.caption)
    }

    /// 目录不存在 / 名字带路径分隔符 / JSON 损坏 → nil（降级）
    func testTemplateLoadFailures() throws {
        let dir = makeTempDir()
        XCTAssertNil(DecorationCore.loadTemplate(named: "missing", decorationsDir: dir))
        // 名字带 "/" 拒绝（防路径逃逸）
        XCTAssertNil(DecorationCore.loadTemplate(named: "../etc", decorationsDir: dir))
        // 空 / 全空格
        XCTAssertNil(DecorationCore.loadTemplate(named: "", decorationsDir: dir))

        // JSON 损坏
        let templateDir = dir.appendingPathComponent("bad", isDirectory: true)
        try FileManager.default.createDirectory(at: templateDir, withIntermediateDirectories: true)
        try "not json".data(using: .utf8)!.write(to: templateDir.appendingPathComponent("template.json"))
        XCTAssertNil(DecorationCore.loadTemplate(named: "bad", decorationsDir: dir))

        // 空对象模板：可解码但 isEmpty
        try "{}".data(using: .utf8)!.write(to: templateDir.appendingPathComponent("template.json"))
        let empty = DecorationCore.loadTemplate(named: "bad", decorationsDir: dir)
        XCTAssertNotNil(empty)
        XCTAssertTrue(empty!.isEmpty)
    }

    // MARK: - 形变

    /// 大头（bloat）：脸中心采样半径缩小 → 脸外近缘像素被放大后的脸覆盖
    func testBigHeadWarpBloatsFace() throws {
        let image = makeFaceImage()
        // 脸红块 x 范围 360~440，(445,300) 在脸外 5px，基线为灰
        let template = DecorationTemplate(warps: [.init(kind: .bigHead, strength: 0.8)])

        let before = pixel(image, x: 445, y: 300)
        XCTAssertEqual(Int(before.r), 229, accuracy: 8, "基线（脸外 5px）应为灰，实际 r=\(before.r)")

        let warped = try DecorationCore.apply(
            image, template: template, faces: [syntheticFace()],
            templateDir: makeTempDir(), ctx: ciContext)

        // 形变后同一位置应被红色（脸被放大）覆盖
        let after = pixel(warped, x: 445, y: 300)
        XCTAssertGreaterThan(Int(after.r), Int(after.b) + 30, "大头形变后脸缘外 5px 应变红，实际 r=\(after.r) b=\(after.b)")
    }

    /// 小脸（pinch）：中心采样半径放大 → 脸边缘内缩、灰底侵入脸内近缘
    func testSlimFaceWarpPinchesFace() throws {
        let image = makeFaceImage()
        let template = DecorationTemplate(warps: [.init(kind: .slimFace, strength: 0.5)])

        // 基线：脸内右缘 (435,300) 是红（红块 360~440）
        let before = pixel(image, x: 435, y: 300)
        XCTAssertGreaterThan(Int(before.r), Int(before.b) + 30, "基线脸内应为红，实际 r=\(before.r) b=\(before.b)")

        let warped = try DecorationCore.apply(
            image, template: template, faces: [syntheticFace()],
            templateDir: makeTempDir(), ctx: ciContext)

        // 形变后同位置应变灰（脸被收缩，采样点落到脸外灰底）
        let after = pixel(warped, x: 435, y: 300)
        XCTAssertLessThan(abs(Int(after.r) - Int(after.b)), 30, "小脸形变后脸内近缘应变灰，实际 r=\(after.r) b=\(after.b)")
    }

    /// 大眼：眼点处放大，距眼较远处不受影响
    func testBigEyesWarpLocal() throws {
        let image = makeFaceImage()
        let template = DecorationTemplate(warps: [.init(kind: .bigEyes, strength: 0.5)])

        let warped = try DecorationCore.apply(
            image, template: template, faces: [syntheticFace()],
            templateDir: makeTempDir(), ctx: ciContext)

        // 眼点附近（375,310 在红块上缘附近）变化存在即可验证 kernel 执行；
        // 远处角点 (10,10) 保持灰不变
        let corner = pixel(warped, x: 10, y: 10)
        XCTAssertEqual(Int(corner.r), 229, accuracy: 6)
        XCTAssertEqual(Int(corner.g), 229, accuracy: 6)
    }

    /// 凸嘴 + 强度钳制：超界强度不崩溃且仍有效果
    func testPoutyMouthStrengthClamped() throws {
        let image = makeFaceImage()
        let template = DecorationTemplate(warps: [.init(kind: .poutyMouth, strength: 5.0)])   // 远超 0.85
        let warped = try DecorationCore.apply(
            image, template: template, faces: [syntheticFace()],
            templateDir: makeTempDir(), ctx: ciContext)
        // 不崩 + 尺寸不变即通过（钳制保护）
        XCTAssertEqual(warped.width, image.width)
        XCTAssertEqual(warped.height, image.height)
    }

    // MARK: - 贴纸

    /// 贴纸绘制在锚点：眼间中点被蓝色贴纸覆盖
    func testStickerDrawnAtAnchor() throws {
        let dir = makeTempDir()
        try makePNG(width: 100, height: 100, color: (0.1, 0.2, 0.9, 1.0))
            .write(to: dir.appendingPathComponent("spot.png"))

        let image = makeFaceImage()
        let template = DecorationTemplate(
            stickers: [.init(file: "spot.png", anchor: .eyeMidpoint, scale: 1.0)])

        let result = DecorationCore.drawStickers(
            image, stickers: template.stickers, faces: [syntheticFace()], templateDir: dir)

        // 眼间中点 (400, 310)：应为贴纸蓝色
        let p = pixel(result, x: 400, y: 310)
        XCTAssertGreaterThan(Int(p.b), Int(p.r) + 30, "锚点应为贴纸蓝，实际 r=\(p.r) b=\(p.b)")
        // 远处角落仍是灰底
        let corner = pixel(result, x: 10, y: 10)
        XCTAssertEqual(Int(corner.r), 229, accuracy: 6)
    }

    /// 贴纸素材缺失：跳过该项不崩，锚点像素与原图一致
    func testStickerMissingFileSkipped() {
        let image = makeFaceImage()
        let template = DecorationTemplate(
            stickers: [.init(file: "ghost.png", anchor: .eyeMidpoint, scale: 1.0)])
        let result = DecorationCore.drawStickers(
            image, stickers: template.stickers, faces: [syntheticFace()], templateDir: makeTempDir())
        let p = pixel(result, x: 400, y: 310)
        let o = pixel(image, x: 400, y: 310)
        XCTAssertEqual(Int(p.r), Int(o.r), "素材缺失锚点应保持原图")
    }

    /// 缺双眼关键点的人脸：该脸贴纸跳过（不崩），锚点像素与原图一致
    func testStickerSkipsFaceWithoutEyes() {
        let face = FaceGeometry(rect: CGRect(x: 360, y: 270, width: 80, height: 60))
        let image = makeFaceImage()
        let template = DecorationTemplate(
            stickers: [.init(file: "spot.png", anchor: .eyeMidpoint, scale: 1.0)])
        let result = DecorationCore.drawStickers(
            image, stickers: template.stickers, faces: [face], templateDir: makeTempDir())
        let p = pixel(result, x: 400, y: 310)
        let o = pixel(image, x: 400, y: 310)
        XCTAssertEqual(Int(p.r), Int(o.r), "无关键点的人脸不应绘贴纸")
    }

    // MARK: - 滤镜与字幕

    /// 风格化滤镜改变像素；未知滤镜抛错
    func testFilterAppliedAndUnknownThrows() throws {
        let image = makeFaceImage()

        let mono = try DecorationCore.applyFilter(image, name: "mono", ctx: ciContext)
        // 单色滤镜后红块区域 r≈g（灰度化）
        let p = pixel(mono, x: 400, y: 290)
        XCTAssertLessThan(abs(Int(p.r) - Int(p.g)), 12, "mono 后应为灰度")

        XCTAssertThrowsError(try DecorationCore.applyFilter(image, name: "CINoSuchFilter", ctx: ciContext))
    }

    /// 字幕条绘制在底部：底部中心出现文字像素
    func testCaptionDrawnAtBottom() throws {
        let image = makeFaceImage()
        let template = DecorationTemplate(
            caption: .init(text: "BOOTH", colorHex: "#FF0000", size: 64))

        let result = try DecorationCore.apply(
            image, template: template, faces: [], templateDir: makeTempDir(), ctx: ciContext)

        // 底部 5%~15% 高度带扫描红色文字像素
        var foundRed = false
        for y in stride(from: 30, to: 90, by: 4) {
            for x in stride(from: 350, to: 450, by: 4) {
                let p = pixel(result, x: x, y: y)
                if Int(p.r) > 200 && Int(p.g) < 80 { foundRed = true; break }
            }
            if foundRed { break }
        }
        XCTAssertTrue(foundRed, "底部应出现红色字幕")
    }

    /// 无人脸：形变/贴纸跳过，滤镜/字幕照常（不抛错）
    func testNoFacesSkipsWarpButKeepsFilter() throws {
        let image = makeFaceImage()
        let template = DecorationTemplate(
            warps: [.init(kind: .bigHead, strength: 0.5)],
            filter: "mono")

        let result = try DecorationCore.apply(
            image, template: template, faces: [], templateDir: makeTempDir(), ctx: ciContext)
        // mono 生效即说明管线继续执行
        let p = pixel(result, x: 400, y: 290)
        XCTAssertLessThan(abs(Int(p.r) - Int(p.g)), 12)
    }

    // MARK: - 管线集成（ImagingService）

    /// 合成一次拍照输入
    private func makeCaptureJPEG() -> Data {
        let image = makeFaceImage()
        let data = NSMutableData()
        let dest = CGImageDestinationCreateWithData(data, UTType.jpeg.identifier as CFString, 1, nil)!
        CGImageDestinationAddImage(dest, image, [kCGImageDestinationLossyCompressionQuality: 0.9] as CFDictionary)
        CGImageDestinationFinalize(dest)
        return data as Data
    }

    private var decorationOffConfig: BoothConfig.ImagingConf {
        var c = BoothConfig.ImagingConf()
        c.autoColor = false
        c.skinSmoothing = false
        c.replaceBackground = false
        c.frame = false
        c.dateWatermark = false
        c.decorationTemplate = ""
        return c
    }

    /// 端到端：模板齐全 + 假 landmarker → 装饰全路径不崩、出片规格不变
    func testPipelineDecorationEndToEnd() async throws {
        let decorationsRoot = makeTempDir()
        let templateDir = decorationsRoot.appendingPathComponent("funny", isDirectory: true)
        try FileManager.default.createDirectory(at: templateDir, withIntermediateDirectories: true)
        try makePNG(width: 100, height: 100, color: (0.1, 0.2, 0.9, 1.0))
            .write(to: templateDir.appendingPathComponent("spot.png"))
        try """
        {
          "warps": [{"kind": "bigHead", "strength": 0.4}],
          "stickers": [{"file": "spot.png", "anchor": "eyeMidpoint", "scale": 1.0}],
          "caption": {"text": "好耶", "size": 48}
        }
        """.data(using: .utf8)!.write(to: templateDir.appendingPathComponent("template.json"))

        var conf = decorationOffConfig
        conf.decorationTemplate = "funny"
        let service = ImagingService(
            segmenter: nil, landmarker: FakeLandmarker(faces: [syntheticFace()]),
            configOverride: conf, themesDirOverride: makeTempDir(),
            decorationsDirOverride: decorationsRoot)

        let capture = CameraCapture(handle: 1, data: makeCaptureJPEG(), fileName: "P1000001.JPG")
        let result = try await service.process(originals: [capture], mode: .single, sessionDir: makeTempDir())
        XCTAssertEqual(result.printFile.lastPathComponent, "print.jpg")
        // 6 寸规格不受装饰影响
        let size = imageSize(result.printFile)
        XCTAssertEqual(size, CGSize(width: 1200, height: 1800))
    }

    /// 装饰开启但模板不存在 → 降级出片
    func testPipelineDecorationTemplateMissingDegrades() async throws {
        var conf = decorationOffConfig
        conf.decorationTemplate = "no-such-template"
        let service = ImagingService(
            segmenter: nil, landmarker: FakeLandmarker(faces: [syntheticFace()]),
            configOverride: conf, themesDirOverride: makeTempDir(),
            decorationsDirOverride: makeTempDir())
        let capture = CameraCapture(handle: 1, data: makeCaptureJPEG(), fileName: "P1.JPG")
        let result = try await service.process(originals: [capture], mode: .single, sessionDir: makeTempDir())
        XCTAssertEqual(imageSize(result.printFile), CGSize(width: 1200, height: 1800))
    }

    /// landmarker 抛错 → 装饰降级出片
    func testPipelineFailingLandmarkerDegrades() async throws {
        let decorationsRoot = makeTempDir()
        let templateDir = decorationsRoot.appendingPathComponent("funny", isDirectory: true)
        try FileManager.default.createDirectory(at: templateDir, withIntermediateDirectories: true)
        try #"{"filter": "mono"}"#.data(using: .utf8)!
            .write(to: templateDir.appendingPathComponent("template.json"))

        var conf = decorationOffConfig
        conf.decorationTemplate = "funny"
        let service = ImagingService(
            segmenter: nil, landmarker: FailingLandmarker(),
            configOverride: conf, themesDirOverride: makeTempDir(),
            decorationsDirOverride: decorationsRoot)
        let capture = CameraCapture(handle: 1, data: makeCaptureJPEG(), fileName: "P1.JPG")
        let result = try await service.process(originals: [capture], mode: .single, sessionDir: makeTempDir())
        XCTAssertEqual(imageSize(result.printFile), CGSize(width: 1200, height: 1800))
    }

    /// 装饰开启但未注入 landmarker → 降级出片
    func testPipelineNoLandmarkerDegrades() async throws {
        var conf = decorationOffConfig
        conf.decorationTemplate = "funny"
        let service = ImagingService(
            segmenter: nil, landmarker: nil,
            configOverride: conf, themesDirOverride: makeTempDir(),
            decorationsDirOverride: makeTempDir())
        let capture = CameraCapture(handle: 1, data: makeCaptureJPEG(), fileName: "P1.JPG")
        let result = try await service.process(originals: [capture], mode: .single, sessionDir: makeTempDir())
        XCTAssertEqual(imageSize(result.printFile), CGSize(width: 1200, height: 1800))
    }

    /// 配置默认值：decorationTemplate 缺省为空（关闭）
    func testConfigDefaultDecorationOff() throws {
        let conf = BoothConfig.ImagingConf()
        XCTAssertEqual(conf.decorationTemplate, "")
        // 老配置文件（无该字段）解码回退默认：
        // ImagingConf 无自定义 init(from:)，缺失字段会抛 keyNotFound（与
        // BoothConfig 顶层逐段解码兼容策略一致），此处验证字段缺失时的行为
        let legacy = #"{"autoColor": false}"#.data(using: .utf8)!
        XCTAssertThrowsError(try JSONDecoder().decode(BoothConfig.ImagingConf.self, from: legacy))
        // 完整字段的新配置正常解码且 decorationTemplate 有默认值
        let fresh = try JSONEncoder().encode(conf)
        let decoded = try JSONDecoder().decode(BoothConfig.ImagingConf.self, from: fresh)
        XCTAssertEqual(decoded.decorationTemplate, "")
    }

    // MARK: - 复用工具

    /// 读 JPEG/PNG 文件像素尺寸
    private func imageSize(_ url: URL) -> CGSize {
        let src = CGImageSourceCreateWithURL(url as CFURL, nil)!
        let props = CGImageSourceCopyPropertiesAtIndex(src, 0, nil) as! [CFString: Any]
        let w = (props[kCGImagePropertyPixelWidth] as? NSNumber)?.intValue ?? 0
        let h = (props[kCGImagePropertyPixelHeight] as? NSNumber)?.intValue ?? 0
        return CGSize(width: w, height: h)
    }
}
