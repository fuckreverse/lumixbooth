import XCTest
import CoreGraphics
import ImageIO
import BoothCore
@testable import PrintKit

// ============================================================
// PreviewPrintBackend + dryRun 路由单测
//  - 全部落临时目录，绝不触碰 CUPS/真实打印机
// ============================================================

final class PreviewPrintBackendTests: XCTestCase {

    // MARK: - 工具

    private var tmpDir: URL!

    override func setUp() {
        super.setUp()
        tmpDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("booth-preview-test-\(UUID().uuidString)", isDirectory: true)
        try? FileManager.default.createDirectory(at: tmpDir, withIntermediateDirectories: true)
    }

    override func tearDown() {
        try? FileManager.default.removeItem(at: tmpDir)
        super.tearDown()
    }

    /// 生成一张测试 JPEG（CoreGraphics 纯色填充）
    private func makeJPEG(name: String = "print.jpg") throws -> URL {
        let url = tmpDir.appendingPathComponent(name)
        guard let space = CGColorSpace(name: CGColorSpace.sRGB),
              let ctx = CGContext(data: nil, width: 120, height: 180,
                                  bitsPerComponent: 8, bytesPerRow: 0, space: space,
                                  bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue) else {
            throw NSError(domain: "test", code: 1)
        }
        ctx.setFillColor(CGColor(srgbRed: 0.8, green: 0.6, blue: 0.4, alpha: 1))
        ctx.fill(CGRect(x: 0, y: 0, width: 120, height: 180))
        let image = try XCTUnwrap(ctx.makeImage())
        let data = NSMutableData()
        guard let dest = CGImageDestinationCreateWithData(data as CFMutableData, "public.jpeg" as CFString, 1, nil)
        else { throw NSError(domain: "test", code: 2) }
        CGImageDestinationAddImage(dest, image, nil)
        guard CGImageDestinationFinalize(dest) else { throw NSError(domain: "test", code: 3) }
        try data.write(to: url)
        return url
    }

    /// 轮询等待条件成立（默认 5s 超时）
    @discardableResult
    private func waitUntil(
        timeout: TimeInterval = 5,
        _ condition: @escaping () async -> Bool
    ) async -> Bool {
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            if await condition() { return true }
            try? await Task.sleep(nanoseconds: 20_000_000)
        }
        return await condition()
    }

    // MARK: - 1. PDF 落盘：份数 == 页数，页面为 4×6 英寸

    func testPreviewWritesPDFWithPagesEqualCopies() async throws {
        let imageURL = try makeJPEG()
        let backend = PreviewPrintBackend(outputDir: tmpDir, delay: .zero)

        try await backend.print(imagePath: imageURL.path, copies: 3, config: BoothConfig.PrintConf())

        let records = await backend.records
        XCTAssertEqual(records.count, 1)
        XCTAssertEqual(records.first?.copies, 3)
        let pdfPath = try XCTUnwrap(records.first?.pdfPath)
        XCTAssertTrue(FileManager.default.fileExists(atPath: pdfPath), "PDF 应已落盘")

        let pdfURL = URL(fileURLWithPath: pdfPath)
        let doc = try XCTUnwrap(CGPDFDocument(pdfURL as CFURL), "产物应是合法 PDF")
        XCTAssertEqual(doc.numberOfPages, 3, "copies=3 → PDF 应有 3 页")
        let mediaBox = doc.page(at: 1)?.getBoxRect(.mediaBox)
        XCTAssertEqual(mediaBox?.width ?? 0, 288, accuracy: 0.5, "页宽应为 4 英寸 = 288pt")
        XCTAssertEqual(mediaBox?.height ?? 0, 432, accuracy: 0.5, "页高应为 6 英寸 = 432pt")
    }

    // MARK: - 2. 源文件缺失 → fileNotFound

    func testPreviewMissingSourceThrows() async {
        let backend = PreviewPrintBackend(outputDir: tmpDir, delay: .zero)
        do {
            try await backend.print(imagePath: "/tmp/booth-definitely-not-exists.jpg",
                                    copies: 1, config: BoothConfig.PrintConf())
            XCTFail("源文件缺失应抛错")
        } catch let error as PrintBackendError {
            guard case .fileNotFound = error else {
                return XCTFail("应为 fileNotFound，实际: \(error)")
            }
        } catch {
            XCTFail("应抛 PrintBackendError，实际: \(error)")
        }
        let records = await backend.records
        XCTAssertTrue(records.isEmpty, "失败不应产生记录")
    }

    // MARK: - 3. dryRun=true 配置：PrintService 路由到 Preview 后端，注入 Mock 收不到作业

    func testDryRunConfigRoutesToPreview() async throws {
        let imageURL = try makeJPEG()
        let mock = MockPrintBackend()
        let preview = PreviewPrintBackend(outputDir: tmpDir, delay: .zero)

        var config = BoothConfig.PrintConf()
        config.dryRun = true
        let service = PrintService(backend: mock, config: config, previewFactory: { preview })

        await service.submit(image: imageURL, copies: 2)
        let done = await waitUntil { (await service.jobs).first?.status == .done }
        XCTAssertTrue(done, "dry-run 任务应走 Preview 后端成功完成")

        let mockRecords = await mock.records
        XCTAssertTrue(mockRecords.isEmpty, "dryRun 下注入的后端不应收到作业")
        let previewRecords = await preview.records
        XCTAssertEqual(previewRecords.count, 1, "作业应路由到 Preview 后端")
    }

    // MARK: - 4. dryRun 热切换：applyConfig(dryRun=true) 后新作业改走 Preview

    func testDryRunHotSwap() async throws {
        let imageURL = try makeJPEG()
        let mock = MockPrintBackend()
        let preview = PreviewPrintBackend(outputDir: tmpDir, delay: .zero)

        let service = PrintService(backend: mock, config: BoothConfig.PrintConf(),
                                   previewFactory: { preview })
        // dryRun=false 时：作业走注入的 mock
        await service.submit(image: imageURL, copies: 1)
        var done = await waitUntil { (await service.jobs).first?.status == .done }
        XCTAssertTrue(done)
        let mockCount1 = await mock.records.count
        let previewCount1 = await preview.records.count
        XCTAssertEqual(mockCount1, 1)
        XCTAssertEqual(previewCount1, 0)

        // 热切 dryRun=true：后续作业改走 Preview
        var dryConfig = BoothConfig.PrintConf()
        dryConfig.dryRun = true
        await service.applyConfig(dryConfig)

        // 换文件名避开去重窗口
        let imageURL2 = try makeJPEG(name: "print-2.jpg")
        await service.submit(image: imageURL2, copies: 1)
        done = await waitUntil {
            let jobs = await service.jobs
            return jobs.count == 2 && jobs.allSatisfy { $0.status == .done }
        }
        XCTAssertTrue(done)
        let mockCount2 = await mock.records.count
        let previewCount2 = await preview.records.count
        XCTAssertEqual(mockCount2, 1, "热切换后注入后端不应再收到作业")
        XCTAssertEqual(previewCount2, 1, "热切换后作业应走 Preview 后端")
    }
}
