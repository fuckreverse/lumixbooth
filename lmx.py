# -*- coding: utf-8 -*-
"""
lumix_photobooth/lmx.py — LUMIX Tether (libLmxptpif.dylib) 的 ctypes 绑定

逆向自 LUMIX Tether v2.12 (macOS, universal x86_64+arm64, 未 strip)。
所有结论来自 IDA 9.3 反编译 + 主程序 "LUMIX Tether" 调用点交叉验证。

用法（photobooth 最小闭环）：
    cam = LumixCamera()
    cam.open()              # 搜索 + 选设备 + 开会话
    cam.start_liveview()    # 预览
    cam.capture(wait=True)  # 拍照（阻塞到 ObjectAdded 事件）
    cam.download(handle)    # 下载 JPEG/RAW 到内存
"""

import ctypes
import os
import threading
import time
from ctypes import (CFUNCTYPE, POINTER, Structure, byref, c_char, c_char_p,
                    c_int, c_size_t, c_ubyte, c_uint, c_ushort, c_ulong,
                    c_void_p, c_wchar_p, create_string_buffer)

# ---------------------------------------------------------------- 常量

DYLIB = os.path.join(os.path.dirname(os.path.abspath(__file__)),
                     "lib", "libLmxptpif.dylib")

# 事件 ID（Send_NotifyMsg_* 里 Get_CBID_from_CBList() 的第一参数）
EV_OBJECT_ADDED        = 0x10000040  # 照片已落卡：cb(param=object_handle)
EV_DATA_TRANSFER_PROG  = 0x10000081  # 下载进度
EV_DEVICE_STRAY        = 0x10000010  # 相机拔出/失联
EV_DEVICE_RESET        = 0x10000001
EV_REQ_OBJ_TRANSFER    = 0x10000100  # 相机请求传输（"PC 保存"模式）
EV_STORE_ADDED         = 0x0e000257
EV_STORE_REMOVED       = 0x0e000254

# 库内已知错误码
ERR_PARAM_NULL = 0x10000     # 参数为空
ERR_LV_BUSY    = 0x40004     # LiveView 忙（正在取帧）
ERR_LV_GENERIC = 0x40003

# PTP object format（Get_Object_FormatType 返回，常见值）
FMT_JPEG_EXIF = 0x3801
FMT_RAW_ORF   = 0x3000  # Panasonic RW2 走 vendor 扩展，实际值以相机为准

# ---------------------------------------------------------------- 结构体

class REC_CTRL(Structure):
    """_tag_LMX_STRUCT_REC_CTRL — LmxExt_Rec_Ctrl 逆向：{u32 param; u16 n; u16 pad; u32 params[n]}"""
    _fields_ = [("param", c_uint),
                ("n_params", c_ushort),
                ("pad", c_ushort),
                ("params", c_uint * 16)]


class PTP_ARRAY_STRING(Structure):
    """_tag_LMX_STRUCT_PTP_ARRAY_STRING — Pascal 串：{u8 len; char s[257]; ...} 共 258+"""
    _fields_ = [("len", c_ubyte),
                ("s", c_char * 257),
                ("flag", c_ubyte)]


NOTIFY_CB = CFUNCTYPE(c_int, c_uint, c_uint, c_char_p)  # int cb(cbid, param, uuid)

# CONNECT_DEVICE_INFO 布局（GetPnPDeviceInfo 逆向 + 主程序读取点验证）：
#   +0x000               u32   设备数
#   +0x008 + i*8         wchar_t* uuid[i]   （最多 64 槽，库 malloc 的 0x400 字节 UTF-32 串）
#   每设备条目 i 基址 = i*0x80C：
#     +0x208  u32   devId（传给 SelectPnPDevice 的第一参数）
#     +0x20C  wchar model[0x100];  +0x60C u32 modelLen
#     +0x610  wchar serial[0x100]; +0xA0C u32 serialLen
DEVINFO_ENTRY_STRIDE = 0x80C
DEVINFO_MAX = 8  # 我们按最多 8 台分配


class LumixCamera:
    def __init__(self, dylib: str = DYLIB):
        self.lib = ctypes.CDLL(dylib)
        self.uuid: str | None = None        # 当前会话的相机 UUID（char* 版本）
        self._obj_added_evt = threading.Event()
        self._last_handle = 0
        self._cbrefs: list = []             # 防 GC
        self.session = 0
        self._bind()

    # ------------------------------------------------------------ 符号绑定

    def _sym(self, mangled: str):
        return getattr(self.lib, mangled)

    def _bind(self):
        L = self.lib
        # void LMX_func_api_Init(void)
        self._Init = self._sym("_Z17LMX_func_api_Initv")
        # int  LMX_func_api_Finish(uint*)
        self._Finish = self._sym("_Z19LMX_func_api_FinishPj")
        # int  LMX_func_api_Search_Device(CONNECT_INFO*, uint*)
        self._Search = self._sym("_Z26LMX_func_api_Search_DeviceP28_tag_LMX_CONNECT_DEVICE_INFOPj")
        self._Search.argtypes = [c_void_p, POINTER(c_uint)]
        self._Search.restype = c_int
        # int  SelectPnPDevice(u32 devId, CONNECT_INFO*, char* name_out, char*, char*, u16, uint*)
        self._Select = self._sym("_Z28LMX_func_api_SelectPnPDevicejP28_tag_LMX_CONNECT_DEVICE_INFOPcS1_S1_tPj")
        self._Select.argtypes = [c_uint, c_void_p, c_char_p, c_char_p, c_char_p, c_ushort, POINTER(c_uint)]
        self._Select.restype = c_int
        # int  OpenSession(uint sess_id, uint* out_sess, char* uuid, uint* err)
        self._OpenSession = self._sym("_Z24LMX_func_api_OpenSessionjPjPcS_")
        self._OpenSession.argtypes = [c_uint, POINTER(c_uint), c_char_p, POINTER(c_uint)]
        self._OpenSession.restype = c_int
        # int  CloseDevice(char* uuid, uint* err)
        self._CloseDevice = self._sym("_Z24LMX_func_api_CloseDevicePcPj")
        # int  Reg_NotifyCallback(uint event_id, int(*)(uint,uint,char*))
        self._RegCB = self._sym("_Z31LMX_func_api_Reg_NotifyCallbackjPFijjPcE")
        self._RegCB.argtypes = [c_uint, NOTIFY_CB]
        self._RegCB.restype = c_int
        # int  StilLCapture_Single(char* uuid) —— 全按快门
        self._Capture = self._sym("_Z32LMX_func_api_StilLCapture_SinglePc")
        self._Capture.argtypes = [c_char_p]
        self._Capture.restype = c_int
        # int  Rec_Ctrl_Release(REC_CTRL*, char* uuid, uint* err) —— 半按/精控
        self._Release = self._sym("_Z29LMX_func_api_Rec_Ctrl_ReleaseP24_tag_LMX_STRUCT_REC_CTRLPcPj")
        # int  Ctrl_LiveView_Start(char* uuid, uint* err) / Stop
        self._LVStart = self._sym("_Z32LMX_func_api_Ctrl_LiveView_StartPcPj")
        self._LVStart.argtypes = [c_char_p, POINTER(c_uint)]
        self._LVStart.restype = c_int
        self._LVStop = self._sym("_Z31LMX_func_api_Ctrl_LiveView_StopPcPj")
        self._LVStop.argtypes = [c_char_p, POINTER(c_uint)]
        self._LVStop.restype = c_int
        # int  Mnt_Get_LiveView_data(u8* buf, uint* size, char* uuid, uint* err) → buf=JPEG 帧
        self._LVGet = self._sym("_Z34LMX_func_api_Mnt_Get_LiveView_dataPhPjPcS0_")
        self._LVGet.argtypes = [c_void_p, POINTER(c_uint), c_char_p, POINTER(c_uint)]
        self._LVGet.restype = c_int
        # int  Get_Object_FileName(u32 handle, PTP_ARRAY_STRING*, char* uuid, uint* err)
        self._GetFileName = self._sym("_Z32LMX_func_api_Get_Object_FileNamejP32_tag_LMX_STRUCT_PTP_ARRAY_STRINGPcPj")
        # int  Get_Object_DataSize(u32 handle, uint64* size, char* uuid, uint* err)
        self._GetDataSize = self._sym("_Z32LMX_func_api_Get_Object_DataSizejPmPcPj")
        # int  Get_Object_FormatType(u32 handle, uint* fmt, char* uuid, uint* err)
        self._GetFmt = self._sym("_Z34LMX_func_api_Get_Object_FormatTypejPjPcS_")
        # int  Get_Object(u32 handle, u8* buf, uint bufsize, char* uuid, uint* err)
        self._GetObject = self._sym("_Z23LMX_func_api_Get_ObjectjPhjPcPj")
        self._GetObject.argtypes = [c_uint, c_void_p, c_uint, c_char_p, POINTER(c_uint)]
        self._GetObject.restype = c_int
        # int  Get_ObjectHandleList(u32 store, uint* count, uint* handles, char* uuid, uint* err)
        self._GetHandles = self._sym("_Z33LMX_func_api_Get_ObjectHandleListjjPjjPcS_")
        # int  GetCameraStatus(u16* status, char* uuid, uint* err)
        self._GetStatus = self._sym("_Z28LMX_func_api_GetCameraStatusPtPcPj")

    # ------------------------------------------------------------ 回调

    def _on_notify(self, cbid: int, param: int, uuid: bytes) -> int:
        if cbid == EV_OBJECT_ADDED:
            self._last_handle = param
            self._obj_added_evt.set()
        return 0

    # ------------------------------------------------------------ 生命周期

    def init(self):
        self._Init()
        cb = NOTIFY_CB(self._on_notify)
        self._cbrefs.append(cb)
        for ev in (EV_OBJECT_ADDED, EV_DEVICE_STRAY, EV_REQ_OBJ_TRANSFER):
            self._RegCB(ev, cb)

    def search(self) -> list[dict]:
        """枚举 USB 相机。返回 [{devId, uuid, model, serial}]"""
        buf = create_string_buffer(0x208 + DEVINFO_ENTRY_STRIDE * DEVINFO_MAX)
        err = c_uint(0)
        if not self._Search(buf, byref(err)):
            raise RuntimeError(f"Search_Device 失败 err=0x{err.value:x}")
        count = ctypes.cast(buf, POINTER(c_uint)).contents.value
        base = ctypes.addressof(buf)
        out = []
        for i in range(min(count, DEVINFO_MAX)):
            entry = base + DEVINFO_ENTRY_STRIDE * i
            dev_id = ctypes.cast(entry + 0x208, POINTER(c_uint)).contents.value
            uuid_p = ctypes.cast(base + 8 + 8 * i, POINTER(c_wchar_p)).contents
            model = ctypes.wstring_at(entry + 0x20C, 0x100).split("\x00")[0]
            serial = ctypes.wstring_at(entry + 0x610, 0x100).split("\x00")[0]
            out.append(dict(devId=dev_id,
                            uuid=uuid_p if isinstance(uuid_p, str) else (uuid_p or ""),
                            model=model, serial=serial))
        return out

    def open(self, index: int = 0):
        """搜索→选设备→开 PTP 会话。photobooth 单机就 index=0"""
        if not self.uuid:
            self.init()
            devs = self.search()
            if not devs:
                raise RuntimeError("未发现 LUMIX 相机（确认相机 USB 模式已设为『Tether』）")
            d = devs[index]
            info = create_string_buffer(0x208 + DEVINFO_ENTRY_STRIDE * DEVINFO_MAX)
            err = c_uint(0)
            name = create_string_buffer(512)
            # 先重新 Search 填 info，再 SelectPnPDevice
            self._Search(info, byref(err))
            if not self._Select(d["devId"], info, name, None, None, 0, byref(err)):
                raise RuntimeError(f"SelectPnPDevice 失败 err=0x{err.value:x}")
            self.uuid = d["uuid"]
        err = c_uint(0)
        sess = c_uint(0)
        if not self._OpenSession(0, byref(sess), self.uuid.encode(), byref(err)):
            raise RuntimeError(f"OpenSession 失败 err=0x{err.value:x}")
        self.session = sess.value
        return self

    def close(self):
        if self.uuid:
            err = c_uint(0)
            self._CloseDevice(self.uuid.encode(), byref(err))
            self.uuid = None

    # ------------------------------------------------------------ 预览

    def start_liveview(self):
        err = c_uint(0)
        if not self._LVStart(self.uuid.encode(), byref(err)):
            raise RuntimeError(f"LiveView Start 失败 err=0x{err.value:x}")

    def stop_liveview(self):
        err = c_uint(0)
        self._LVStop(self.uuid.encode(), byref(err))

    def liveview_frame(self, bufsize: int = 1 << 20) -> bytes | None:
        """取一帧 JPEG（约 10-30fps 轮询调用）。无新帧返回 None"""
        buf = create_string_buffer(bufsize)
        size = c_uint(0)
        err = c_uint(0)
        r = self._LVGet(buf, byref(size), self.uuid.encode(), byref(err))
        if r and size.value:
            return buf.raw[:size.value]
        if err.value == ERR_LV_BUSY:
            return None
        if err.value not in (0,):
            raise RuntimeError(f"LiveView err=0x{err.value:x}")
        return None

    # ------------------------------------------------------------ 拍摄 / 下载

    def capture(self, timeout: float = 10.0, wait: bool = True) -> int:
        """全按快门拍一张。wait=True 时阻塞到 ObjectAdded，返回新照片的 handle"""
        self._obj_added_evt.clear()
        self._last_handle = 0
        if not self._Capture(self.uuid.encode()):
            raise RuntimeError("StilLCapture_Single 失败")
        if not wait:
            return 0
        if not self._obj_added_evt.wait(timeout):
            raise TimeoutError("等待 ObjectAdded 事件超时")
        return self._last_handle

    def half_press(self, on: bool):
        """半按快门（对焦/测光）。REC_CTRL{param=1/0, n=0}"""
        c = REC_CTRL(param=1 if on else 0, n_params=0)
        err = c_uint(0)
        self._Release(byref(c), self.uuid.encode(), byref(err))

    def object_info(self, handle: int) -> dict:
        name = PTP_ARRAY_STRING()
        size = ctypes.c_ulong(0)
        fmt = c_uint(0)
        err = c_uint(0)
        u = self.uuid.encode()
        self._GetFileName(handle, byref(name), u, byref(err))
        self._GetDataSize(handle, byref(size), u, byref(err))
        self._GetFmt(handle, byref(fmt), u, byref(err))
        return dict(name=name.s[:name.len].decode(errors="replace"),
                    size=size.value, format=fmt.value)

    def download(self, handle: int) -> bytes:
        """把照片完整下载到内存（JPEG 直出给 photobooth 用）"""
        info = self.object_info(handle)
        buf = create_string_buffer(max(info["size"], 1))
        err = c_uint(0)
        if not self._GetObject(handle, buf, info["size"], self.uuid.encode(), byref(err)):
            raise RuntimeError(f"Get_Object 失败 err=0x{err.value:x}")
        return buf.raw[:info["size"]]

    def capture_and_download(self, timeout: float = 10.0) -> tuple[int, bytes, str]:
        handle = self.capture(timeout=timeout)
        data = self.download(handle)
        return handle, data, self.object_info(handle)["name"]


# ---------------------------------------------------------------- 自测

if __name__ == "__main__":
    import sys
    cam = LumixCamera()
    cam.open()
    print(f"已连接: {cam.uuid} session=0x{cam.session:x}")
    for d in cam.search():
        print("  设备:", d)
    if "--lv" in sys.argv:
        cam.start_liveview()
        for i in range(10):
            f = cam.liveview_frame()
            print(f"  LV 帧 {i}: {'%dB JPEG' % len(f) if f else 'busy'}")
            time.sleep(0.1)
        cam.stop_liveview()
    if "--shot" in sys.argv:
        h, data, name = cam.capture_and_download()
        out = os.path.join(os.path.dirname(DYLIB), "..", f"shot_{name}")
        with open(out, "wb") as f:
            f.write(data)
        print(f"已拍摄并下载: {name} ({len(data)} bytes) → {out}")
    cam.close()
