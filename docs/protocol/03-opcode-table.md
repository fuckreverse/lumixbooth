# 03 · Opcode 全表与命令结构

> 验证状态：**[已验证]**（全部由 `Lmx_lib_ptpif_util_Get_NextPhase_StdOpCode` @0x29b5c 位掩码解码 +
> 各 LmxExt/std 函数调用点交叉验证）

## 1. 命令统一构造结构（`_PTP_VENDOR_DATA_IN`，38 字节）`[已验证]`

所有 vendor/std 命令构造函数都填充同一个栈结构后调 `Lmx_lib_wpdif_SendCommand` @0x40160：

```c
struct _PTP_VENDOR_DATA_IN {     // 偏移=栈结构内偏移；总 0x26(38)B，ZeroMemory 0x27
    uint16_t opcode;            // +0x00
    uint8_t  pad0[4];           // +0x02
    uint32_t field06;           // +0x06  ← opcode∉{0x1001,0x1002} 且为 0 时强置 1（tid 相关）
    uint32_t param1;            // +0x0A
    uint32_t param2;            // +0x0E
    uint32_t param3;            // +0x12
    uint32_t param4;            // +0x16
    uint32_t param5;            // +0x1A
    uint16_t nParams;           // +0x1E
    uint16_t pad1;              // +0x20
    uint32_t nextPhase;         // +0x22  ← 数据阶段（见 §2）
};
```

`Bridge::sendCommand` @0xefc4 将其转换为 Apple 调用：
`operationCode=opcode`、`numberOfParameters=nParams`、`parameter1..5=param1..5`、
数据阶段 `outData` = 发送缓冲（phase 4 时）。

出参 `_PTP_VENDOR_DATA_OUT`（31 字节）：`{u16 responseCode; u32 pad; u32 tid; u32 param1..5}`。

## 2. 数据阶段（phase / NextPhase）判定表 `[已验证]`

`Get_NextPhase_StdOpCode(opcode) → phase`：
- **phase 3** = 设备→主机（命令有数据返回，需准备接收缓冲）
- **phase 4** = 主机→设备（命令带数据载荷）
- **phase 5** = 无数据阶段
- **0** = opcode 不认识（库拒绝发送）

### 2.1 标准区 0x1001-0x1025

| phase | opcode |
|-------|--------|
| 3 读数据 | 0x1001 GetDeviceInfo, 0x1004 GetStorageIDs, 0x1005 GetStorageInfo, 0x1007 GetObjectHandles, 0x1008 GetObjectInfo, 0x1009 GetObject, 0x100A GetThumb, 0x1014 GetDevicePropDesc, 0x1015 GetDevicePropValue, 0x101B GetPartialObject, 0x101E EnumHandles, 0x1020, 0x1021 |
| 5 无数据 | 0x1002 OpenSession, 0x1003 CloseSession, 0x1006 GetNumObjects, 0x100B DeleteObject, 0x100E InitiateCapture, 0x100F FormatStore, 0x1010 ResetDevice, 0x1011 SelfTest, 0x1012 SetObjectProtection, 0x1013 PowerDown, 0x1017 ResetDevicePropValue, 0x1018 TerminateOpenCapture, 0x1019 MoveObject, 0x101A CopyObject, 0x101C InitiateOpenCapture, 0x101D StartEnumHandles, 0x101F StopEnumHandles |
| 4 写数据 | 0x100C SendObjectInfo, 0x100D SendObject, 0x1016 SetDevicePropValue, 0x1022-0x1025（默认） |

> 0x101B 兼容 `GetPartialObject64`（0x101B 在新 PTP 规范是 GetPartialObject64）——Lumix 按 32 位偏移用。

### 2.2 vendor 区 0x9101-0x9123（会话/对象扩展）

| phase | opcode | 语义（调用点） |
|-------|--------|--------------|
| 3 读 | 0x9101, 0x9102* | 0x9101 [待验证]；0x9102 OpenSession（phase 表标 5，见注） |
| 5 无 | 0x9102, 0x9103, 0x910C, 0x9113, 0x9117, 0x9118 | CloseSession(0x9103)、SkipObjectTransfer(0x9113)、StartObjectRW(0x9117)、EndObjectRW(0x9118) |
| 3 读 | 0x9104, 0x9107, 0x9108, 0x9110, 0x9112, 0x9114, 0x9115 | Get_Tag_CapabilitySize(0x9107)、Get_Tag_Capability(0x9108)、ObjectInfoEx(0x9110)、GetPartialObjectEx(0x9112)、GetStorageIDs(0x9114) |
| 4 写 | 0x9116 | （表内定义；实际写操作走 0x9403/0x9415） |
| 未登记 | 0x9105, 0x9106, 0x9109, 0x910A, 0x910B, 0x910D, 0x910E, 0x910F, 0x9111, 0x9119-0x9123 区间内 | 相机固件侧可能支持，库未用 |

> *注：Get_NextPhase(0x9102)=5（无数据），`LmxExt_OpenSession` 中 phase==3 的 1MB 接收缓冲分支为
> 通用模板的死代码。实测 vendor OpenSession 无数据阶段。

### 2.3 vendor 区 0x9401-0x9423（拍摄控制/信息）

| phase | opcode | 语义 |
|-------|--------|------|
| 3 读 | 0x9401, 0x9402, 0x9408, 0x940A, 0x9414, 0x9417, 0x9421 | 0x9402=读参数组（Get_XXX_Info 系列：SS/光圈/WB/曝光/AF/闪光/RecInfo/CameraMode/Strobe/4K6K/MovFilter/SelfTimer/RecDisp/BurstBracket/LvComposite/Lens/LensZoom/LiveView_Str/SetupInfo/ImageInfo/PowerSaving…）；0x9408=Mov_Filter_Info；0x9414=GetRecInfo（按 tag 读单参数）；0x9417=Get_SetupFilesConfigSet_Info；0x9421=Get_SetupFilesConfigSetting；0x9401/0x940A [待验证] |
| 5 无 | 0x9404, 0x9405, 0x9406, 0x9407, 0x940C, 0x940D, 0x940E, 0x9410, 0x9412 | 0x9404=快门 Rec_Ctrl_Release（半按/全按）；0x9405=AF/AE；0x9406=Setup_Ctrl（菜单保存/SD格式化/传感器清洁/像素刷新/固件中止/设置重置）；0x9407=[待验证]；0x940C=Move/Filter 停止；0x940D=电源控制（关机/设备复位/重启）；0x940E=单张回放（当前/下一张/上一张）；0x9410=Rec_Ctrl_Other；0x9412=LiveView 启停 |
| 4 写 | 0x9403, 0x9409, 0x940B, 0x940F, 0x9411, 0x9415, 0x9416, 0x9418, 0x9422, 0x9423 | 0x9403=写参数（SetRecInfo/SetCameraModeInfo，param1=tag）；0x940F=回放控制（开始/停止/暂停/重启）；0x9415=SetLvTransImg（LiveView 传输尺寸）；0x9416=Rec_Ctrl_with_data/params（AF/AE 附加、WBSET、Zoom、MF_Assist、4K、AF_Area、LV_Mag、Lens、Menu、Backup_Req） |
| 未登记 | 0x9413, 0x9419, 0x941A, 0x941B, 0x941C, 0x941D, 0x941E, 0x941F, 0x9420 | 固件可能有，库未用 |

### 2.4 vendor 区 0x9601-0x9607（事件配置）

| phase | opcode | 语义 |
|-------|--------|------|
| 3 读 | 0x9601, 0x9602, 0x9605 | 0x9605=Get_Event_Info（读设备事件信息） |
| 4 写 | 0x9606, 0x9607 | [待验证] |
| 5 无 | 0x9603 | **ChgEvntType**：切换事件类型（param1=事件码 0x4002, param2=类型/开关）|
| 未登记 | 0x9604 | — |

### 2.5 vendor 区 0x9701-0x9707（Mnt/LiveView 流）

| phase | opcode | 语义 |
|-------|--------|------|
| 4 写 | 0x9701, 0x9704 | 0x9704=SetMntInfo（监控设置写入） |
| 3 读 | 0x9702, 0x9703, 0x9706, 0x9707 | 0x9703=Mnt_GetInfo（USB 模式/版本查询）；**0x9706=LiveView 流数据（Mnt_Get_StreamData/2）**；0x9702/0x9707 [待验证] |
| 5 无 | 0x9705 | Mnt_Ctrl_LiveView（MNT_CTRL 结构控制） |

## 3. 命令发送总入口 `Lmx_lib_wpdif_SendCommand` `[已验证]`

```
Lmx_lib_wpdif_SendCommand(cmd_in, send_len, send_buf, resp_out, recv_cap, recv_buf, &recv_len, uuid)
  │
  ├─ USB（ptpip 未连接）→ Bridge::getInstance() → Bridge::sendCommand()
  │     → PTPOperationRequest + dispatch_sync(queue) → Controller.send → LmxSenderThread
  │     → [ICCameraDevice requestSendPTPCommand:...]
  │
  └─ ptpip（已连接）→ Lmx_lib_ptpip_Send_Command[_And_Receive|_And_Data]
```

- 返回 `true` = 传输完成（再看 responseCode）；responseCode 0x2001/0x2016 视为成功；
- phase 3 时若 `recv_len==0` 记录调试日志 "PTP_NEXTPHASE_READ_DATA && pRcvedDataSize == 0"；
- **photobooth 重写只需 USB 分支**。

## 4. 常用命令参数速查（photobooth 最小集）

| 功能 | opcode | phase | param1 | param2 | 数据 |
|------|--------|-------|--------|--------|------|
| vendor 会话 | 0x9102 | 5 | session_id(0) | — | — |
| vendor 会话关闭 | 0x9103 | 5 | — | — | — |
| 拍一张 | 0x100E | 5 | — | — | — |
| 半按快门 | 0x9404 | 5 | REC_CTRL.param=1（按下）| | — |
| 松开快门 | 0x9404 | 5 | REC_CTRL.param=0 | | — |
| LiveView 启动 | 0x9412 | 5 | 0x0D000010 | | — |
| LiveView 停止 | 0x9412 | 5 | 0x0D000011 | | — |
| LiveView 取帧 | 0x9706 | 3 | — | — | 出：TLV 复合流 |
| 枚举对象 | 0x1007 | 3 | storageID(0=全部) | format(0=全部) | 出：u32 count + handles |
| 对象信息 | 0x1008 | 3 | handle | | 出：ObjectInfo Dataset |
| 下载对象 | 0x1009 | 3 | handle | | 出：文件全部字节 |
| 分段下载 | 0x101B | 3 | handle, offset(u32), size | | 出：size 字节 |
| 删除对象 | 0x100B | 5 | handle, format(0) | | — |
| 参数读（tag） | 0x9414 | 3 | tag（如 0x12000010 状态） | 1 | 出：REC_INFO 452B |
| 参数写（tag） | 0x9403 | 4 | tag（如 0x2000021 ISO） | 1 | 入：payload 模板（见 07） |
| 能力查询 | 0x9108 | 3 | tag | | 出：能力数组 |

> `REC_CTRL`（`_tag_LMX_STRUCT_REC_CTRL`，LmxExt_Rec_Ctrl @0x3c3f8 逆向）：
> `{u32 param; u16 n_params; u16 pad; u32 params[n]}`——param 为主命令值，params 为附加参数。
> 0x9404 时 nParams=REC_CTRL.n_params+1，params = [REC_CTRL.param, REC_CTRL.params...]。
