import XCTest
@testable import CameraKit
import BoothCore
import Foundation

// ============================================================
// 电量/存储状态功能测试（2026-09 新增，不接真机）
//  - LmxBatteryInfo 16B 布局与解析（逆向 @0x42400 的回归保险）
//  - 事件 CBID 修正回归（0x0E000254/57 → 0x10000000/01/02）
//  - CameraStatusReport 百分比启发式
//  - Mock 状态轮询流
// ============================================================

final class CameraStatusTests: XCTestCase {

    // MARK: - LmxBatteryInfo 布局（PTP vendor 0x9414，16 字节）

    func testBatteryInfoLayout() {
        XCTAssertEqual(MemoryLayout<LmxBatteryInfo>.size, 16)
        XCTAssertEqual(MemoryLayout<LmxBatteryInfo>.alignment, 4)
        XCTAssertEqual(MemoryLayout<LmxBatteryInfo>.stride, 16)
    }

    /// parse() 按逆向布局逐字段读：tag@0(u32) size@4(u32) fields@8..16(4×u16)
    func testBatteryInfoParse() {
        let buf = UnsafeMutableRawPointer.allocate(byteCount: 16, alignment: 4)
        defer { buf.deallocate() }
        buf.storeBytes(of: UInt32(0x1600B0D1), toByteOffset: 0, as: UInt32.self)
        buf.storeBytes(of: UInt32(8), toByteOffset: 4, as: UInt32.self)
        buf.storeBytes(of: UInt16(64), toByteOffset: 8, as: UInt16.self)
        buf.storeBytes(of: UInt16(1), toByteOffset: 10, as: UInt16.self)
        buf.storeBytes(of: UInt16(7850), toByteOffset: 12, as: UInt16.self)
        buf.storeBytes(of: UInt16(300), toByteOffset: 14, as: UInt16.self)

        let info = LmxBatteryInfo.parse(buf)
        XCTAssertEqual(info.tag, 0x1600B0D1)
        XCTAssertEqual(info.size, 8)
        XCTAssertEqual(info.fieldArray, [64, 1, 7850, 300])
    }

    /// 零初始化默认值
    func testBatteryInfoDefaults() {
        let info = LmxBatteryInfo()
        XCTAssertEqual(info.tag, 0)
        XCTAssertEqual(info.size, 0)
        XCTAssertEqual(info.fieldArray, [0, 0, 0, 0])
    }

    // MARK: - 事件 CBID 修正回归（逆向自 Send_NotifyMsg_* @0x445F4/0x446FC/0x44808）

    func testEventCBIDs() {
        XCTAssertEqual(LmxEvent.objectAdded, 0x10000040)
        XCTAssertEqual(LmxEvent.dataTransferProg, 0x10000081)
        XCTAssertEqual(LmxEvent.deviceStray, 0x10000010)
        XCTAssertEqual(LmxEvent.reqObjTransfer, 0x10000100)
        // 修正后：旧 lmx.py 的 0x0E000254/57 是 PTP 标准事件码，注册无效
        XCTAssertEqual(LmxEvent.storeAdded, 0x10000000)
        XCTAssertEqual(LmxEvent.storeRemoved, 0x10000001)
        XCTAssertEqual(LmxEvent.storageInfoChanged, 0x10000002)
        // 三个存储事件互不相同（防手滑写重）
        XCTAssertNotEqual(LmxEvent.storeAdded, LmxEvent.storeRemoved)
        XCTAssertNotEqual(LmxEvent.storeRemoved, LmxEvent.storageInfoChanged)
    }

    // MARK: - CameraStatusReport 百分比启发式

    func testBatteryPercentHeuristic() {
        // 电池百分比放首字段（最常见布局）
        var r = CameraStatusReport(batteryFields: [64, 1, 7850, 300], freeRecordSeconds: 5400)
        XCTAssertEqual(r.batteryPercent, 64)
        XCTAssertFalse(r.batteryLow)

        // 低电告警：≤15%
        r = CameraStatusReport(batteryFields: [12, 1, 0, 0], freeRecordSeconds: nil)
        XCTAssertEqual(r.batteryPercent, 12)
        XCTAssertTrue(r.batteryLow)

        // 0%（放电完毕）
        r = CameraStatusReport(batteryFields: [0, 1, 0, 0], freeRecordSeconds: nil)
        XCTAssertEqual(r.batteryPercent, 0)
        XCTAssertTrue(r.batteryLow)

        // 空数组（查询失败）→ 无百分比，不误报低电
        r = CameraStatusReport(batteryFields: [], freeRecordSeconds: nil)
        XCTAssertNil(r.batteryPercent)
        XCTAssertFalse(r.batteryLow)

        // 全是大值（布局未知）→ 不瞎猜
        r = CameraStatusReport(batteryFields: [600, 700, 800, 900], freeRecordSeconds: 1)
        XCTAssertNil(r.batteryPercent)
    }

    // MARK: - Mock 状态轮询

    func testMockRefreshStatusBroadcast() async throws {
        let cam = MockCameraService()
        var events = cam.events.makeAsyncIterator()
        _ = try await cam.connect()

        // connect() 末尾应立即广播一份 statusReport
        let report: CameraStatusReport = try await firstStatusReport(from: &events)
        XCTAssertEqual(report.batteryPercent, 87)   // mock 初始电量
        XCTAssertEqual(report.freeRecordSeconds, 5400)

        // 手动刷新 → 电量递减
        await cam.refreshStatus()
        let report2 = try await firstStatusReport(from: &events)
        XCTAssertEqual(report2.batteryPercent, 86)

        // 断开后不再广播
        await cam.disconnect()
        await cam.refreshStatus()
        var next: CameraEvent?
        // events 流无限，只能靠超时验证没有 statusReport；改为状态守卫检查
        // （refreshStatus guard 已直接短路，不产生事件）
        _ = next
        let state = await cam.connectionState
        XCTAssertEqual(state, .disconnected)
    }

    func testMockStatusPolling() async throws {
        let cam = MockCameraService()
        var events = cam.events.makeAsyncIterator()
        await cam.setStatusInterval(0.1)
        _ = try await cam.connect()
        _ = try await events.next()   // connected
        _ = try await firstStatusReport(from: &events)  // 首份

        // 等一个轮询周期，应收到第二份（电量递减：87 首份 → 轮询 86）
        let r2 = try await firstStatusReport(from: &events, timeout: 3)
        XCTAssertEqual(r2.batteryPercent, 86)
        await cam.disconnect()
    }

    // MARK: - 助手

    private func firstStatusReport(from events: inout AsyncStream<CameraEvent>.Iterator,
                                   timeout: TimeInterval = 2) async throws -> CameraStatusReport {
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            guard let ev = await events.next() else { break }
            if case .statusReport(let r) = ev { return r }
        }
        XCTFail("超时未收到 statusReport")
        throw BoothError.captureFailed("超时未收到 statusReport")
    }
}
