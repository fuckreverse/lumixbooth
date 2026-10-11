# 02 · 设备发现与会话生命周期

> 验证状态：**[已验证]**（`LMX_func_api_Init` @0x33044、`Search_Device` @0x34470、`SelectPnPDevice` @0x33c50、
> `LmxExt_OpenSession` @0x4b138、`Controller openSession:` @0x2d190 等反编译 + lmx.py 实测）

## 1. 全流程总览

```
LMX_func_api_Init()                          # ① 起后台线程 + ICDeviceBrowser.startBrowsing
  │
  ├─ Reg_NotifyCallback(event, cb)           # ② 注册关心的事件（可任意时机）
  │
LMX_func_api_Search_Device(&info)            # ③ 枚举，填 CONNECT_DEVICE_INFO
  │    ↓ 读取 Controller.deviceList（IC 层枚举结果缓存）
  │
LMX_func_api_SelectPnPDevice(devId, &info, nameOut, ...)   # ④ 选中（记录 uuid + devIndex）
  │
LMX_func_api_OpenSession(0, &sess, uuid, &err)             # ⑤ 两级会话
  │    ├─ IC 层:   [ICCameraDevice requestOpenSession]     #    （Apple 驱动内部走标准 PTP OpenSession）
  │    └─ vendor:  opcode 0x9102（USB）                     #    ptpip 时先发标准 0x1002 再发 0x9102
  │
  ├─ GetDeviceInfo(0x1001)                   # ⑥ 能力协商（opcode/事件码/属性码表）
  ├─ SetMntInfo / Mnt_GetInfo                # ⑦ USB 模式等监控设置（可选）
  │
  │   …… 命令交互（拍摄/LiveView/下载/参数）……
  │
LMX_func_api_CloseSession(uuid)              # ⑧ opcode 0x9103
LMX_func_api_CloseDevice(uuid)               # ⑨ IC requestCloseSession
LMX_func_api_Finish()                        # ⑩ browser 停止 + 线程收尾
```

## 2. 设备信息结构（CONNECT_DEVICE_INFO）`[已验证]`

`LMX_func_api_GetPnPDeviceInfo` @0x335c4 填充、主程序读取点交叉验证：

```c
struct LMX_CONNECT_DEVICE_INFO {          // 调用方分配 0x208 + 0x80C*N（N=设备数上限，库按 8~64 分配）
    uint32_t  count;                     // +0x000 设备数
    // +0x008 起：wchar_t* uuid[i]，每设备一个堆指针（UTF-32 串，缓冲 0x400 字节）
    // 设备条目 i 基址 = base + 0x208 + i*0x80C：
    //   +0x000 (即条目内 0x208 偏移处，绝对 = 0x208 + i*0x80C + 0x208？—— 见下)
};
// 每设备条目（0x80C 字节，从 0x208 开始排布）:
//   +0x000  uint32_t devId      → SelectPnPDevice 第一个参数
//   +0x004  wchar_t model[0x100]（+0x400 处 u32 有效长度）
//   +0x404  wchar_t serial[0x100]（+0x804 处 u32 有效长度）
```

实测可照抄 lmx.py `search()`：分配 `0x208 + 0x80C*8`，
`devId = *(u32*)(base + 0x208 + i*0x80C)`，`model = (wchar*)(base + 0x20C + i*0x80C)` 等。

**Swift 重写**：直接从 `ICDeviceDevice`（ICCameraDevice）取
`usbProductID`/`usbVendorID`/`serialNumberString`/`name`/`uuidString`，
本结构无需复刻（它只是库对 IC 枚举结果的缓存格式）。

## 3. vendor OpenSession（opcode 0x9102）`[已验证]`

`Lmx_lib_ptpif_LmxExt_OpenSession` @0x4b138：

```
命令: opcode=0x9102
      param1 = session_id（API 入参，默认传 0 → 常规取 0x10001？库默认调 0）
      nParams = 1
      phase = 5（无数据阶段）        ← Get_NextPhase(0x9102) = 5
响应: 0x2001 OK（SessionID 由设备分配）
      0x2005 → 库错误 0x41002 (SessionAlreadyOpen)
      0x201E → 库错误 0x41000
```

- **ptpip（Wi-Fi）连接时**先发标准 `0x1002 OpenSession`，成功后再发 `0x9102`；
- USB 连接时直接 `0x9102`（IC 层 requestOpenSession 已含标准会话）；
- `session_id` 传 API 的第一参数（官方主程序传 0，设备端从 0x10001 起分配，见 lmx.py 实测）。

## 4. GetDeviceInfo（opcode 0x1001，标准）`[已验证]`

`Lmx_lib_ptpif_std_GetDeviceInfo` @0x39e08 → 0x1001，phase 3（读数据）。
返回标准 PTP DeviceInfo Dataset（PIMA 15740 §9.4.3）：
StandardVersion / VendorExtensionID (**Panasonic = 0x0000000A**) / Operations /
Events / DeviceProps / CaptureFormats / ImageFormats / Manufacturer / Model / ...

解析函数：`std_GetDeviceInfo_sub_set_DevInfo_form_buf` @0x39f74。
便捷子 API（VendorName/ModelName/VersionInfo/SerialNo/OpCode/EventCode/DevicePropCode/
CaptureFormatCode/ImageFormatCode @0x1764c-0x17f8c）从缓存结构取值。

**用途**：连接后查询设备支持哪些 opcode（Operations 数组），photobooth 可用它探测
固件能力（如是否有 0x9706 LiveView）。

## 5. USB 模式 / Mnt 信息（0x9703 读 / 0x9704 写）`[已验证]`

| 操作 | opcode | phase | param1 | 数据 |
|------|--------|-------|--------|------|
| `Mnt_GetInfo_Get_UsbMode` @0x4acf0 | 0x9703 | 3 读 | 查询码（u32，如 -2147287038=0x80010022 一类常量） | 出参 |
| `Mnt_GetInfo_Get_Version` @0x4a9f8 | 0x9703 | 3 读 | 版本查询码 | 出参 |
| `SetMntInfo` @0x420b0 → `LmxExt_SetMntInfo` @0x3e3e4 | 0x9704 | 4 写 | 0 | MNT_SET_INFO 结构体 |

- `MNT_SET_INFO` 由调用方填（`LMX_func_api_SetMntInfo`），含 PC 名称/传输设置等 `[待验证：字段明细]`；
- **photobooth 场景**：相机菜单手工设 Tether 即可，这两个 opcode 可不实现；
  仅当需要程序化切 USB 模式时用 0x9704 写 MNT_SET_INFO（payload `[待验证]`）。

## 6. 断线检测与自动重连 `[已验证]`

三层机制：

1. **事件层**：`Send_NotifyMsg_Device_Stray`（PTP 事件 0x10000010 系）→ 上层回调"相机失联"；
2. **发送超时层**（`Controller send:...` @0x2d530）：
   `closeSession` → `LmxUsbSender(initWithPID:andVID:).searchAndSendRequestsForDevices`
   → `openSession:` → `checkConnectionStart` → 重试原命令；
3. **等待线程**：`Lmx_lib_wpdif_DeviceReconnectWait_TH` @0x37f5c 轮询设备回线。

Swift 重写：订阅 ICDeviceBrowser 的 `deviceBrowser:didRemoveDevice:moreGoing:` +
发送超时 → `requestCloseSession` → 重新 `requestOpenSession` 即可。

## 7. Keep-alive / 唤醒 `[已验证]`

- `LMX_func_api_Set_Awake_Msg` @0x2732c：设置保活消息文本（Bridge::setAwakeMsg）；
- `Lmx_lib_ptpip_Send_KeepAlive` @0x3cd4/@0x43b0（仅 ptpip 通道）；
- USB 无显式 keepalive —— ICDeviceBrowser 常驻浏览即维持热连接。
