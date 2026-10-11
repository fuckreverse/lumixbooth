# LUMIX 相机联机协议逆向文档

> 目标：**甩掉 `libLmxptpif.dylib`，用 Swift 原生代码直接与 Lumix 相机（DC-S5，USB Tether 模式）通信。**
>
> 来源：LUMIX Tether v2.12 `libLmxptpif.dylib`（arm64 切片，未 strip，6117 导出符号）IDA 9.3 逆向。
> 全部结论标注来源函数地址（形如 `@0x40160`，均为 dylib arm64 文件偏移，加载基址 0）。
> 验证状态：`[已验证]` 反编译确认 + lmx.py 实测链路一致；`[推断]` 逻辑推导；`[待验证]` 需实机抓包确认。

## 核心结论（先看这个）

1. **USB 传输层不是库自实现的**。`libLmxptpif.dylib` 在 macOS 上完全依赖系统框架
   **ImageCaptureCore**（`ICDeviceBrowser` + `ICCameraDevice.requestSendPTPCommand`）收发 PTP 命令，
   事件走 `ICCameraDeviceDelegate.cameraDevice(_:didReceivePTPEvent:)`。这些是 **Apple 公开 API**。
   → 去 dylib 后 Swift 可以直接用 ImageCaptureCore，**无需写任何 USB 驱动代码**。
2. 真正需要复刻的只有三层：
   - **PTP 命令块格式**（Apple 的 `PTPOperationRequest/Response/Event` commandBuffer 序列化，很简单，见 01）；
   - **Lumix vendor 扩展 opcode 体系**（0x9101-0x9707，含 OpenSession/快门/LiveView/下载，见 02-07）；
   - **事件码 → 业务事件映射**（0xC128=ObjectAdded 等，见 04）。
3. 标准对象操作（枚举/下载/删除）走 **标准 PTP opcode**（0x1007/0x1008/0x1009/0x101B），与 PIMA 15740 一致。
4. 拍摄参数（ISO/快门/光圈/WB…）走 **tag 体系**：opcode 0x9403（写）/0x9414（读）+ 73 个参数 tag（见 07）。
5. LiveView 是 opcode 0x9412 启停 + 0x9706 轮询拉流，流为 TLV 复合格式（见 05）。

## 文档导航

| 文档 | 内容 | 层次 |
|------|------|------|
| [01-transport-usb.md](01-transport-usb.md) | USB 传输层：ImageCaptureCore 用法、PTP 命令/响应/事件块格式、transactionID、超时与重连 | 传输 |
| [02-session-lifecycle.md](02-session-lifecycle.md) | 设备发现、连接、会话建立（IC 会话 + vendor 0x9102）、DeviceInfo、USB 模式、断线重连 | 会话 |
| [03-opcode-table.md](03-opcode-table.md) | opcode 全表（标准 + vendor）、数据阶段（phase）判定表、`_PTP_VENDOR_DATA_IN/OUT` 结构 | 命令 |
| [04-events.md](04-events.md) | 事件机制：PTP 事件码、事件类型切换（0x9603）、回调注册与 cbid 归并表 | 事件 |
| [05-liveview.md](05-liveview.md) | LiveView：0x9412 启停、0x9706 TLV 流解析、JPEG 提取、直方图/姿态/水平仪、尺寸设置 0x9415 | 业务 |
| [06-capture-object.md](06-capture-object.md) | 拍摄（0x100E）、ObjectAdded、对象信息/下载/分段下载/跳过传输/句柄枚举 | 业务 |
| [07-params-tags.md](07-params-tags.md) | 拍摄参数 tag 体系全表（ISO/SS/光圈/WB/曝光/AF/闪光/PhotoStyle…）、payload 模板、能力查询、标准 DeviceProp | 业务 |
| [08-ptpip-wifi.md](08-ptpip-wifi.md) | Wi-Fi/以太网 PTP/IP 通道（ptpip）：发现、握手、TLS 证书（简要，photobooth 用 USB 可跳过） | 备用通道 |
| [09-replacement-plan.md](09-replacement-plan.md) | **Swift 去 dylib 实现路线图**：模块划分、最小闭环序列、风险清单 | 实施 |

## 协议栈全景

```
┌─────────────────────────────────────────────────────────────┐
│ LUMIX Tether.app (Qt UI)                                     │
├─────────────────────────────────────────────────────────────┤
│ libLmxptpif.dylib                                            │
│                                                              │
│  LMX_func_api_*            C++ API 层（photobooth dlopen 的）│
│    │                                                         │
│  Lmx_lib_ptpif_LmxExt_*    vendor PTP 命令构造（opcode/参数/ │
│  Lmx_lib_ptpif_std_*       数据打包）                        │
│  Lmx_lib_ptpif_util_*      opcode→phase 表、字段编解码       │
│    │                                                         │
│  Lmx_lib_wpdif_SendCommand 传输分派：USB 还是 ptpip？        │
│    │                          │                              │
│    │ USB 分支                  │ Wi-Fi 分支                   │
│    ▼                          ▼                              │
│  Bridge (C++)              Lmx_lib_ptpip_* + TcpTlsClient   │
│    │ PTPOperationRequest    （PTP over TCP/IP + OpenSSL）    │
│    ▼                                                         │
│  Controller (ObjC)          ICDeviceBrowser delegate          │
│    │ LmxSenderThread / LmxReceiverThread                     │
│    ▼                                                         │
│  ImageCaptureCore (系统框架) ← ★ 公开 API，Swift 可直接用     │
│    │ ICCameraDevice.requestSendPTPCommand / didReceivePTPEvent│
│    ▼                                                         │
│  macOS PTP USB 驱动（USB Still Image Class, bulk 端点）       │
├─────────────────────────────────────────────────────────────┤
│ 相机（Lumix DC-S5，USB Tether 模式, VID=0x04DA PID=0x2382）   │
└─────────────────────────────────────────────────────────────┘
```

## 术语速查

| 术语 | 含义 |
|------|------|
| PTP | Picture Transfer Protocol（PIMA 15740 / ISO 15740），相机联机标准协议 |
| opcode | PTP 操作码。0x1001-0x1025 标准区；0x9101+ Panasonic vendor 扩展区 |
| phase / NextPhase | 命令的数据阶段：3=设备→主机收数据，4=主机→设备发数据，5=无数据阶段 |
| tid | transactionID，PTP 事务号，每条命令自增 |
| tag | Lumix 参数标识（0x02xxxxxx/0x0D8xxxxx/0x12xxxxxx），用于读(0x9414)/写(0x9403)拍摄参数 |
| ObjectHandle | 相机内对象（照片/视频）的 32 位句柄 |
| cbid | 库向用户回调上报的事件 ID（0x10000040=ObjectAdded 等），由 PTP 事件码经归并表得到 |

## 关键常量速查

```
USB VID = 0x04DA (Panasonic)   PID = 0x2382 (DC-S5 Tether)
PTP ResponseCode OK = 0x2001
LiveView 无新帧      = 0x2019（库内转错误码 0x40004 busy）
vendor OpenSession   = 0x9102      vendor CloseSession = 0x9103
快门（半按/全按）     = 0x9404      InitiateCapture(拍一张) = 0x100E（标准）
LiveView 启/停       = 0x9412 param1=0x0D000010 / 0x0D000011
LiveView 拉流        = 0x9706
参数写/读            = 0x9403 / 0x9414（param1 = tag）
ObjectAdded 事件     = 0xC128（vendor）可切标准 0x4002（opcode 0x9603）
```

## 分析资产位置

| 资产 | 路径 |
|------|------|
| **附录数据表（本仓库内）** | [appendix/](appendix/)：参数 tag 表、payload 模板表、事件 cbid 归并表（301+77 行原始 dump）、协议相关字符串 |
| IDA 数据库（IDA 9.3） | `~/src/booth-analysis/ida/libLmxptpif_arm64.dylib.i64` |
| 全量伪代码（959 函数） | `~/src/booth-analysis/full/funcs/` |
| API 面伪代码（111 函数） | `~/src/booth-analysis/decompiled/` |
| 函数符号总表（8503） | `~/src/booth-analysis/all_funcs.txt` |
| 事件 cbid 归并表 dump | `appendix/lmx_tbl_cbid_list.txt`（301 行）、`appendix/lmx_tbl_cbid_devprop_list.txt`（77 行） |
| 参数 tag/payload 表 | `appendix/tag_table.txt`、`appendix/set_payload_table.txt` |
| 协议字符串 dump | `appendix/strings.txt` |
| ctypes 实测绑定 | `~/src/booth/lmx.py` |
| 当前 Swift 封装（待替换） | `~/src/booth/Sources/CameraKit/` |
