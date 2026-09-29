import BoothCore
import Foundation

// ============================================================
// libLmxptpif.dylib C 结构体 Swift 布局
// 布局完全按 lmx.py L47-74 与 analysis/ANALYSIS.md §3 逆向结论复刻，
// 任何字段改动都必须先核对逆向报告。
// ============================================================

/// _tag_LMX_STRUCT_PTP_ARRAY_STRING — Pascal 串 {u8 len; char s[257]; u8 flag}
/// 总 259 字节，对齐 1。Get_Object_FileName / Save_ObjectData_to_File 使用。
public struct LmxPTPArrayString {
    public var len: UInt8 = 0
    // char s[257] —— Swift 元组复刻定长数组
    public var s: (
        CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar,
        CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar,
        CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar,
        CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar,
        CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar,
        CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar,
        CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar,
        CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar,
        CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar,
        CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar,
        CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar,
        CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar,
        CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar,
        CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar,
        CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar,
        CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar,
        CChar
    ) = (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
         0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
         0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
         0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
         0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
         0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
         0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
         0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
         0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
         0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
         0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
         0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
         0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
         0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
         0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
         0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
         0)
    public var flag: UInt8 = 0

    public init() {}

    /// 按 Pascal 串语义取出 String（len 截断，非法 UTF-8 替换）
    public func string() -> String {
        var copy = self
        return withUnsafeBytes(of: &copy.s) { raw in
            let n = min(Int(copy.len), raw.count)
            return String(decoding: raw.prefix(n), as: UTF8.self)
        }
    }
}

/// _tag_LMX_STRUCT_REC_CTRL — {u32 param; u16 n_params; u16 pad; u32 params[16]}
/// 半按快门/精控用（Rec_Ctrl_Release → PTP vendor opcode 0x9412）。总 72 字节，对齐 4。
public struct LmxRecCtrl {
    public var param: UInt32 = 0
    public var nParams: UInt16 = 0
    public var pad: UInt16 = 0
    public var params: (UInt32, UInt32, UInt32, UInt32, UInt32, UInt32, UInt32, UInt32,
                        UInt32, UInt32, UInt32, UInt32, UInt32, UInt32, UInt32, UInt32)
        = (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)

    public init() {}

    /// 半按快门（对焦/测光）：REC_CTRL{param=1/0, n=0}，见 lmx.py half_press
    public static func halfPress(_ on: Bool) -> LmxRecCtrl {
        var c = LmxRecCtrl()
        c.param = on ? 1 : 0
        return c
    }
}

/// _tag_LMX_STRUCT_BATTERY_INFO — GetBatteryInfo 输出（PTP vendor 0x9414）。
/// 逆向自 LmxExt_GetBatteryInfo_from_Buf @0x42400（逐字段拷贝）：
///   {u32 tag; u32 size; u16 f[4]} 共 16 字节。
/// 4 个 u16 的语义库内无映射（主程序才消费），全量上抛由上层启发式判定。
public struct LmxBatteryInfo {
    public var tag: UInt32      // 响应块 tag（0x1600B0D1）
    public var size: UInt32     // 响应块长度
    public var fields: (UInt16, UInt16, UInt16, UInt16)

    public init() {
        tag = 0; size = 0; fields = (0, 0, 0, 0)
    }

    /// 从 16 字节原始缓冲区解析（库写入后的结构体直接重解释）
    public static func parse(_ raw: UnsafeRawPointer) -> LmxBatteryInfo {
        var v = LmxBatteryInfo()
        v.tag = raw.loadUnaligned(fromByteOffset: 0, as: UInt32.self)
        v.size = raw.loadUnaligned(fromByteOffset: 4, as: UInt32.self)
        v.fields = (raw.loadUnaligned(fromByteOffset: 8, as: UInt16.self),
                    raw.loadUnaligned(fromByteOffset: 10, as: UInt16.self),
                    raw.loadUnaligned(fromByteOffset: 12, as: UInt16.self),
                    raw.loadUnaligned(fromByteOffset: 14, as: UInt16.self))
        return v
    }

    /// Swift 侧访问用数组视图
    public var fieldArray: [UInt16] {
        [fields.0, fields.1, fields.2, fields.3]
    }
}

// MARK: - CONNECT_DEVICE_INFO 原始缓冲区解析

/// CONNECT_DEVICE_INFO 布局（GetPnPDeviceInfo 逆向 + 主程序读取点验证）：
///   +0x000               u32   设备数
///   +0x008 + i*8         wchar_t* uuid[i]（最多 64 槽，库 malloc 的 0x400 字节 UTF-32 串）
///   每设备条目 i 基址 = i*0x80C：
///     +0x208  u32   devId（传给 SelectPnPDevice 的第一参数）
///     +0x20C  wchar model[0x100];  +0x60C u32 modelLen
///     +0x610  wchar serial[0x100]; +0xA0C u32 serialLen
/// 注意：wchar 在本库是 4 字节 UTF-32（非 macOS 的 2 字节）。
public enum LmxDeviceInfoParser {
    public static let entryStride = 0x80C
    public static let maxDevices = 8
    /// Search_Device 缓冲区大小：0x208 + 0x80C * maxDevices
    public static let bufferSize = 0x208 + entryStride * maxDevices

    private static let offCount = 0x0
    private static let offUUIDTable = 0x8
    private static let offDevId = 0x208
    private static let offModel = 0x20C
    private static let offModelLen = 0x60C
    private static let offSerial = 0x610
    private static let offSerialLen = 0xA0C
    private static let wcharMax = 0x100

    /// 解析 Search_Device 输出缓冲区 → 设备列表
    public static func parse(_ base: UnsafeRawPointer) -> [CameraDeviceInfo] {
        let count = min(Int(base.loadUnaligned(fromByteOffset: offCount, as: UInt32.self)), maxDevices)
        var out: [CameraDeviceInfo] = []
        out.reserveCapacity(count)
        for i in 0..<count {
            let entry = base + entryStride * i
            let devId = entry.loadUnaligned(fromByteOffset: offDevId, as: UInt32.self)
            // uuid 指针表：读取指针，再按 UTF-32 解码
            var uuid = ""
            let uuidPtr = base.loadUnaligned(fromByteOffset: offUUIDTable + i * 8, as: UInt.self)
            if uuidPtr != 0, let p = UnsafeRawPointer(bitPattern: uuidPtr) {
                uuid = readUTF32(p, maxUnits: 0x400 / 4)
            }
            let modelLen = Int(entry.loadUnaligned(fromByteOffset: offModelLen, as: UInt32.self))
            let serialLen = Int(entry.loadUnaligned(fromByteOffset: offSerialLen, as: UInt32.self))
            let model = readUTF32(entry + offModel, maxUnits: modelLen > 0 ? min(modelLen, wcharMax) : wcharMax)
            let serial = readUTF32(entry + offSerial, maxUnits: serialLen > 0 ? min(serialLen, wcharMax) : wcharMax)
            out.append(CameraDeviceInfo(devId: devId, uuid: uuid, model: model, serial: serial))
        }
        return out
    }

    /// 读取 4 字节 UTF-32 wchar 串（遇 0 终止），非法标量丢弃
    static func readUTF32(_ p: UnsafeRawPointer, maxUnits: Int) -> String {
        var scalars = String.UnicodeScalarView()
        for i in 0..<maxUnits {
            let u = p.loadUnaligned(fromByteOffset: i * 4, as: UInt32.self)
            if u == 0 { break }
            if let s = Unicode.Scalar(u) { scalars.append(s) }
        }
        return String(scalars)
    }
}

// MARK: - 事件 ID / 错误码

/// 事件 CBID（Send_NotifyMsg_* 里 Get_CBID_from_CBList() 的第一参数，
/// 逆向自 libLmxptpif v2.12 @0x44554/0x446FC/0x44808/0x445F4）。
/// ⚠ lmx.py 旧值 0x0E000254/57 是 PTP 标准事件码，注册后不会被触发，已修正。
public enum LmxEvent {
public static let objectAdded: UInt32 = 0x10000040       // 照片落卡：param=object handle
public static let dataTransferProg: UInt32 = 0x11000000  // 下载进度（E6 勘误：Send_NotifyMsg_DataTransferProgress @0x450c4 硬编码）
public static let dataTransferProgLegacy: UInt32 = 0x10000081 // 旧值，双监听兼容
public static let deviceStray: UInt32 = 0x10000010       // 相机拔出/失联（USB 实测有效）
public static let deviceStrayAlt: UInt32 = 0x1FF20001   // 失联库内常量路径，双监听更稳
public static let deviceReset: UInt32 = 0x1FF20003      // 相机复位（E6 勘误；旧值 0x10000001 与 storeRemoved 撞值）
public static let reqObjTransfer: UInt32 = 0x10000043   // 相机请求传输（E6 勘误：真值；旧值 0x10000100 在静态表中不存在）
public static let storeAdded: UInt32 = 0x10000000         // 存储卡插入：param=storageID
public static let storeRemoved: UInt32 = 0x10000001      // 存储卡拔出：param=storageID
public static let storageInfoChanged: UInt32 = 0x10000002 // 存储信息变更（换卡/满）：param=storageID
}

public enum LmxError {
    public static let paramNull: UInt32 = 0x10000   // 参数为空
    public static let lvBusy: UInt32 = 0x40004      // LiveView 忙（正在取帧）——正常，跳过
    public static let lvGeneric: UInt32 = 0x40003
}

/// err 码格式化（日志统一 0x 前缀十六进制）
func lmxErrHex(_ err: UInt32) -> String { String(format: "0x%05X", err) }
