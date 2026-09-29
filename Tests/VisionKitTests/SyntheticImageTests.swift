import BoothCore
import CoreGraphics
import XCTest
@testable import VisionKit

// ============================================================
// 合成图端到端测试：
//  - 程序生成的纯色/带矩形块图 → JPEG → 各检测器
//  - 无人/无手画面必须"不崩溃、返回未命中"，分割器输出全黑 matte
//  - 全部离线运行，不接相机
// ============================================================

final class SyntheticImageTests: XCTestCase {

    /// 灰色纯色 JPEG
    private func solidGrayJPEG(size: Int) -> Data? {
        guard let img = makeImage(width: size, height: size, background: (0.5, 0.5, 0.5)) else { return nil }
        return encodeJPEG(img)
    }

    // MARK: - 就绪检测：无人画面 → not ready，不崩溃

    func testReadinessOnEmptyScene() async {
        guard let jpeg = solidGrayJPEG(size: 200) else {
            return XCTFail("合成 JPEG 失败")
        }
        let detector = PoseReadinessDetector()
        let result = await detector.detectReadiness(in: jpeg)

        XCTAssertFalse(result.humanPresent, "纯色图不应检出人体")
        XCTAssertFalse(result.facePresent, "纯色图不应检出人脸")
        XCTAssertFalse(result.isReady)
        XCTAssertEqual(result.faceAreaRatio, 0, accuracy: 1e-9)
    }

    func testReadinessOnRectBlockScene() async {
        // 灰底 + 一个白色矩形块（模拟现场干扰物；不是人 → 不应误判）
        guard let img = makeImage(width: 200, height: 200, background: (0.4, 0.4, 0.4), draw: { ctx, w, h in
            ctx.setFillColor(gray: 1, alpha: 1)
            ctx.fill(CGRect(x: CGFloat(w) / 3, y: CGFloat(h) / 3,
                            width: CGFloat(w) / 3, height: CGFloat(h) / 3))
        }) else { return XCTFail("合成图失败") }
        let jpeg = encodeJPEG(img)

        let result = await PoseReadinessDetector(minFaceAreaRatio: 0.01).detectReadiness(in: jpeg)
        XCTAssertFalse(result.isReady, "矩形块画面不应判为就绪")
    }

    func testReadinessThresholdApplied() async {
        // 纯构造验证阈值语义：人/脸都缺失时，任何阈值下都 not ready；
        // isReady 公式为 human && face && ratio >= 阈值（阈值大 → 更难就绪）
        guard let jpeg = solidGrayJPEG(size: 200) else { return XCTFail("合成 JPEG 失败") }
        let result = await PoseReadinessDetector(minFaceAreaRatio: 0.0).detectReadiness(in: jpeg)
        XCTAssertFalse(result.isReady, "无人无脸时零阈值也不应就绪")
    }

    // MARK: - 手势：无手画面 → nil，不崩溃

    func testGestureOnEmptyScene() async {
        guard let jpeg = solidGrayJPEG(size: 160) else {
            return XCTFail("合成 JPEG 失败")
        }
        let gesture = await GestureDetector().detectGesture(in: jpeg)
        XCTAssertNil(gesture, "无手画面应返回 nil")
    }

    // MARK: - 分割：无人图 → 同尺寸全黑 matte，不抛错

    func testSegmentationOnEmptyScene() async throws {
        guard let img = makeImage(width: 64, height: 48, background: (0.2, 0.2, 0.2)) else {
            return XCTFail("合成图失败")
        }
        let mask = try await PersonSegmenter().segmentationMask(for: img)

        // 同尺寸
        XCTAssertEqual(mask.width, img.width)
        XCTAssertEqual(mask.height, img.height)
        // 8bit 灰度
        XCTAssertEqual(mask.bitsPerComponent, 8)
        XCTAssertEqual(mask.bitsPerPixel, 8)
        // 全黑
        XCTAssertTrue(allPixelsBlack(mask), "无人的 matte 应全黑")
    }

    // MARK: - 解码与降采样

    func testJPEGDecodeRoundTrip() {
        guard let img = makeImage(width: 120, height: 80, background: (0.7, 0.2, 0.2)) else {
            return XCTFail("合成图失败")
        }
        let decoded = FrameImage.decode(jpeg: encodeJPEG(img))
        XCTAssertNotNil(decoded, "JPEG 解码不应失败")
        XCTAssertEqual(decoded?.width, 120)
        XCTAssertEqual(decoded?.height, 80)
    }

    func testDownscaleLongEdge() {
        guard let big = makeImage(width: 2000, height: 1000, background: (0, 0, 0)) else {
            return XCTFail("合成图失败")
        }
        let small = FrameImage.downscaleForDetection(big)
        XCTAssertEqual(small.width, 960, "最长边应被压到 960")
        XCTAssertEqual(small.height, 480)
    }

    func testNoDownscaleWhenAlreadySmall() {
        guard let small = makeImage(width: 640, height: 480, background: (0, 0, 0)) else {
            return XCTFail("合成图失败")
        }
        let out = FrameImage.downscaleForDetection(small)
        XCTAssertEqual(out.width, 640, "小于上限的图不重绘")
        XCTAssertEqual(out.height, 480)
    }

    // MARK: - 辅助

    /// 读取灰度 matte 全部像素，验证全为 0
    private func allPixelsBlack(_ mask: CGImage) -> Bool {
        let w = mask.width, h = mask.height
        guard let ctx = FrameImage.makeGrayContext(width: w, height: h) else { return false }
        ctx.draw(mask, in: CGRect(x: 0, y: 0, width: CGFloat(w), height: CGFloat(h)))
        guard let data = ctx.data else { return false }
        let bytes = data.assumingMemoryBound(to: UInt8.self)
        let rowBytes = ctx.bytesPerRow
        for row in 0..<h {
            let line = bytes + row * rowBytes
            for col in 0..<w where line[col] > 0 { return false }
        }
        return true
    }
}
