import BoothCore
import Foundation

// ============================================================
// LmxLibrary — libLmxptpif.dylib 的 dlopen/dlsym 封装
//  - 选 dlopen 而非 link-time 绑定：库 install_name 为 /usr/local/lib/...，
//    dlopen 绝对路径最稳，且符号解析失败可在启动时给出友好报错（SPEC §4.1）
//  - C++ mangled 符号名对照表直接移植自 lmx.py L94-146
//  - dylib 非线程安全：本类只负责解析符号，调用方必须把调用收敛到串行上下文
// ============================================================

/// C 事件回调原型：int cb(uint cbid, uint param, char* uuid)
public typealias LmxNotifyCallback = @convention(c) (UInt32, UInt32, UnsafeMutablePointer<CChar>?) -> Int32

// 非线程安全库，但本类只持有只读函数指针；调用串行化由 LumixCameraService actor 保证
public final class LmxLibrary: @unchecked Sendable {

    // MARK: - 函数指针类型（@convention(c)，签名以 ANALYSIS.md §3 为准）

    public typealias InitFn = @convention(c) () -> Void
    public typealias FinishFn = @convention(c) (UnsafeMutablePointer<UInt32>) -> Int32
    public typealias SearchFn = @convention(c) (UnsafeMutableRawPointer, UnsafeMutablePointer<UInt32>) -> Int32
    public typealias SelectFn = @convention(c) (UInt32, UnsafeMutableRawPointer,
                                                UnsafeMutablePointer<CChar>?, UnsafeMutablePointer<CChar>?,
                                                UnsafeMutablePointer<CChar>?, UInt16,
                                                UnsafeMutablePointer<UInt32>) -> Int32
    public typealias OpenSessionFn = @convention(c) (UInt32, UnsafeMutablePointer<UInt32>,
                                                     UnsafeMutablePointer<CChar>, UnsafeMutablePointer<UInt32>) -> Int32
    public typealias CloseDeviceFn = @convention(c) (UnsafeMutablePointer<CChar>, UnsafeMutablePointer<UInt32>) -> Int32
    public typealias RegCallbackFn = @convention(c) (UInt32, LmxNotifyCallback) -> Int32
    public typealias CaptureFn = @convention(c) (UnsafeMutablePointer<CChar>) -> Int32
    // REC_CTRL/PTP_ARRAY_STRING 是 Swift 布局结构体，@convention(c) 签名用裸指针规避 ObjC 可表示性限制
    public typealias RecCtrlReleaseFn = @convention(c) (UnsafeRawPointer, UnsafeMutablePointer<CChar>,
                                                        UnsafeMutablePointer<UInt32>) -> Int32
    public typealias LiveViewStartFn = @convention(c) (UnsafeMutablePointer<CChar>, UnsafeMutablePointer<UInt32>) -> Int32
    public typealias LiveViewStopFn = @convention(c) (UnsafeMutablePointer<CChar>, UnsafeMutablePointer<UInt32>) -> Int32
    public typealias LiveViewGetFn = @convention(c) (UnsafeMutablePointer<UInt8>, UnsafeMutablePointer<UInt32>,
                                                     UnsafeMutablePointer<CChar>, UnsafeMutablePointer<UInt32>) -> Int32
    public typealias GetFileNameFn = @convention(c) (UInt32, UnsafeMutableRawPointer,
                                                     UnsafeMutablePointer<CChar>, UnsafeMutablePointer<UInt32>) -> Int32
    public typealias GetDataSizeFn = @convention(c) (UInt32, UnsafeMutablePointer<UInt64>,
                                                     UnsafeMutablePointer<CChar>, UnsafeMutablePointer<UInt32>) -> Int32
    public typealias GetFormatFn = @convention(c) (UInt32, UnsafeMutablePointer<UInt32>,
                                                   UnsafeMutablePointer<CChar>, UnsafeMutablePointer<UInt32>) -> Int32
    public typealias GetObjectFn = @convention(c) (UInt32, UnsafeMutablePointer<UInt8>, UInt32,
                                                   UnsafeMutablePointer<CChar>, UnsafeMutablePointer<UInt32>) -> Int32
    public typealias GetStatusFn = @convention(c) (UnsafeMutablePointer<UInt16>, UnsafeMutablePointer<CChar>,
                                                   UnsafeMutablePointer<UInt32>) -> Int32

    // MARK: - 已解析符号（mangled 名抄自 lmx.py L94-146）

    public let Init: InitFn                             // _Z17LMX_func_api_Initv
    public let Finish: FinishFn                         // _Z19LMX_func_api_FinishPj
    public let SearchDevice: SearchFn                   // _Z26LMX_func_api_Search_DeviceP28_tag_LMX_CONNECT_DEVICE_INFOPj
    public let SelectPnPDevice: SelectFn                // _Z28LMX_func_api_SelectPnPDevicejP28_tag_LMX_CONNECT_DEVICE_INFOPcS1_S1_tPj
    public let OpenSession: OpenSessionFn               // _Z24LMX_func_api_OpenSessionjPjPcS_
    public let CloseDevice: CloseDeviceFn               // _Z24LMX_func_api_CloseDevicePcPj
    public let RegNotifyCallback: RegCallbackFn         // _Z31LMX_func_api_Reg_NotifyCallbackjPFijjPcE
    public let StilLCaptureSingle: CaptureFn            // _Z32LMX_func_api_StilLCapture_SinglePc
    public let RecCtrlRelease: RecCtrlReleaseFn         // _Z29LMX_func_api_Rec_Ctrl_ReleaseP24_tag_LMX_STRUCT_REC_CTRLPcPj
    public let LiveViewStart: LiveViewStartFn           // _Z32LMX_func_api_Ctrl_LiveView_StartPcPj
    public let LiveViewStop: LiveViewStopFn             // _Z31LMX_func_api_Ctrl_LiveView_StopPcPj
    public let GetLiveViewData: LiveViewGetFn           // _Z34LMX_func_api_Mnt_Get_LiveView_dataPhPjPcS0_
    public let GetObjectFileName: GetFileNameFn         // _Z32LMX_func_api_Get_Object_FileNamejP32_tag_LMX_STRUCT_PTP_ARRAY_STRINGPcPj
    public let GetObjectDataSize: GetDataSizeFn         // _Z32LMX_func_api_Get_Object_DataSizejPmPcPj
    public let GetObjectFormatType: GetFormatFn         // _Z34LMX_func_api_Get_Object_FormatTypejPjPcS_
    public let GetObject: GetObjectFn                   // _Z23LMX_func_api_Get_ObjectjPhjPcPj
    public let GetCameraStatus: GetStatusFn             // _Z28LMX_func_api_GetCameraStatusPtPcPj

    /// 实际加载的 dylib 路径（诊断日志用）
    public let path: String
    private let handle: UnsafeMutableRawPointer

    // MARK: - 加载错误

    public enum LoadError: Error, Equatable {
        /// 所有候选路径都找不到 dylib（附查找过的路径列表）
        case notFound(searched: [String])
        /// dlopen 失败（附系统错误信息）
        case openFailed(path: String, detail: String)
        /// 符号缺失（附缺失的 mangled 名列表）——说明库版本不对
        case missingSymbols([String])
    }

    // MARK: - 解析

    /// 需要的全部符号（mangled 名 → 人类可读名，报错时两个都打出来）
    public static let requiredSymbols: [(mangled: String, readable: String)] = [
        ("_Z17LMX_func_api_Initv", "LMX_func_api_Init"),
        ("_Z19LMX_func_api_FinishPj", "LMX_func_api_Finish"),
        ("_Z26LMX_func_api_Search_DeviceP28_tag_LMX_CONNECT_DEVICE_INFOPj", "LMX_func_api_Search_Device"),
        ("_Z28LMX_func_api_SelectPnPDevicejP28_tag_LMX_CONNECT_DEVICE_INFOPcS1_S1_tPj", "LMX_func_api_SelectPnPDevice"),
        ("_Z24LMX_func_api_OpenSessionjPjPcS_", "LMX_func_api_OpenSession"),
        ("_Z24LMX_func_api_CloseDevicePcPj", "LMX_func_api_CloseDevice"),
        ("_Z31LMX_func_api_Reg_NotifyCallbackjPFijjPcE", "LMX_func_api_Reg_NotifyCallback"),
        ("_Z32LMX_func_api_StilLCapture_SinglePc", "LMX_func_api_StilLCapture_Single"),
        ("_Z29LMX_func_api_Rec_Ctrl_ReleaseP24_tag_LMX_STRUCT_REC_CTRLPcPj", "LMX_func_api_Rec_Ctrl_Release"),
        ("_Z32LMX_func_api_Ctrl_LiveView_StartPcPj", "LMX_func_api_Ctrl_LiveView_Start"),
        ("_Z31LMX_func_api_Ctrl_LiveView_StopPcPj", "LMX_func_api_Ctrl_LiveView_Stop"),
        ("_Z34LMX_func_api_Mnt_Get_LiveView_dataPhPjPcS0_", "LMX_func_api_Mnt_Get_LiveView_data"),
        ("_Z32LMX_func_api_Get_Object_FileNamejP32_tag_LMX_STRUCT_PTP_ARRAY_STRINGPcPj", "LMX_func_api_Get_Object_FileName"),
        ("_Z32LMX_func_api_Get_Object_DataSizejPmPcPj", "LMX_func_api_Get_Object_DataSize"),
        ("_Z34LMX_func_api_Get_Object_FormatTypejPjPcS_", "LMX_func_api_Get_Object_FormatType"),
        ("_Z23LMX_func_api_Get_ObjectjPhjPcPj", "LMX_func_api_Get_Object"),
        ("_Z28LMX_func_api_GetCameraStatusPtPcPj", "LMX_func_api_GetCameraStatus"),
    ]

    /// dlopen 指定路径并解析全部符号；任一符号缺失则报错并列出缺失清单
    public init(path: String) throws {
        guard let h = dlopen(path, RTLD_NOW | RTLD_LOCAL) else {
            let detail = dlerror().map { String(cString: $0) } ?? "未知错误"
            throw LoadError.openFailed(path: path, detail: detail)
        }
        self.handle = h
        self.path = path

        // 先全量检查，缺符号一次性报全（方便判断库版本是否匹配）
        var missing: [String] = []
        var syms: [String: UnsafeMutableRawPointer] = [:]
        for s in LmxLibrary.requiredSymbols {
            if let p = dlsym(h, s.mangled) {
                syms[s.mangled] = p
            } else {
                missing.append("\(s.readable) (\(s.mangled))")
            }
        }
        guard missing.isEmpty else {
            dlclose(h)
            throw LoadError.missingSymbols(missing)
        }

        // dlsym 结果 → @convention(c) 函数指针
        func cast<T>(_ name: String, as type: T.Type = T.self) -> T {
            unsafeBitCast(syms[name]!, to: T.self)
        }
        self.Init = cast("_Z17LMX_func_api_Initv")
        self.Finish = cast("_Z19LMX_func_api_FinishPj")
        self.SearchDevice = cast("_Z26LMX_func_api_Search_DeviceP28_tag_LMX_CONNECT_DEVICE_INFOPj")
        self.SelectPnPDevice = cast("_Z28LMX_func_api_SelectPnPDevicejP28_tag_LMX_CONNECT_DEVICE_INFOPcS1_S1_tPj")
        self.OpenSession = cast("_Z24LMX_func_api_OpenSessionjPjPcS_")
        self.CloseDevice = cast("_Z24LMX_func_api_CloseDevicePcPj")
        self.RegNotifyCallback = cast("_Z31LMX_func_api_Reg_NotifyCallbackjPFijjPcE")
        self.StilLCaptureSingle = cast("_Z32LMX_func_api_StilLCapture_SinglePc")
        self.RecCtrlRelease = cast("_Z29LMX_func_api_Rec_Ctrl_ReleaseP24_tag_LMX_STRUCT_REC_CTRLPcPj")
        self.LiveViewStart = cast("_Z32LMX_func_api_Ctrl_LiveView_StartPcPj")
        self.LiveViewStop = cast("_Z31LMX_func_api_Ctrl_LiveView_StopPcPj")
        self.GetLiveViewData = cast("_Z34LMX_func_api_Mnt_Get_LiveView_dataPhPjPcS0_")
        self.GetObjectFileName = cast("_Z32LMX_func_api_Get_Object_FileNamejP32_tag_LMX_STRUCT_PTP_ARRAY_STRINGPcPj")
        self.GetObjectDataSize = cast("_Z32LMX_func_api_Get_Object_DataSizejPmPcPj")
        self.GetObjectFormatType = cast("_Z34LMX_func_api_Get_Object_FormatTypejPjPcS_")
        self.GetObject = cast("_Z23LMX_func_api_Get_ObjectjPhjPcPj")
        self.GetCameraStatus = cast("_Z28LMX_func_api_GetCameraStatusPtPcPj")
    }

    // 不 dlclose：函数指针可能被长生命周期 actor 持有，进程退出时由系统回收

    // MARK: - 查找顺序

    /// 按优先级解析 dylib 路径并加载：
    ///  1. 配置 camera.dylibPath 非空
    ///  2. Bundle.module 资源（CameraKit target 自带 libLmxptpif.dylib）
    ///  3. 开发兜底：<可执行文件上三级>/Sources/CameraKit/libLmxptpif.dylib
    ///  4. 开发兜底：/Users/liqiang/src/booth/Sources/CameraKit/libLmxptpif.dylib
    public static func load(configuredPath: String) throws -> LmxLibrary {
        let candidates = candidatePaths(configuredPath: configuredPath)
        var searched: [String] = []
        for path in candidates {
            searched.append(path)
            if FileManager.default.fileExists(atPath: path) {
                Log.camera.info("加载相机库: \(path)")
                return try LmxLibrary(path: path)
            }
        }
        Log.camera.error("找不到 libLmxptpif.dylib，已查找: \(searched.joined(separator: ", "))")
        throw LoadError.notFound(searched: searched)
    }

    /// 候选路径列表（供测试与诊断）
    public static func candidatePaths(configuredPath: String) -> [String] {
        var paths: [String] = []
        if !configuredPath.isEmpty { paths.append(configuredPath) }
        if let res = Bundle.module.url(forResource: "libLmxptpif", withExtension: "dylib") {
            paths.append(res.path)
        }
        // <可执行文件上三级>/Sources/CameraKit/libLmxptpif.dylib（DerivedData/.../Debug/booth → 工程根）
        if let exe = Bundle.main.executableURL {
            let devLib = exe.deletingLastPathComponent()
                .deletingLastPathComponent()
                .deletingLastPathComponent()
                .appendingPathComponent("Sources/CameraKit/libLmxptpif.dylib")
            paths.append(devLib.path)
        }
        paths.append("/Users/liqiang/src/booth/Sources/CameraKit/libLmxptpif.dylib")
        return paths
    }
}
