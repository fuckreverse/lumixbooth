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
}
