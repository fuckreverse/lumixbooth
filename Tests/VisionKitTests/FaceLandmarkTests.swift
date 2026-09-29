import XCTest
import CoreGraphics
@testable import VisionKit
import BoothCore

// ============================================================
// FaceLandmarkDetector 测试 — 合成图验证"无人脸返回空数组"契约；
// 真实人脸关键点精度靠真机成片验证（合成图无真人脸）
// ============================================================

final class FaceLandmarkTests: XCTestCase {

    /// 纯色空场景：不抛错、返回空数组
    func testNoFaceReturnsEmpty() async throws {
        let detector = FaceLandmarkDetector()
        let ctx = CGContext(
            data: nil, width: 400, height: 300,
            bitsPerComponent: 8, bytesPerRow: 0,
            space: CGColorSpace(name: CGColorSpace.sRGB)!,
            bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue
        )!
        ctx.setFillColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)
        ctx.fill(CGRect(x: 0, y: 0, width: 400, height: 300))
        let image = ctx.makeImage()!

        let faces = try await detector.detectFaces(in: image)
        XCTAssertTrue(faces.isEmpty, "无人脸场景应返回空数组而非抛错")
    }

    /// 大图（>960px）走降采样路径不崩
    func testLargeImageDownscalePath() async throws {
        let detector = FaceLandmarkDetector()
        let ctx = CGContext(
            data: nil, width: 3000, height: 2000,
            bitsPerComponent: 8, bytesPerRow: 0,
            space: CGColorSpace(name: CGColorSpace.sRGB)!,
            bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue
        )!
        ctx.setFillColor(red: 0.2, green: 0.6, blue: 0.9, alpha: 1)
        ctx.fill(CGRect(x: 0, y: 0, width: 3000, height: 2000))
        let image = ctx.makeImage()!

        let faces = try await detector.detectFaces(in: image)
        XCTAssertTrue(faces.isEmpty)
    }
}
