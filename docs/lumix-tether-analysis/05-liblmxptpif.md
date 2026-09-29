# 05 · libLmxptpif.dylib 协议层

> 本报告是库内部（arm64，文件偏移地址）的协议级逆向，全部经 IDA MCP（127.0.0.1:13337）反编译验证。
> 库同时承载 USB（wpdif → macOS ImageCaptureCore）与 PTP/IP（Wi-Fi 直连）两条通道，`LMX_func_api_*` 层按 `LMX_ptpip_util_Get_Conn_Type() == 1` 自动分流。

## 1. 全局对象与通道选择

| 对象 | 地址 | 作用 |
|---|---|---|
| `Bridge::getInstance()` | — | USB 通道单例，内部持 `vector<tuple<string,string,int,string>>` 设备表（getDeviceList） |
| `LMX_ptpip_util_Get_Conn_Type` | @0x452f8 | 返回 0=USB / 1=PTP/IP |
| `lmx_cb_info` | @0x4a0398 | 回调表，256 槽 × 8B（运行时填充，静态映像全 0xFFFFFFFF） |
| `lmx_tbl_cbid_list` | @0x266e08 | 事件码→CBID 静态表，272 条 × 12B |
| `lmx_tbl_cbid_devprop_list` | @0x267ac8 | 设备属性族表，62 条 × 12B |
| `gLocal_usb_vid / gLocal_usb_pid` | — | 1242 (0x04DA) / 9090 (0x2382) 或 9076 |

## 2. 设备枚举（USB）

`LMX_func_api_SetSearchCondition` @0x331cc：

- 写 `gLocal_usb_vid=1242`（Panasonic），`gLocal_usb_pid=9090`（Tether 模式，type 0）/ `9076`（type 1，另一种 USB 配置态）。
- `gModelName`：按型号名过滤（空 = 不过滤）。
- PTP/IP 直连时含魔术路径 `"/PTPRemoteView"`（相机 Wi-Fi 直连服务的 PTP 路径）。

`LMX_func_api_GetPnPDeviceInfo` @0x335c4（Search_Device 的填充实现）：

```c
// USB 路径核心：
auto list = Bridge::getInstance()->getDeviceList();   // ImageCaptureCore 枚举结果
for (dev : list) {
    if (!gModelName.empty() && dev.name != gModelName) continue;
    // 填条目（stride 515 个 dword = 0x80C）：
    entry[130]        = devId;              // +520 (0x208)
    mbstowcs(model_wchar @+524, dev.name, 0x100);
    entry[387]        = modelLen;
    mbstowcs(serial_wchar @+388*4, dev.serial, ...);
    a1[2*i + 2]       = uuidPtr;            // UUID 指针表 @+8+i*8
}
```

布局与 booth `LmxDeviceInfoParser` 完全一致（详见 01 §6）。

## 3. 会话层

`LMX_func_api_OpenSession` @0x4b078 → `Lmx_lib_ptpif_LmxExt_OpenSession` @0x4b138：

- 标准 PTP `0x9102` OpenSession；调用方传 session id `0` 时库内默认 **65537 (0x10001)**。
- USB：经 `Lmx_lib_wpdif_SendCommand` 发标准 PTP 命令；PTP/IP：走 4098 分支（PTP/IP 协议命令封装）。
- 响应码映射：`0x2001 (OK)` 成功；`0x2005 (OperationNotSupported)` / `0x201E` → 错误路径。
- 相机侧句柄：`Controller send:` 按 `strcmp(handle+260, uuid)` 定位设备——这就是为什么所有 API 的 uuid 必须传 SelectPnPDevice 输出的**会话 UUID**。

## 4. Vendor 命令

### 4.1 拍照：Rec_Ctrl（opcode 0x9404）

`LMX_func_api_Rec_Ctrl_Release` @0x436f0 → `Lmx_lib_ptpif_LmxExt_Rec_Ctrl` @0x3c3f8：

```
REC_CTRL 线上布局（逆向自 0x3c3f8 的打包代码）：
  +0x00  u16  opcode   = 0x9404
  +0x02  u32  param    （如 0x3000011 单张 / 0x3000018 半按）
  +0x06  u16  n_params
  +0x08  u16  pad
  +0x0A  u32  params[n_params]
```

- `n = v6` 时 params 从 `param` 之后连续拷贝（即结构体 `_tag_LMX_STRUCT_REC_CTRL` 的 `{u32 param; u16 n; u16 pad; u32 params[16]}` 是去掉 opcode 的调用侧视图，opcode 由库补上）。
- 经 `Get_NextPhase_StdOpCode` 相位机 → `Lmx_lib_wpdif_SendCommand` 下发。
- 相机响应 `8193 (0x2001)` = OK。

⚠ booth `LmxTypes.swift` 注释写「半按用 PTP vendor opcode 0x9412」是笔误——0x9412 是 LiveView 控制的 opcode（§4.2），Rec_Ctrl 恒为 0x9404。

### 4.2 LiveView 开关（opcode 0x9412 / 0x9413）

`LMX_func_api_Ctrl_LiveView_Start` @0x49448：`LIVE_CTRL{param=0x840008}` → `Lmx_lib_ptpif_LmxExt_Ctrl_LiveView(37906=0x9412, ...)`。Stop 对称（0x9413）。

### 4.3 LiveView 取帧

`LMX_func_api_Get_LiveView_data` @0x495a0（完整版，10 参数）：

```c
int Get_LiveView_data(
    HISTGRAM* a1 /*76B 直方图*/, u32* a2,
    POSTURE* a3 /*姿态*/, u32* a4,
    LEVEL* a5 /*水平仪*/, u32* a6,
    u8* a7 /*帧缓冲*/, u32* a8 /*帧大小*/,
    char* a9 /*uuid*/, u32* a10 /*err*/);
// 判空：任一指针为 NULL → err=0x10000 返回 0
// 分流：Get_Conn_Type()==1 → ptpip 版；否则 → LmxExt_Mnt_Get_StreamData2
//      （Mnt = USB 挂载通道）
// 失败时：err==262148 (0x40004) 打 "LiveView BUSY!!"，其他打错误码
```

`LMX_func_api_Mnt_Get_LiveView_data` @0x49388（4 参数精简版，booth 绑定的就是它）：只走 USB 通道、不带附加结构输出。

### 4.4 对象访问（地址全部经 `nm -arch arm64` 实测复核）

| API | 库内地址 | 主程序包装（adp_*，运行时地址） | PTP 基础 |
|---|---|---|---|
| `Get_Object` | @0x18a48 | `adp_Get_Object @0x100071ff8` | `0x1009 GetObject` |
| `Get_Partial_Object` | @0x18b40 | `adp_Get_Partial_Object @0x100071bc0` | `0x100B GetPartialObject` |
| `Get_Partial_ObjectEx` | @0x11e18 | `adp_Get_Partial_ObjectEx @0x100071ddc` | vendor 扩展分段 |
| `Get_Object_DataSize` | @0x19064 | `adp_Get_Object_DataSize @0x1000719bc` | `0x0158 GetObjectPropValue` 族 |
| `Get_Object_FormatType` | @0x18bd0 | `adp_Get_Object_FormatType @0x1000713b0` | 同上 |
| `Get_Object_FileName` | @0x1918c | `adp_Get_Object_FileName @0x1000741a4` | Pascal 串输出 |
| `Get_Object_AssociatType` | @0x18db4 | `adp_Get_Object_AssociatType @0x1000715b4` | 关联类型（多帧合成） |
| `Get_Object_AssociatDesc` | @0x18f1c | `adp_Get_Object_AssociatDesc @0x1000717b8` | 关联描述 |
| `Get_ObjectHandleList` | @0x19470 | — | `0x1008 GetObjectHandles` |
| `StilLCapture_Single` | @0x19604 | —（官方从未调用） | 便捷封装 |

## 5. 事件与回调基础设施

（详见 02 报告，此处只列库侧地址）

| 函数 | 地址 | 作用 |
|---|---|---|
| `LMX_func_api_Reg_NotifyCallback` | @0x44450 | 注册：查 `lmx_cb_info` 256 槽，重复返回 0x20003，满返回 0x20004 |
| `Get_CBID_from_CBList` | @0x44554 | 事件码 → CBID（两张静态表，12B 条目） |
| `Send_NotifyMsg_ObjectAdd` | @0x44914 | `cb(cbid, objectHandle, uuid拷贝)` |
| `Add_CallBackInfo` | — | 挂接回调指针 |

## 6. 错误码总表（库侧已验证）

| 值 | 含义 | 出处 |
|---|---|---|
| `0x2001` | PTP OK | OpenSession / Rec_Ctrl 响应 |
| `0x2003` | 事件已注册（Reg_NotifyCallback） | @0x44450 |
| `0x2004` | 回调表满（>255） | @0x44450 |
| `0x2005` / `0x201E` | 操作不支持 / 会话错误 | OpenSession 响应映射 |
| `0x10000` | 参数为 NULL | Get_LiveView_data 判空 |
| `0x40004` (262148) | LiveView BUSY（无新帧） | @0x495a0 |
| `0x40003` | LiveView 一般错误 | booth 实测 |

## 7. 对 booth 绑定的直接影响

1. `LmxRecCtrl` 布局正确（`{u32 param; u16 n; u16 pad; u32 params[16]}`），opcode 0x9404 由库补——booth 只需把 `param=0x3000011` 填进去就能走官方单张拍照路径。
2. `LmxPTPArrayString`（`{u8 len; char s[257]; u8 flag}`）与库 `Get_Object_FileName` 输出一致。
3. `LmxBatteryInfo`（`{u32 tag; u32 size; u16 f[4]}`，tag 实测 `0x1600B0D1`）来自 `LmxExt_GetBatteryInfo_from_Buf @0x42400` 的逐字段拷贝——已验证。
4. LiveView 两符号并存的事实（完整版/精简版）见 03 §3；booth 保持精简版。
5. 会话 UUID 语义（handle+260 strcmp）解释了 booth 早期「传序列号必然失败」的坑，现有实现已正确。
