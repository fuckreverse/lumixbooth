import XCTest
import AppKit
import CoreGraphics
import ImageIO
import UniformTypeIdentifiers
@testable import ImagingKit
import BoothCore

// ============================================================
// ImagingKitTests — 全部使用程序合成图像，不接相机
//  - 测试图：CoreGraphics 画的色块渐变 1920×1280（3:2，模拟相机横构图）
//  - 配置/主题目录通过注入覆盖，不读写真实用户目录
// ============================================================

/// 假分割器：返回全白 matte（= 整张都是人），验证换背景路径不崩
final class FakeSegmenter: PersonSegmenting, @unchecked Sendable {
    func segmentationMask(for image: CGImage) async throws -> CGImage {
        let ctx = CGContext(
            data: nil, width: image.width, height: image.height,
            bitsPerComponent: 8, bytesPerRow: 0,
            space: CGColorSpaceCreateDeviceGray(),
            bitmapInfo: CGImageAlphaInfo.none.rawValue
        )!
        ctx.setFillColor(gray: 1, alpha: 1)
        ctx.fill(CGRect(x: 0, y: 0, width: image.width, height: image.height))
        return ctx.makeImage()!
    }
}

/// 抛错分割器：验证分割失败时降级不阻断
final class FailingSegmenter: PersonSegmenting, @unchecked Sendable {
    func segmentationMask(for image: CGImage) async throws -> CGImage {
        throw BoothError.imagingFailed("模拟分割失败")
    }
}

final class ImagingKitTests: XCTestCase {

    // MARK: - 工具

    private var tempDirs: [URL] = []

    override func tearDownWithError() throws {
        for dir in tempDirs { try? FileManager.default.removeItem(at: dir) }
        tempDirs = []
    }

    /// 新建临时目录（用例结束自动清理）
    private func makeTempDir(_ name: String = UUID().uuidString) -> URL {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("imagingkit-tests-\(name)", isDirectory: true)
        try! FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        tempDirs.append(url)
        return url
    }

    /// 程序合成测试图：横向色带 + 纵向渐变条 1920×1280，编码为 JPEG Data
    private func makeTestJPEG(width: Int = 1920, height: Int = 1280, seed: Int = 0) -> Data {
        let ctx = CGContext(
            data: nil, width: width, height: height,
            bitsPerComponent: 8, bytesPerRow: 0,
            space: CGColorSpace(name: CGColorSpace.sRGB)!,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        )!
        // 横向彩虹色带
        let bands = 8
        for b in 0..<bands {
            let hue = (CGFloat(b) / CGFloat(bands) + CGFloat(seed) * 0.13).truncatingRemainder(dividingBy: 1)
            ctx.setFillColor(NSColor(hue: hue, saturation: 0.7, brightness: 0.9, alpha: 1).cgColor)
            ctx.fill(CGRect(x: 0, y: height * b / bands, width: width, height: height / bands + 1))
        }
        // 叠加纵向灰阶渐变条，增加细节
        for x in 0..<width {
            let g = CGFloat(x) / CGFloat(width)
            ctx.setFillColor(red: g, green: g, blue: g, alpha: 0.15)
            ctx.fill(CGRect(x: x, y: 0, width: 1, height: height))
        }
        let image = ctx.makeImage()!
        let data = NSMutableData()
        let dest = CGImageDestinationCreateWithData(data, UTType.jpeg.identifier as CFString, 1, nil)!
        CGImageDestinationAddImage(dest, image, [kCGImageDestinationLossyCompressionQuality: 0.9] as CFDictionary)
        XCTAssertTrue(CGImageDestinationFinalize(dest))
        return data as Data
    }

    private func makeCapture(_ index: Int) -> CameraCapture {
        CameraCapture(handle: UInt32(index), data: makeTestJPEG(seed: index), fileName: "P100000\(index).JPG")
    }

    private func imageSize(_ url: URL) -> CGSize {
        let src = CGImageSourceCreateWithURL(url as CFURL, nil)!
        let props = CGImageSourceCopyPropertiesAtIndex(src, 0, nil) as! [CFString: Any]
        return CGSize(width: props[kCGImagePropertyPixelWidth] as! Int,
                      height: props[kCGImagePropertyPixelHeight] as! Int)
    }

    private func originalFiles(in dir: URL) -> [URL] {
        (try! FileManager.default.contentsOfDirectory(at: dir, includingPropertiesForKeys: nil))
            .filter { $0.lastPathComponent.hasPrefix("original-") }
    }

    /// 全功能关闭的配置
    private var allOffConfig: BoothConfig.ImagingConf {
        var c = BoothConfig.ImagingConf()
        c.autoColor = false
        c.skinSmoothing = false
        c.replaceBackground = false
        c.frame = false
        c.dateWatermark = false
        return c
    }

    // MARK: - 单张模式

    func testSingleModeProduces6InchPrint() async throws {
        let sessionDir = makeTempDir()
        let service = ImagingService(segmenter: nil, configOverride: allOffConfig, themesDirOverride: makeTempDir())
        let result = try await service.process(originals: [makeCapture(1)], mode: .single, sessionDir: sessionDir)

        XCTAssertTrue(FileManager.default.fileExists(atPath: result.printFile.path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: result.displayFile.path))
        // 打印位图必须严格 1200×1800（6 寸竖版 @300dpi）
        XCTAssertEqual(imageSize(result.printFile), CGSize(width: 1200, height: 1800))
        // 展示位图长边 1600
        let displaySize = imageSize(result.displayFile)
        XCTAssertEqual(max(displaySize.width, displaySize.height), 1600)
        // 打印位图应带 300dpi 元数据
        let src = CGImageSourceCreateWithURL(result.printFile as CFURL, nil)!
        let props = CGImageSourceCopyPropertiesAtIndex(src, 0, nil) as! [CFString: Any]
        XCTAssertEqual((props[kCGImagePropertyDPIWidth] as? NSNumber)?.intValue, 300)
        // 原图落盘 1 张
        XCTAssertEqual(result.originals.count, 1)
        XCTAssertEqual(originalFiles(in: sessionDir).count, 1)
        XCTAssertTrue(result.originals[0].lastPathComponent.contains("P1000001.JPG"))
    }

    // MARK: - 拼版模式

    func testCollageModeProduces6InchStrip() async throws {
        let sessionDir = makeTempDir()
        let service = ImagingService(segmenter: nil, configOverride: allOffConfig, themesDirOverride: makeTempDir())
        let captures = (1...4).map { makeCapture($0) }
        let result = try await service.process(originals: captures, mode: .collage(4), sessionDir: sessionDir)

        XCTAssertEqual(imageSize(result.printFile), CGSize(width: 1200, height: 1800))
        let displaySize = imageSize(result.displayFile)
        XCTAssertEqual(max(displaySize.width, displaySize.height), 1600)
        // 4 张原图全部落盘
        XCTAssertEqual(result.originals.count, 4)
        XCTAssertEqual(originalFiles(in: sessionDir).count, 4)
    }

    // MARK: - 降级路径

    /// 配置全关 + 主题目录为空：不崩、产物仍生成
    func testAllFeaturesOffStillProduces() async throws {
        let sessionDir = makeTempDir()
        let service = ImagingService(segmenter: nil, configOverride: allOffConfig, themesDirOverride: makeTempDir())
        let result = try await service.process(originals: [makeCapture(1)], mode: .single, sessionDir: sessionDir)
        XCTAssertEqual(imageSize(result.printFile), CGSize(width: 1200, height: 1800))
    }

    /// 配置全开但无主题素材、无 segmenter：全部降级跳过，产物仍生成
    func testMissingThemeAndNoSegmenterDegrades() async throws {
        let sessionDir = makeTempDir()
        var conf = BoothConfig.ImagingConf()
        conf.replaceBackground = true   // 开了但没素材没 segmenter → 应降级
        let service = ImagingService(segmenter: nil, configOverride: conf, themesDirOverride: makeTempDir())
        let result = try await service.process(originals: [makeCapture(1)], mode: .single, sessionDir: sessionDir)
        XCTAssertEqual(imageSize(result.printFile), CGSize(width: 1200, height: 1800))
    }

    /// 主题素材齐全 + 全白 matte 假分割器：换背景/边框/水印全路径不崩
    func testFakeSegmenterBackgroundPath() async throws {
        let sessionDir = makeTempDir()
        let themeRoot = makeTempDir()
        let themeDir = themeRoot.appendingPathComponent("party", isDirectory: true)
        try FileManager.default.createDirectory(at: themeDir, withIntermediateDirectories: true)
        // 造素材：background.png / frame.png / mascot.png / config.json
        try makePNG(size: CGSize(width: 1920, height: 1280), color: NSColor.systemTeal)
            .write(to: themeDir.appendingPathComponent("background.png"))
        try makePNG(size: CGSize(width: 1200, height: 1800), color: NSColor.clear, border: true)
            .write(to: themeDir.appendingPathComponent("frame.png"))
        try makePNG(size: CGSize(width: 200, height: 200), color: NSColor.systemYellow)
            .write(to: themeDir.appendingPathComponent("mascot.png"))
        try ##"{"accent": "#FF6600"}"##.data(using: .utf8)!
            .write(to: themeDir.appendingPathComponent("config.json"))

        var conf = BoothConfig.ImagingConf()
        conf.replaceBackground = true
        conf.themeName = "party"
        let service = ImagingService(segmenter: FakeSegmenter(), configOverride: conf, themesDirOverride: themeRoot)

        // 单张 + 拼版都走一遍换背景路径
        let single = try await service.process(originals: [makeCapture(1)], mode: .single, sessionDir: sessionDir)
        XCTAssertEqual(imageSize(single.printFile), CGSize(width: 1200, height: 1800))
        let collageDir = makeTempDir()
        let collage = try await service.process(originals: (1...4).map { makeCapture($0) }, mode: .collage(4), sessionDir: collageDir)
        XCTAssertEqual(imageSize(collage.printFile), CGSize(width: 1200, height: 1800))
    }

    /// 分割器抛错：换背景降级保留原背景，管线不中断
    func testFailingSegmenterDegrades() async throws {
        let sessionDir = makeTempDir()
        let themeRoot = makeTempDir()
        let themeDir = themeRoot.appendingPathComponent("default", isDirectory: true)
        try FileManager.default.createDirectory(at: themeDir, withIntermediateDirectories: true)
        try makePNG(size: CGSize(width: 1920, height: 1280), color: NSColor.systemPink)
            .write(to: themeDir.appendingPathComponent("background.png"))

        var conf = BoothConfig.ImagingConf()
        conf.replaceBackground = true
        let service = ImagingService(segmenter: FailingSegmenter(), configOverride: conf, themesDirOverride: themeRoot)
        let result = try await service.process(originals: [makeCapture(1)], mode: .single, sessionDir: sessionDir)
        XCTAssertEqual(imageSize(result.printFile), CGSize(width: 1200, height: 1800))
    }

    // MARK: - 异常输入

    /// 空输入必须抛 imagingFailed
    func testEmptyOriginalsThrows() async {
        let sessionDir = makeTempDir()
        let service = ImagingService(segmenter: nil, configOverride: allOffConfig, themesDirOverride: makeTempDir())
        do {
            _ = try await service.process(originals: [], mode: .single, sessionDir: sessionDir)
            XCTFail("空输入应抛错")
        } catch BoothError.imagingFailed {
            // 预期
        } catch {
            XCTFail("错误类型不符: \(error)")
        }
    }

    /// 损坏数据：解码失败被跳过，只要有一张好的就能出片
    func testCorruptCaptureSkipped() async throws {
        let sessionDir = makeTempDir()
        let service = ImagingService(segmenter: nil, configOverride: allOffConfig, themesDirOverride: makeTempDir())
        let corrupt = CameraCapture(handle: 99, data: Data("not a jpeg".utf8), fileName: "BAD.JPG")
        let result = try await service.process(originals: [corrupt, makeCapture(1)], mode: .single, sessionDir: sessionDir)
        XCTAssertEqual(imageSize(result.printFile), CGSize(width: 1200, height: 1800))
        // 两张都落盘（落盘不因解码失败而跳过）
        XCTAssertEqual(result.originals.count, 2)
    }

    // MARK: - 素材生成辅助

    /// 生成纯色（可选带边框环）PNG 素材
    private func makePNG(size: CGSize, color: NSColor, border: Bool = false) -> Data {
        let ctx = CGContext(
            data: nil, width: Int(size.width), height: Int(size.height),
            bitsPerComponent: 8, bytesPerRow: 0,
            space: CGColorSpace(name: CGColorSpace.sRGB)!,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        )!
        ctx.setFillColor(color.cgColor)
        ctx.fill(CGRect(origin: .zero, size: size))
        if border {
            // frame.png 模拟：透明底 + 四周描边
            ctx.clear(CGRect(origin: .zero, size: size))
            ctx.setStrokeColor(NSColor.systemBlue.cgColor)
            ctx.setLineWidth(30)
            ctx.stroke(CGRect(origin: .zero, size: size).insetBy(dx: 15, dy: 15))
        }
        let image = ctx.makeImage()!
        let data = NSMutableData()
        let dest = CGImageDestinationCreateWithData(data, UTType.png.identifier as CFString, 1, nil)!
        CGImageDestinationAddImage(dest, image, nil)
        CGImageDestinationFinalize(dest)
        return data as Data
    }

    // MARK: - 拍后自选滤镜（PhotoBoothProject 借鉴）

    /// process 应额外落盘 print-base.jpg（未滤镜未边框底图），applyFilter 换滤镜重打成功
    func testProcessWritesBaseAndApplyFilterReprints() async throws {
        let sessionDir = makeTempDir()
        let service = ImagingService(segmenter: nil, configOverride: allOffConfig, themesDirOverride: makeTempDir())
        let original = try await service.process(originals: [makeCapture(1)], mode: .single, sessionDir: sessionDir)

        // print-base.jpg 应落盘并挂到成片上
        let base = sessionDir.appendingPathComponent("print-base.jpg")
        XCTAssertTrue(FileManager.default.fileExists(atPath: base.path), "应落盘 print-base.jpg")
        XCTAssertEqual(original.baseFile, base)

        // 换滤镜重打：新 id、覆写 print/display、base 保持
        let vivid = try await service.applyFilter(.vivid, to: original, sessionDir: sessionDir)
        XCTAssertNotEqual(vivid.id, original.id, "重打应生成新成片 id（iPad 端避缓存换图）")
        XCTAssertTrue(FileManager.default.fileExists(atPath: vivid.printFile.path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: vivid.displayFile.path))
        XCTAssertEqual(imageSize(vivid.printFile), CGSize(width: 1200, height: 1800))
        XCTAssertEqual(vivid.baseFile, base)

        // 再换一次滤镜仍然成功（base 可反复重打）
        let mono = try await service.applyFilter(.mono, to: vivid, sessionDir: sessionDir)
        XCTAssertNotEqual(mono.id, vivid.id)
        XCTAssertEqual(imageSize(mono.printFile), CGSize(width: 1200, height: 1800))
    }

    /// 旧会话无 print-base.jpg（baseFile=nil）：applyFilter 降级返回原成片
    func testApplyFilterDegradesWithoutBase() async throws {
        let sessionDir = makeTempDir()
        // 手造一个“旧会话”成片：只有 print.jpg，没有 base
        let oldPrint = sessionDir.appendingPathComponent("print.jpg")
        try makePNG(size: CGSize(width: 1200, height: 1800), color: NSColor.white).write(to: oldPrint)
        let photo = ProcessedPhoto(id: UUID(), printFile: oldPrint,
                                    displayFile: oldPrint, originals: [oldPrint])
        let service = ImagingService(segmenter: nil, configOverride: allOffConfig, themesDirOverride: makeTempDir())
        let result = try await service.applyFilter(.warm, to: photo, sessionDir: sessionDir)
        XCTAssertEqual(result.id, photo.id, "无底图时应原样返回（不支持重打）")
        XCTAssertEqual(result.printFile, photo.printFile)
    }

    /// 六档滤镜算子：全部不抛错、尺寸不变、.none 原图直返
    func testAllStyleFiltersApply() throws {
        let ctx = CIContext()
        let source = try decodeJPEG(makeTestJPEG())
        for f in PhotoFilter.allCases {
            let out = try PipelineCore.applyStyleFilter(source, filter: f, ctx: ctx)
            XCTAssertEqual(out.width, source.width, "\(f.rawValue) 不应改变尺寸")
            XCTAssertEqual(out.height, source.height, "\(f.rawValue) 不应改变尺寸")
        }
        // .none 应逐像素一致（直返）
        let none = try PipelineCore.applyStyleFilter(source, filter: .none, ctx: ctx)
        XCTAssertEqual(none, source, "none 滤镜应原样返回")
    }

    /// 暖阳/冷调回归（曾因旧键名 inputTarget 失效 + tint 巨值全黑）：
    /// 输出不得全黑，且方向正确——暖调 R 相对 B 抬升，冷调 B 相对 R 抬升
    func testWarmCoolFilterNotBlackAndDirection() throws {
        let ctx = CIContext()
        let source = try decodeJPEG(makeTestJPEG())
        let region = (x: 600, y: 500, w: 300, h: 300)
        let base = try averageRGB(source, x: region.x, y: region.y, w: region.w, h: region.h)
        XCTAssertGreaterThan(base.r + base.g + base.b, 0.15, "测试图基线不应接近全黑")

        let warm = try PipelineCore.applyStyleFilter(source, filter: .warm, ctx: ctx)
        let w = try averageRGB(warm, x: region.x, y: region.y, w: region.w, h: region.h)
        XCTAssertGreaterThan(w.r + w.g + w.b, 0.15, "暖阳不应输出全黑")
        XCTAssertGreaterThan(w.r - w.b, base.r - base.b + 0.02,
                             "暖阳应让红通道相对蓝通道抬升（R>B 方向）")

        let cool = try PipelineCore.applyStyleFilter(source, filter: .cool, ctx: ctx)
        let c = try averageRGB(cool, x: region.x, y: region.y, w: region.w, h: region.h)
        XCTAssertGreaterThan(c.r + c.g + c.b, 0.15, "冷调不应输出全黑")
        XCTAssertGreaterThan(c.b - c.r, base.b - base.r + 0.02,
                             "冷调应让蓝通道相对红通道抬升（B>R 方向）")
    }

    // MARK: - QR 叠印

    func testOverlayQRCode() throws {
        let ctx = CIContext()
        let base = try decodeJPEG(makeTestJPEG())
        let out = try PipelineCore.overlayQRCode(on: base,
                                                 content: "http://192.168.1.8:8080/photo/ABC-123", ctx: ctx)
        XCTAssertEqual(out.width, base.width)
        XCTAssertEqual(out.height, base.height)
        // 右缘中部 QR 区域应被明显改写（白色垫底 + 黑色码点，与原图区域亮度差异显著）。
        // 注：不用“更亮”断言——测试图右缘本就偏亮，QR 黑码点会拉低均值，方向不可预测。
        let sampled = try averageLuminance(out, x: out.width - 120, y: out.height / 2 - 60,
                                            w: 80, h: 80)
        let original = try averageLuminance(base, x: base.width - 120, y: base.height / 2 - 60,
                                             w: 80, h: 80)
        XCTAssertGreaterThan(abs(sampled - original), 0.05,
                             "QR 区域亮度应与原图差异显著（印上了东西），实际 out=\(sampled) base=\(original)")
    }

    // MARK: - 多拼版布局

    /// 全部布局产出 1200×1800，且五种布局两两像素互不相同
    func testCollageLayouts() throws {
        let themeRoot = makeTempDir()
        let photos = try (1...4).map { _ in try decodeJPEG(makeTestJPEG(seed: Int.random(in: 0...99))) }
        let dateText = "2026-09-29"

        var outputs: [CollageLayout: CGImage] = [:]
        for layout in CollageLayout.allCases {
            let img = try PipelineCore.composeCollage(photos: photos, layout: layout,
                                                      themeDir: themeRoot, accent: nil, dateText: dateText)
            XCTAssertEqual(img.width, 1200, "\(layout.rawValue) 输出宽应为 1200")
            XCTAssertEqual(img.height, 1800, "\(layout.rawValue) 输出高应为 1800")
            outputs[layout] = img
        }
        // 五种布局两两互不相同（含新增 trio / onePlusThree）
        XCTAssertEqual(CollageLayout.allCases.count, 5)
        let keys = Array(outputs.keys)
        for i in 0..<keys.count {
            for j in (i + 1)..<keys.count {
                XCTAssertNotEqual(outputs[keys[i]], outputs[keys[j]],
                                  "\(keys[i].rawValue) 与 \(keys[j].rawValue) 不应输出相同像素")
            }
        }
    }

    /// 新增布局用各自推荐张数合成：三格拼条(3张) / 主图三拼(4张) 不崩、尺寸正确
    func testCollageTrioAndOnePlusThree() throws {
        let themeRoot = makeTempDir()
        let dateText = "2026-09-30"

        let trioPhotos = try (1...3).map { try decodeJPEG(makeTestJPEG(seed: $0)) }
        let trio = try PipelineCore.composeCollage(photos: trioPhotos, layout: .trio,
                                                    themeDir: themeRoot, accent: nil, dateText: dateText)
        XCTAssertEqual(trio.width, 1200)
        XCTAssertEqual(trio.height, 1800)

        let quadPhotos = try (1...4).map { try decodeJPEG(makeTestJPEG(seed: $0 + 40)) }
        let onePlusThree = try PipelineCore.composeCollage(photos: quadPhotos, layout: .onePlusThree,
                                                            themeDir: themeRoot, accent: nil, dateText: dateText)
        XCTAssertEqual(onePlusThree.width, 1200)
        XCTAssertEqual(onePlusThree.height, 1800)

        let grid = try PipelineCore.composeCollage(photos: quadPhotos, layout: .grid2x2,
                                                   themeDir: themeRoot, accent: nil, dateText: dateText)
        XCTAssertNotEqual(onePlusThree, grid, "主图三拼与四宫格不应输出相同像素")
    }

    /// 选片页实时预览：单张/整版 + 滤镜组合，输出 2:3 尺寸且互不相同
    func testComposePreviewSingleCollageAndFilter() throws {
        let ctx = CIContext()
        let photos = try (1...4).map { try decodeJPEG(makeTestJPEG(seed: $0)) }

        // 单张（第 2 张）与整版不应相同
        let single = try PipelineCore.composePreview(photos: photos, layout: .grid2x2,
                                                      singleIndex: 1, filter: .none, ctx: ctx)
        XCTAssertEqual(single.width, 900)
        XCTAssertEqual(single.height, 1350)

        let collage = try PipelineCore.composePreview(photos: photos, layout: .grid2x2,
                                                      singleIndex: nil, filter: .none, ctx: ctx)
        XCTAssertEqual(collage.width, 900)
        XCTAssertEqual(collage.height, 1350)
        XCTAssertNotEqual(single, collage, "单张预览与整版预览不应相同")

        // 换布局互不相同；换滤镜互不相同（实时预览区分度高）
        let strip = try PipelineCore.composePreview(photos: photos, layout: .strip,
                                                    singleIndex: nil, filter: .none, ctx: ctx)
        XCTAssertNotEqual(collage, strip)
        let warm = try PipelineCore.composePreview(photos: photos, layout: .grid2x2,
                                                   singleIndex: nil, filter: .warm, ctx: ctx)
        XCTAssertNotEqual(collage, warm, "选滤镜后预览应有变化")
        // 滤镜预览不落黑（暖阳回归）
        let warmRep = NSBitmapImageRep(cgImage: warm)
        let c = warmRep.colorAt(x: 450, y: 200)!
        XCTAssertGreaterThan(c.redComponent + c.greenComponent + c.blueComponent, 0.15,
                              "暖阳预览不应全黑")
    }

    /// 端到端：collage 带布局参数跑通 process（grid2x2 两张）
    func testCollageDuoLayoutEndToEnd() async throws {
        let sessionDir = makeTempDir()
        let service = ImagingService(segmenter: nil, configOverride: allOffConfig, themesDirOverride: makeTempDir())
        let result = try await service.process(originals: [makeCapture(1), makeCapture(2)],
                                                mode: .collage(2, layout: .duo), sessionDir: sessionDir)
        XCTAssertEqual(imageSize(result.printFile), CGSize(width: 1200, height: 1800))
        XCTAssertEqual(result.originals.count, 2)
    }

    // MARK: - 新工具

    /// 解码 JPEG Data → CGImage
    private func decodeJPEG(_ data: Data) throws -> CGImage {
        let src = CGImageSourceCreateWithData(data as CFData, nil)!
        return try XCTUnwrap(CGImageSourceCreateImageAtIndex(src, 0, nil))
    }

    /// 采样区域平均 RGB（0~1）：画到 sRGB 上下文取三通道均值（暖阳/冷调方向断言用）
    private func averageRGB(_ image: CGImage, x: Int, y: Int, w: Int, h: Int) throws -> (r: Double, g: Double, b: Double) {
        let ctx = CGContext(
            data: nil, width: w, height: h,
            bitsPerComponent: 8, bytesPerRow: 0,
            space: CGColorSpace(name: CGColorSpace.sRGB)!,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        )!
        ctx.draw(image, in: CGRect(x: -x, y: -y, width: image.width, height: image.height))
        guard let dataPtr = ctx.data else { return (0, 0, 0) }
        let buf = dataPtr.bindMemory(to: UInt8.self, capacity: w * h * 4)
        var r = 0.0, g = 0.0, b = 0.0
        for i in 0..<(w * h) {
            r += Double(buf[i * 4]); g += Double(buf[i * 4 + 1]); b += Double(buf[i * 4 + 2])
        }
        let n = Double(w * h)
        return (r / n / 255.0, g / n / 255.0, b / n / 255.0)
    }

    /// 采样区域平均亮度（0~1）：把 image 指定偏移区域画到 80×80 灰度上下文取均值
    private func averageLuminance(_ image: CGImage, x: Int, y: Int, w: Int, h: Int) throws -> Double {
        let gray = CGContext(
            data: nil, width: w, height: h,
            bitsPerComponent: 8, bytesPerRow: 0,
            space: CGColorSpaceCreateDeviceGray(),
            bitmapInfo: CGImageAlphaInfo.none.rawValue
        )!
        gray.draw(image, in: CGRect(x: -x, y: -y, width: image.width, height: image.height))
        guard let dataPtr = gray.data else { return 0 }
        let buf = dataPtr.bindMemory(to: UInt8.self, capacity: w * h)
        var total = 0.0
        for i in 0..<(w * h) { total += Double(buf[i]) }
        return total / Double(w * h) / 255.0
    }
}
