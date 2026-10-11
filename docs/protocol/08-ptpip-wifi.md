# 08 · Wi-Fi / 以太网 PTP/IP 通道（ptpip，附录用）

> 验证状态：**[已验证]**（`Lmx_lib_ptpip_*` 系列反编译：Send @0x3098、Send_Command @0xbae0、
> Init_Command_Packet @0x8ddc、Thread_Connect_Device_SendMSearch @0x6074、
> TcpTlsClient::Send/Recv @0x240a0/@0x24170、GetCertPEM @0xc40c、UpdateCer @0xc574）
>
> photobooth 走 USB，**本章可不实现**；仅当未来需要无线机位时参考。

## 1. 与 USB 通道的关系

`Lmx_lib_wpdif_SendCommand` @0x40160 按 `LMX_func_api_ptpip_Get_Connection_Type` 分流：

```
Connection_Type == 0（USB） → Bridge → ImageCaptureCore
Connection_Type != 0（ptpip）→ Lmx_lib_ptpip_Send_Command / _And_Receive / _And_Data
```

上层（LmxExt/std 命令构造、opcode、tag、事件语义）**两个通道完全共用** ——
ptpip 只是把 PTP 命令封装成 TCP 包。

## 2. 设备发现（ptpip）`[已验证]`

`LMX_func_api_ptpip_Start_Search_Device` @0x2a3d8：
- `Thread_Connect_Device_SendMSearch` @0x6074 发送 **SSDP M-SEARCH**（UDP 组播）发现相机；
- `Thread_Connect_Device_GetDDD` @0x679c / `GetDDDThreadFunc` @0x7800 拉取**设备详细描述（DDD）**；
- `LMX_func_api_ptpip_StopGetDeviceInfo` 停止；PC 侧配置：`ptpip_Set_Ip_Addr` / `Set_Pc_Name`
  （@0x2a198/@0x2a0e4，写入 `LMX_PTPIP_PC_NAME` 结构）。

## 3. 连接与握手 `[已验证]`

`Thread_Connect_Device_proc` @0x5d88：

1. TCP 连接相机（**TcpTlsClient**：OpenSSL 静态链接进 dylib，TLS 加密通道）；
2. `Init_Command_Packet` @0x8ddc + `createInitCommandRequestPacketMessage` @0x87c4
   —— 构造 **PTP/IP InitCommandRequest**（标准 PTP/IP 包：含 GUID、协议版本、PC 名称）；
3. `Init_Event_Packet` @0x9160 —— **InitEventRequest**（事件通道）；
4. `Send_And_WaitOK` @0x38fc 等待 InitCommandAck；
5. 之后命令走 `Send_Command`（命令包）→ `Send_Bin`（数据包）/ 事件线程收包。

包结构（`_tag_LMX_STRUCT_PTPIP_MESSAGE`）：标准 **ISO 15740 PTP/IP** 包头
`{u32 len; u32 packetType}` + 载荷。命令流封装 vendor 数据（`_PTP_IP_VENDOR_DATA_IN/OUT`）。

## 4. 线程模型 `[已验证]`

| 线程 | 函数 | 职责 |
|------|------|------|
| 连接 | `Thread_Connect_Device_proc` @0x5d88 | M-SEARCH → DDD → TCP → 握手 |
| 事件 | `Thread_Event_Packet_proc` @0x9608 | 事件通道收包 → relayCallback |
| 状态 | `Thread_Get_State_proc` @0x9dd8 | 状态轮询 |
| LiveView | `Thread_Get_Liveview_Data_proc` @0xb3ac | 主动推流拉帧 |
| 保活 | `Send_KeepAlive` @0x3cd4/@0x43b0 | 心跳（防相机断开） |

## 5. 证书体系 `[已验证]`

- `GetCertPEM` @0xc40c / `ptpip_GetCertPEM` @0x2a344：读取配对证书（PEM）；
- `UpdateCer` @0xc574：更新证书（配对流程产物）；
- 首次连接需**配对**（相机屏幕确认），证书持久化供后续免配对。

## 6. 与 USB 通道的行为差异

| 差异点 | USB | ptpip |
|--------|-----|-------|
| OpenSession | 仅 vendor 0x9102 | 先标准 0x1002 再 vendor 0x9102 |
| LiveView 取帧 | 0x9706 轮询 | 独立线程被动收流 |
| 事件 | IC delegate 推送 | 事件 socket 推送 |
| 保活 | 无需 | Send_KeepAlive 心跳 |
| 断线重连 | ICDeviceBrowser | DeviceReconnectWait_TH + 指数重试 |

## 7. 若要实现（无线机位）

Swift 原生：NWConnection（TLS）+ 标准 PTP/IP 包格式（ISO 15740 §C）。
GUID 用稳定 UUID（Keychain 持久化），PC 名任意。
**工作量大头在配对证书流程**（相机端确认 + 证书存储），建议先用 USB 方案上线。
