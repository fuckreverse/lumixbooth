import Foundation
import CoreGraphics
import ImageIO
import BoothCore

// ============================================================
// 预览/PDF 打印后端（演示 dry-run，SPEC §12 无打印机降级路径）
//  - 不触碰 CUPS/打印机：把打印位图包成 PDF 落到 print-preview/
//  - 份数语义保留：copies=N → PDF 含 N 页相同内容
//  - 页面尺寸 4×6 英寸（288×432pt），与 1200×1800 @300dpi 打印位图一致
//  - 可编程延迟模拟出片耗时；可选自动打开预览（默认关，演示大屏不打扰）
// ============================================================

actor PreviewPrintBackend: PrintBackend {

    /// 一次预览打印的记录
    struct Record: Sendable, Equatable {
        let imagePath: String
        let pdfPath: String
        let copies: Int
    }

    /// 每个作业的人为延迟（模拟打印机出片耗时，让 UI printing 态可见）
    var delay: Duration

    /// 生成 PDF 后是否自动用系统预览打开（演示大屏建议关）
    var autoOpen: Bool

    /// PDF 输出目录（测试注入临时目录）
    let outputDir: URL

    /// 收到的作业记录（顺序敏感）
    private(set) var records: [Record] = []

    /// 默认输出目录：~/Library/Application Support/Booth/print-preview/
    static var defaultOutputDir: URL { BoothPaths.printPreviewDir }

    init(outputDir: URL? = nil, delay: Duration = .milliseconds(800), autoOpen: Bool = false) {
        self.outputDir = outputDir ?? PreviewPrintBackend.defaultOutputDir
        self.delay = delay
        self.autoOpen = autoOpen
    }

    func print(imagePath: String, copies: Int, config: BoothConfig.PrintConf) async throws {
        guard FileManager.default.fileExists(atPath: imagePath) else {
            throw PrintBackendError.fileNotFound(imagePath)
        }
        if delay > .zero {
            try await Task.sleep(for: delay)
        }
        let pdfURL = try Self.renderPDF(imagePath: imagePath, copies: copies, to: outputDir)
        records.append(Record(imagePath: imagePath, pdfPath: pdfURL.path, copies: copies))
        Log.print.info("[Preview] 已生成预览 PDF（\(copies) 页）: \(pdfURL.path)")
        if autoOpen {
            Self.openInPreview(pdfURL)
        }
    }

    // MARK: - PDF 渲染

    /// 把位图包成 N 页 PDF：页尺寸固定 4×6 英寸，图片满幅居中（无边距语义）
    static func renderPDF(imagePath: String, copies: Int, to dir: URL) throws -> URL {
        let srcURL = URL(fileURLWithPath: imagePath)
        guard let src = CGImageSourceCreateWithURL(srcURL as CFURL, nil),
              let image = CGImageSourceCreateImageAtIndex(src, 0, nil) else {
            throw PrintBackendError.previewFailed("无法解码位图: \(imagePath)")
        }

        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        let stamp = DateFormatter.boothLogTime.string(from: Date())
            .replacingOccurrences(of: "[-: ]", with: "", options: .regularExpression)
        let base = srcURL.deletingPathExtension().lastPathComponent
        let pdfURL = dir.appendingPathComponent("\(stamp)-\(base).pdf")

        // 6 寸相纸 = 4×6 英寸 = 288×432pt（PDF 点 = 1/72 英寸）
        let pageRect = CGRect(x: 0, y: 0, width: 288, height: 432)
        guard let ctx = CGContext(pdfURL as CFURL, mediaBox: nil, nil) else {
            throw PrintBackendError.previewFailed("无法创建 PDF: \(pdfURL.path)")
        }
        for _ in 0..<max(1, copies) {
            var box = pageRect
            ctx.beginPDFPage([kCGPDFContextMediaBox: NSData(bytes: &box, length: MemoryLayout<CGRect>.size)] as CFDictionary)
            ctx.draw(image, in: pageRect)
            ctx.endPDFPage()
        }
        ctx.closePDF()
        return pdfURL
    }

    /// 系统预览打开（fire-and-forget；失败只记日志）
    private static func openInPreview(_ url: URL) {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/open")
        process.arguments = [url.path]
        do { try process.run() } catch {
            Log.print.warn("[Preview] 自动打开预览失败: \(error.localizedDescription)")
        }
    }
}
