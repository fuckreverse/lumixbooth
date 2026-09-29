import XCTest
import CoreGraphics
@testable import ImagingKit

// ============================================================
// GIF/Boomerang（GIFCore）单元测试：
// 帧序列构造、编码产物有效性、缩放不放大。
// ============================================================
final class GIFCoreTests: XCTestCase {

    /// boomerang 帧序列：正放 + 倒放（首尾不重复，循环无缝）
    func testBoomerangIndices() {
        XCTAssertEqual(GIFCore.boomerangIndices(count: 0), [])
        XCTAssertEqual(GIFCore.boomerangIndices(count: 1), [0])
        XCTAssertEqual(GIFCore.boomerangIndices(count: 2), [0, 1],
                       "2 帧：倒放部分 dropLast 后为空，仅正放（首→尾直接回环）")
        XCTAssertEqual(GIFCore.boomerangIndices(count: 4), [0, 1, 2, 3, 2, 1],
                       "4 张原图 → 6 帧正放+倒放（首尾帧不重复）")
        XCTAssertEqual(GIFCore.boomerangIndices(count: 6), [0, 1, 2, 3, 4, 5, 4, 3, 2, 1])
    }

    /// 无缝循环：任意相邻帧（含首→尾跳回）序号差 ≤ 1
    func testBoomerangSeamlessLoop() {
        for n in 2...8 {
            let seq = GIFCore.boomerangIndices(count: n)
            for i in 0..<seq.count {
                let jump = abs(seq[i] - seq[(i + 1) % seq.count])
                XCTAssertLessThanOrEqual(jump, 1, "count=\(n) 第 \(i) 帧跳变 \(jump) 应 ≤1")
            }
        }
    }

    /// 编码：合成 3 帧 200×150 位图 → GIF 文件存在且魔数正确
    func testEncodeBoomerangProducesGIF() throws {
        let frames = (0..<3).map { self.makeFrame(width: 200, height: 150, tint: $0) }
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("booth-gif-test-\(UUID().uuidString).gif")
        defer { try? FileManager.default.removeItem(at: url) }
        try GIFCore.encodeBoomerang(frames: frames, to: url)

        let data = try Data(contentsOf: url)
        XCTAssertGreaterThan(data.count, 100, "GIF 文件不应为空")
        XCTAssertEqual([UInt8](data.prefix(3)), [0x47, 0x49, 0x46], "GIF89a 魔数")
        // 帧数 = 正放 3 + 倒放 1（boomerangIndices(3) = [0,1,2,1]，见上）
        let src = CGImageSourceCreateWithURL(url as CFURL, nil)
        XCTAssertNotNil(src)
        XCTAssertEqual(CGImageSourceGetCount(src!), 4, "3 帧原图应编出 4 帧 boomerang（正放 3 + 倒放 1）")
    }

    // MARK: - 辅助

    /// 生成纯色测试位图
    private func makeFrame(width: Int, height: Int, tint: Int) -> CGImage {
        let space = CGColorSpaceCreateDeviceRGB()
        let ctx = CGContext(data: nil, width: width, height: height,
                            bitsPerComponent: 8, bytesPerRow: 0, space: space,
                            bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)!
        ctx.setFillColor(red: CGFloat(tint) / 3, green: 0.5, blue: 1 - CGFloat(tint) / 3, alpha: 1)
        ctx.fill(CGRect(x: 0, y: 0, width: width, height: height))
        return ctx.makeImage()!
    }
}
