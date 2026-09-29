import XCTest
@testable import CameraKit
import BoothCore
import Foundation

// ============================================================
// LmxLibrary 符号解析 + C 结构体布局测试（不接真机）
// dylib 用 #filePath 相对定位 Sources/CameraKit/libLmxptpif.dylib
// ============================================================

final class LmxLibraryTests: XCTestCase {

    /// 工程内 dylib：<root>/Sources/CameraKit/libLmxptpif.dylib
    private var dylibPath: String {
        // #filePath = <root>/Tests/CameraKitTests/LmxLibraryTests.swift
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()   // CameraKitTests
            .deletingLastPathComponent()   // Tests
            .deletingLastPathComponent()   // root
            .appendingPathComponent("Sources/CameraKit/libLmxptpif.dylib")
            .path
    }

    func testDylibExists() {
        XCTAssertTrue(FileManager.default.fileExists(atPath: dylibPath),
                      "测试 dylib 不存在: \(dylibPath)")
    }

    /// 全部 mangled 符号（lmx.py L94-146 对照表）可解析
    func testAllRequiredSymbolsResolve() throws {
        let lib = try LmxLibrary(path: dylibPath)
        XCTAssertEqual(lib.path, dylibPath)
        // 能走到这里说明 17 个符号全部 dlsym 成功；再逐个裸 dlsym 验证
        let handle = dlopen(dylibPath, RTLD_NOW | RTLD_LOCAL)
        XCTAssertNotNil(handle)
        defer { dlclose(handle) }
        for s in LmxLibrary.requiredSymbols {
            XCTAssertNotNil(dlsym(handle, s.mangled),
                            "符号缺失: \(s.readable) (\(s.mangled))")
        }
    }

    /// 符号缺失时报错并列出缺失清单（用系统库冒充，必然缺 LMX 符号）
    func testMissingSymbolsReported() {
        XCTAssertThrowsError(try LmxLibrary(path: "/usr/lib/libSystem.B.dylib")) { error in
            guard case LmxLibrary.LoadError.missingSymbols(let missing) = error else {
                return XCTFail("期望 missingSymbols，实际: \(error)")
            }
            XCTAssertEqual(missing.count, LmxLibrary.requiredSymbols.count)
            XCTAssertTrue(missing.first?.contains("LMX_func_api_Init") == true)
        }
    }

    /// 不存在路径报 openFailed / notFound
    func testLoadFailures() {
        XCTAssertThrowsError(try LmxLibrary(path: "/nonexistent/libLmxptpif.dylib")) { error in
            guard case LmxLibrary.LoadError.openFailed = error else {
                return XCTFail("期望 openFailed，实际: \(error)")
            }
        }
        // 查找顺序：配置路径必须排在最前，bundle 资源/开发兜底随后
        let candidates = LmxLibrary.candidatePaths(configuredPath: "/nonexistent/x.dylib")
        XCTAssertEqual(candidates.first, "/nonexistent/x.dylib")
        XCTAssertTrue(candidates.contains("/Users/liqiang/src/booth/lib/libLmxptpif.dylib"))
        // 本机兜底存在时 load 能成功（这也是开发机的预期路径）
        if candidates.contains(where: { FileManager.default.fileExists(atPath: $0) }) {
            XCTAssertNoThrow(try LmxLibrary.load(configuredPath: ""))
        }
    }

    // MARK: - 结构体布局（lmx.py L47-74 精确复刻的回归保险）

    /// PTP_ARRAY_STRING = {u8 len; char s[257]; u8 flag} → 259 字节，对齐 1
    func testPTPArrayStringLayout() {
        XCTAssertEqual(MemoryLayout<LmxPTPArrayString>.size, 259)
        XCTAssertEqual(MemoryLayout<LmxPTPArrayString>.alignment, 1)
        XCTAssertEqual(MemoryLayout<LmxPTPArrayString>.stride, 259)
        // 字段偏移：len@0, s@1, flag@258
        var v = LmxPTPArrayString()
        withUnsafeBytes(of: &v) { raw in
            XCTAssertEqual(raw.count, 259)
        }
        v.len = 3
        XCTAssertEqual(withUnsafeBytes(of: &v) { $0[0] }, 3)
    }

    /// REC_CTRL = {u32 param; u16 n_params; u16 pad; u32 params[16]} → 72 字节，对齐 4
    func testRecCtrlLayout() {
        XCTAssertEqual(MemoryLayout<LmxRecCtrl>.size, 72)
        XCTAssertEqual(MemoryLayout<LmxRecCtrl>.alignment, 4)
        XCTAssertEqual(MemoryLayout<LmxRecCtrl>.stride, 72)
        // param@0, n_params@4, pad@6, params@8
        var c = LmxRecCtrl.halfPress(true)
        XCTAssertEqual(withUnsafeBytes(of: &c) { $0.load(fromByteOffset: 0, as: UInt32.self) }, 1)
        XCTAssertEqual(withUnsafeBytes(of: &c) { $0.load(fromByteOffset: 4, as: UInt16.self) }, 0)
        c.nParams = 2
        withUnsafeMutableBytes(of: &c.params) { p in
            p.storeBytes(of: UInt32(0xAA), toByteOffset: 0, as: UInt32.self)
            p.storeBytes(of: UInt32(0xBB), toByteOffset: 4, as: UInt32.self)
        }
        XCTAssertEqual(withUnsafeBytes(of: &c) { $0.load(fromByteOffset: 8, as: UInt32.self) }, 0xAA)
        XCTAssertEqual(withUnsafeBytes(of: &c) { $0.load(fromByteOffset: 12, as: UInt32.self) }, 0xBB)
    }

    // MARK: - CONNECT_DEVICE_INFO 原始缓冲区解析

    /// 构造假缓冲区验证布局解析：count@0x0、uuid 指针表@0x8、条目 stride 0x80C、
    /// devId@+0x208、model@+0x20C（UTF-32）、serial@+0x610
    func testDeviceInfoParsing() {
        let bufSize = LmxDeviceInfoParser.bufferSize
        let buf = UnsafeMutableRawPointer.allocate(byteCount: bufSize, alignment: 8)
        defer { buf.deallocate() }
        buf.initializeMemory(as: UInt8.self, repeating: 0, count: bufSize)

        // wchar(UTF-32) 写入助手
        func writeUTF32(_ s: String, to p: UnsafeMutableRawPointer) {
            for (i, scalar) in s.unicodeScalars.enumerated() {
                p.storeBytes(of: scalar.value, toByteOffset: i * 4, as: UInt32.self)
            }
            p.storeBytes(of: UInt32(0), toByteOffset: s.unicodeScalars.count * 4, as: UInt32.self)
        }

        // uuid 指针表需要真实指针：单独分配 UTF-32 串
        let uuidStr = UnsafeMutableRawPointer.allocate(byteCount: 0x400, alignment: 8)
        defer { uuidStr.deallocate() }
        writeUTF32("UUID-S5-1234", to: uuidStr)

        let stride = LmxDeviceInfoParser.entryStride
        // 设备数 = 1
        buf.storeBytes(of: UInt32(1), toByteOffset: 0x0, as: UInt32.self)
        // uuid 指针表 @0x8
        buf.storeBytes(of: UInt(UInt(bitPattern: uuidStr)), toByteOffset: 0x8, as: UInt.self)
        // 条目 0：devId@+0x208、model@+0x20C、modelLen@+0x60C、serial@+0x610、serialLen@+0xA0C
        let entry = buf
        entry.storeBytes(of: UInt32(42), toByteOffset: 0x208, as: UInt32.self)
        writeUTF32("DC-S5", to: entry + 0x20C)
        entry.storeBytes(of: UInt32(5), toByteOffset: 0x60C, as: UInt32.self)
        writeUTF32("WJA12345", to: entry + 0x610)
        entry.storeBytes(of: UInt32(8), toByteOffset: 0xA0C, as: UInt32.self)
        _ = stride

        let devices = LmxDeviceInfoParser.parse(UnsafeRawPointer(buf))
        XCTAssertEqual(devices.count, 1)
        XCTAssertEqual(devices[0].devId, 42)
        XCTAssertEqual(devices[0].uuid, "UUID-S5-1234")
        XCTAssertEqual(devices[0].model, "DC-S5")
        XCTAssertEqual(devices[0].serial, "WJA12345")
    }

    /// count=0 → 空列表；count 超上限被钳制不越界
    func testDeviceInfoParsingEmptyAndClamped() {
        let buf = UnsafeMutableRawPointer.allocate(byteCount: LmxDeviceInfoParser.bufferSize, alignment: 8)
        defer { buf.deallocate() }
        buf.initializeMemory(as: UInt8.self, repeating: 0, count: LmxDeviceInfoParser.bufferSize)
        XCTAssertTrue(LmxDeviceInfoParser.parse(UnsafeRawPointer(buf)).isEmpty)
        buf.storeBytes(of: UInt32(999), toByteOffset: 0, as: UInt32.self)
        XCTAssertEqual(LmxDeviceInfoParser.parse(UnsafeRawPointer(buf)).count, LmxDeviceInfoParser.maxDevices)
    }

    /// PTP_ARRAY_STRING 的 Pascal 串取值
    func testPTPArrayStringValue() {
        var v = LmxPTPArrayString()
        let name = "P1000123.JPG"
        let bytes = Array(name.utf8)
        v.len = UInt8(bytes.count)
        withUnsafeMutableBytes(of: &v.s) { raw in
            raw.copyBytes(from: bytes)
        }
        XCTAssertEqual(v.string(), name)
    }
}
