# 07 · 拍摄参数协议 —— tag 体系与 DeviceProp

> 验证状态：**[已验证]**（`LmxExt_SetRecInfo` @0x3be00、`LmxExt_GetRecInfo` @0x243dc、
> `Get_Tag_Capability` @0x1e0d0 / `Get_Tag_CapabilitySize` @0x1de88、
> 73 个 `*_Set_*` 函数 payload 提取、`direct_Get/SetDevicePropValue` @0x180b8/@0x181fc）

## 1. 两套参数体系

| 体系 | 适用 | 读 opcode | 写 opcode | 标识 |
|------|------|-----------|-----------|------|
| **tag 体系**（Lumix vendor） | ISO/快门/光圈/WB/曝光/AF/闪光/PhotoStyle…（拍摄参数） | 0x9414 | 0x9403 | tag（0x02xxxxxx / 0x0D8xxxxx / 0x12xxxxxx） |
| 标准 DeviceProp | PTP 标准属性（0x5000-0x5FFF） | 0x1015 | 0x1016 | propCode |

photobooth 场景（设 ISO/光圈/快门）全部走 **tag 体系**。

## 2. tag 读（opcode 0x9414）`[已验证]`

`Lmx_lib_ptpif_LmxExt_GetRecInfo(buf_out, tag, uuid)` @0x243dc：

```
opcode=0x9414, param1=tag, nParams=1（v23=1）, phase=3
接收缓冲: 0x1C4（452）字节 —— REC_INFO 泛型结构
```

- 各 `Get_XXX_Info` 系列（如 `GetCameraStatus` @0x249a0 → `GetRecInfo(buf, 0x12000010, uuid)`）
  从 452 字节结果中按组结构抽取字段；
- 相机组读取（0x9402）是另一种形式：param1=组 ID，返回整组结构（`_tag_LMX_STRUCT_REC_INFO` 系）。

## 3. tag 写（opcode 0x9403）`[已验证]`

`Lmx_lib_ptpif_LmxExt_SetRecInfo(payload, len, tag, uuid)` @0x3be00：

```
opcode=0x9403, param1=tag, nParams=1, phase=4
数据阶段 payload = {
    u32  head;       // 参数头（每个 tag 固定，见 §4 表；= tag 的流内表示）
    u32  value_len;  // value 字节数
    u8   value[value_len]
}
```

**payload 模板规律**（由 73 个 Set 函数批量提取验证）：
`head` 与 `value_len` 打包成一个 u64 立即数写入：
`u64 header = (u64(value_len) << 32) | head`，随后追加 value。

## 4. tag 全表（73 个，photobooth 常用加粗）`[已验证]`

> 表来源：`~/src/booth-analysis/full/set_payload_table.txt`（函数级提取）。
> `hdr` 列 = payload 前 8 字节的 u64 值（head | value_len<<32）。

| tag | 参数 | 值宽 | hdr (u64) |
|-----|------|------|-----------|
| **0x2000021** | **ISO 感光度** | u32 | 0x402000021 |
| 0x2000022 | ISO 上限 | u32 | 0x402000022 |
| 0x2000025 | ISO Gain 值 | u16 | 0x202000025 |
| **0x2000031** | **快门速度** | u32 | 0x402000031 |
| 0x2000032 | 快门范围限制 | u64 | 0x802000032 |
| 0x2000033 | 快门 Cfg | u16 | 0x202000033 |
| 0x2000034 | 快门 StAngle | u16 | 0x202000034 |
| **0x2000041** | **光圈 F 值** | u16 | 0x202000041 |
| 0x2000042 | 光圈范围限制 | u32 | 0x402000042 |
| **0x2000051** | **白平衡模式** | u16 | 0x202000051 |
| 0x2000052 | WB 色温 K | u16 | 0x202000052 |
| 0x2000053 | WB ADJ A-B | u16 | 0x202000053 |
| 0x2000054 | WB ADJ G-M | u16 | 0x202000054 |
| 0x2000055 | WB ADJ A-B 分离 | u16 | 0x202000055 |
| **0x2000061** | **曝光补偿** | u16 | 0x202000061 |
| 0x2000062 | 曝光范围限制 | u32 | 0x402000062 |
| 0x2000071 | AF 模式 | u16 | 0x202000071 |
| 0x2000072 | AF 区域 | u16 | 0x202000072 |
| 0x2000073 | Quick AF | u16 | 0x202000073 |
| 0x2000074 | AF 区域自定义 | u16 | 0x202000074 |
| 0x2000075-0x2000078 | AF 识别（动物/模式/自动/部位） | u16 | 0x20200007x |
| 0x20000E1-0x20000ED | 拍摄显示（直方图模式/位置、网格、斑马纹、峰值、高亮） | u16/u32 | 0x2020000Ex（E2/E4 为 u32） |
| 0x2000111-0x200011B | 闪光（模式/红眼/调光/同步/手动/无线 Ch/FP/ComPower） | u16 | 0x20200011x |
| 0x2000121-0x2000128 | AF/MF（模式/MF辅助/指南/定点/LV放大/PinP） | u16 | 0x20200012x |
| 0x2000141 | 连拍/包围 | u16 | 0x202000141 |
| 0x2000171-0x2000173 | 回放预览（自动预览/常预览/监视器显示） | u16 | 0x20200017x |
| 0x20001A1-0x20001A2 | 自拍定时器 | u16 | 0x2020001Ax |
| 0x20001C1-0x20001C2 | 4K6K（录制格式/对焦选择） | u16 | 0x2020001Cx |
| 0x20001D4 | AF 框架（多 AF 框） | 0x13D 字节 | 0x13D020001D4 |
| 0x20001D8 | AF 单点人脸尺寸 | u16 | 0x2020001D8 |
| 0x20001F1-0x20001FA | PhotoStyle2（双原生 ISO/色彩噪声/LUT/Gain/Base/DENSITY…） | u16 | 0x2020001Fx |

**非 0x02 前缀 tag**（读侧为主）：

| tag | 用途 |
|-----|------|
| 0x12000010 | CameraStatus（`GetCameraStatus` @0x249a0 → GetRecInfo） |
| 0x0D800011 | LiveView 传输尺寸（0x9415，见 05 §4） |

## 5. 值编码 `[推断]`（读侧未逐 tag 抓包）

- value_len=2 → u16 枚举/索引（多数参数）；=4 → u32（ISO 精确值/范围对）；=8 → u64（范围对 min/max）；
- 枚举值与机身菜单序号的映射（如 ISO 0x50=AUTO?）**[待验证：需实机读回对照]**——
  建议实现时先 `0x9414` 读当前值 + `0x9108` 查能力表对照；
- 能力查询：`Get_Tag_CapabilitySize`（0x9107，返回能力数据大小）+
  `Get_Tag_Capability`（0x9108，返回该 tag 的可选值数组），
  `LMX_func_api_GetEventTag` @0x2862c 亦走 0x9414。

## 6. 标准 DeviceProp（0x1014/0x1015/0x1016）`[已验证]`

`LMX_func_api_direct_Get/SetDevicePropValue` @0x180b8/@0x181fc（propCode 限 0x5000-0x5FFE）：

```
读: opcode=0x1015, param1=propCode, phase=3 → 值（类型由 Get_DataTye_StdDevPropCode(propCode) 决定）
写: opcode=0x1016, param1=propCode, phase=4 → 值
描述: opcode=0x1014, param1=propCode, phase=3 → DevicePropDesc Dataset
```

DC-S5 的实际可用 propCode 集合以 `GetDeviceInfo`(0x1001) 的 DeviceProps 数组为准
`[待验证：S5 暴露的标准属性清单]`。

## 7. 参数组读取（opcode 0x9402）`[已验证]`

`Get_XXX_Info` 系列走 0x9402（phase 3，param1=组 ID，如 CameraModeInfo/SS_Info/Aperture_Info/
Exposure_Info/BurstBracket/SelfTimer/Mov_Filter/4K6K/Lv_Composite/LensInfo/LensZoomInfo/
SetupInfo/PowerSaving/Strobe/AFMF_Cfg2/RecDisp/RecPreview/ImageInfo/RecInfo）——
一次读**整组**参数。photobooth 只需单参数读写（0x9414/0x9403）时可不实现。

## 8. Swift 重写要点

```swift
func setParam(tag: UInt32, value: Data) async throws {
    var payload = Data()
    payload.appendLE(UInt32(head32(tag)))      // head 常量，照 §4 表
    payload.appendLE(UInt32(value.count))
    payload.append(value)
    _ = try await send(opcode: 0x9403, params: [tag], data: payload)   // phase 4
}

func getParam(tag: UInt32) async throws -> Data {
    let (_, data) = try await sendRead(opcode: 0x9414, params: [tag], cap: 452)  // phase 3
    return data
}

// 例：设 ISO
try await setParam(tag: 0x2000021, value: packLE(UInt32(400)))
// 例：设光圈 F4（枚举值需先能力查询）
let caps = try await sendRead(opcode: 0x9108, params: [0x2000041], cap: 1024)
```

**坑位提示**：
1. payload 的 `head` 与 `tag` 是**两个不同常量**（tag 0x2000021 ↔ head 0x20000021），照表抄；
2. 枚举型参数值域因机型/模式而异，**先读当前值再写**（设置失败返回非 0x2001 时读回对照）；
3. 参数变更后相机会推 0x200000xx 系事件（见 04 §5 归并表），可用于确认写入生效。
