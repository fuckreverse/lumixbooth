import CoreGraphics
import XCTest
@testable import CameraKit
import BoothCore
import Foundation

// ============================================================
// MockCameraService 行为测试（不接真机）
// 连接状态流 / 拍照返回 / 帧流产出 / 失败注入
// ============================================================

final class MockCameraServiceTests: XCTestCase {

    private func makeMock() -> MockCameraService {
        let m = MockCameraService()
        return m
    }


    func testConnectStateFlowAndEvent() async throws {
        let mock = makeMock()
        await mock.setConnectDelay(0.01)
        let stream = mock.events
        let eventsTask = Task { await collectCameraEvents(stream, count: 1) }

        let state1 = await mock.connectionState
        XCTAssertEqual(state1, .disconnected)
        try await mock.connect()
        let state2 = await mock.connectionState
        XCTAssertEqual(state2, .connected)

        let events = await eventsTask.value
        guard case .connected(let dev) = events.first else {
            return XCTFail("期望 .connected 事件，实际: \(String(describing: events.first))")
        }
        XCTAssertEqual(dev.model, "DC-S5")
    }

    func testConnectFailureInjection() async {
        let mock = makeMock()
        await mock.setConnectError(BoothError.cameraNotFound)
        do {
            try await mock.connect()
            XCTFail("应抛 cameraNotFound")
        } catch {
            XCTAssertEqual(error as? BoothError, .cameraNotFound)
        }
        let state3 = await mock.connectionState
        XCTAssertEqual(state3, .disconnected)
    }

    func testCaptureReturnsSyntheticJPEG() async throws {
        let mock = makeMock()
        await mock.setCaptureDelay(0.01)
        try await mock.connect()

        let stream = mock.events
        let eventsTask = Task { await collectCameraEvents(stream, count: 1) }
        let capture = try await mock.capture()

        // JPEG magic bytes
        XCTAssertGreaterThan(capture.data.count, 1000)
        XCTAssertEqual(capture.data[capture.data.startIndex], 0xFF)
        XCTAssertEqual(capture.data[capture.data.index(after: capture.data.startIndex)], 0xD8)
        XCTAssertEqual(capture.fileName, "P1000001.JPG")
        XCTAssertEqual(capture.handle, 1001)

        let events = await eventsTask.value
        guard case .objectAdded(let h) = events.first else {
            return XCTFail("期望 .objectAdded 事件")
        }
        XCTAssertEqual(h, capture.handle)

        // 第二张递增
        let c2 = try await mock.capture()
        XCTAssertEqual(c2.fileName, "P1000002.JPG")
    }

    func testCaptureFailureInjection() async throws {
        let mock = makeMock()
        try await mock.connect()
        await mock.setCaptureError(BoothError.captureTimeout)
        do {
            _ = try await mock.capture()
            XCTFail("应抛 captureTimeout")
        } catch {
            XCTAssertEqual(error as? BoothError, .captureTimeout)
        }
        // 一次性注入：第二次恢复成功
        _ = try await mock.capture()
    }

    func testCaptureBeforeConnectFails() async {
        let mock = makeMock()
        do {
            _ = try await mock.capture()
            XCTFail("未连接拍照应失败")
        } catch {
            XCTAssertTrue(error is BoothError)
        }
    }

    func testLiveViewFrameStream() async throws {
        let mock = makeMock()
        await mock.setFrameInterval(0.02)
        try await mock.connect()
        try await mock.startLiveView()
        let state4 = await mock.connectionState
        XCTAssertEqual(state4, .liveView)

        // 收 3 帧验证产出且各不相同（帧号/色相不同）
        var frames: [Data] = []
        for await frame in mock.liveViewFrames {
            frames.append(frame)
            if frames.count >= 3 { break }
        }
        XCTAssertEqual(frames.count, 3)
        for f in frames {
            XCTAssertEqual(f[f.startIndex], 0xFF)
            XCTAssertEqual(f[f.index(after: f.startIndex)], 0xD8)
        }
        XCTAssertNotEqual(frames[0], frames[1], "连续帧应不同（帧号变化）")

        await mock.stopLiveView()
        let state5 = await mock.connectionState
        XCTAssertEqual(state5, .connected)
        await mock.disconnect()
        let state6 = await mock.connectionState
        XCTAssertEqual(state6, .disconnected)
    }

    func testSyntheticImageSizes() {
        // LiveView 1280×720、成片 1920×1280（注释：真机 6000×4000 太大）
        guard let lv = MockImageFactory.liveViewJPEG(frame: 1),
              let shot = MockImageFactory.captureJPEG(sequence: 1) else {
            return XCTFail("合成 JPEG 生成失败")
        }
        XCTAssertEqual(jpegSize(lv), CGSize(width: 1280, height: 720))
        XCTAssertEqual(jpegSize(shot), CGSize(width: 1920, height: 1280))
    }

    /// 极简 JPEG SOF0 解析拿宽高（避免测试引入 ImageIO 依赖差异）
    private func jpegSize(_ data: Data) -> CGSize? {
        var i = 2   // 跳过 FFD8
        while i + 9 < data.count {
            guard data[i] == 0xFF else { return nil }
            let marker = data[i + 1]
            if marker == 0xC0 || marker == 0xC2 {
                let h = (Int(data[i + 5]) << 8) | Int(data[i + 6])
                let w = (Int(data[i + 7]) << 8) | Int(data[i + 8])
                return CGSize(width: w, height: h)
            }
            let segLen = (Int(data[i + 2]) << 8) | Int(data[i + 3])
            i += 2 + segLen
        }
        return nil
    }
}

/// 收集事件流的辅助：收满 count 个或超时返回已收的（文件级函数避免捕获 self）
private func collectCameraEvents(_ stream: AsyncStream<CameraEvent>, count: Int,
                                 timeout: TimeInterval = 3) async -> [CameraEvent] {
    await withTaskGroup(of: [CameraEvent].self) { group in
        group.addTask {
            var out: [CameraEvent] = []
            for await e in stream {
                out.append(e)
                if out.count >= count { break }
            }
            return out
        }
        group.addTask {
            try? await Task.sleep(nanoseconds: UInt64(timeout * 1_000_000_000))
            return []
        }
        let first = await group.next()!
        group.cancelAll()
        return first
    }
}

// 测试侧便捷注入接口（actor 隔离属性需要 await 写入，包一层更直观）
extension MockCameraService {
    func setConnectDelay(_ d: TimeInterval) { connectDelay = d }
    func setConnectError(_ e: (any Error)?) { connectError = e }
    func setCaptureError(_ e: (any Error)?) { captureError = e }
    func setCaptureDelay(_ d: TimeInterval) { captureDelay = d }
    func setFrameInterval(_ d: TimeInterval) { frameInterval = d }
}
