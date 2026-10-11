# 05 · LiveView 实时取景协议

> 验证状态：**[已验证]**（`LMX_func_api_Ctrl_LiveView_Start/Stop` @0x49448/@0x494f4、
> `LmxExt_Mnt_Get_StreamData2` @0x3ccec、`LmxExt_Mnt_Get_StreamData` @0x3caa4、
> `LmxExt_SetLvTransImg` @0x3c280、`LiveView_Str_Set_Trans_Img` @0x236a0）

## 1. 协议概览

```
启动:  opcode 0x9412  param1=0x0D000010   (nParams=1, phase 5)
停止:  opcode 0x9412  param1=0x0D000011
拉流:  opcode 0x9706  (phase 3)  → 返回 TLV 复合流（JPEG + 直方图 + 姿态 + 水平仪）
设尺寸: opcode 0x9415  param1=0x0D800011  payload 16B（TRANS_IMG 结构）
备用:  opcode 0x9705  (Mnt_Ctrl_LiveView, MNT_CTRL 完整结构, phase 5)
```

## 2. 启动/停止 `[已验证]`

`LMX_func_api_Ctrl_LiveView_Start` @0x49448：

```c
// USB 路径（photobooth 场景）
bzero(mnt_ctrl, 0x808);                  // MNT_CTRL 结构 0x808 字节
mnt_ctrl[0] = 0x0D000010;                // u32 LE
LmxExt_Ctrl_LiveView(0x9412, mnt_ctrl, uuid);   // → opcode 0x9412, param1=0x0D000010, nParams=1, phase 5
```

- Stop 同款，`param1 = 0x0D000011`；
- 响应 0x2001 = 成功；0x2019 = 忙（LiveView 已在跑等场景）；
- ptpip（Wi-Fi）连接时走 `LMX_func_api_ptpip_Start_Liveview_Req`（不同路径，USB 不涉及）。

## 3. 拉流（opcode 0x9706）与 TLV 复合格式 `[已验证]`

`Mnt_Get_LiveView_data`（简化版，@0x49388 → `LmxExt_Mnt_Get_StreamData` @0x3caa4）
与 `Get_LiveView_data`（带直方图/姿态/水平仪版，@0x495a0 →
`LmxExt_Mnt_Get_StreamData2` @0x3ccec）。二者 opcode 相同，StreamData2 额外解析块。

### 3.1 命令

```
opcode=0x9706, nParams=0, phase=3（读数据）
接收缓冲: 0x100000（1MB）——实测一帧 C4K JPEG ~ 200-500KB，够用
```

### 3.2 TLV 流结构

返回数据为**顺序块**流。每块：

```
┌────────────────────────────┐
│ u32 type    （字节序见下） │  块类型
│ u32 len                     │  data 区字节数
│ u8  data[len]               │  载荷
└────────────────────────────┘
块总长（前进步长）= len + 8
```

**type 的字节序注意**（`StreamData2` 以小端 u32 读入再 switch）：

| switch 值（LE u32） | 流内字节 | 大端读法 | 含义 |
|--------------------|---------|----------|------|
| 0x17000000 | `00 00 00 17` | 0x00000017 | **跳过块**（内容忽略，仅前进） |
| 0x17000001 | `01 00 00 17` | 0x01000017 | **图像块**：data+12 处 u32 = 图像数据在**整个流**中的偏移 |
| 0x17000002 | `02 00 00 17` | 0x02000017 | **图像总长**：data+12 处 u32 = 图像总字节数 |
| 0x17000003 | `03 00 00 17` | 0x03000017 | **直方图参数**（解析成 84B dataset → HISTGRAM 结构） |
| 0x17000004 | `04 00 00 17` | 0x04000017 | **姿态（POSTURE）**：data+12 处 u16 |
| 0x17000005 | `05 00 00 17` | 0x05000017 | **水平仪（LEVEL）**：data+12 处 u32 |
| 其它 | — | — | 停止解析（默认分支） |

> 规律：块 tag 固定 `0x00000017`，第 1 字节（最高字节）为子类型 —— 相当于大端
> `[subtype, 0x00, 0x00, 0x17]`。解析时建议：`tagBE = UInt32(bigEndian: bytes)`，
> `subtype = tagBE >> 24`。

### 3.3 JPEG 帧提取算法（照抄 StreamData2）`[已验证]`

```
recv_len = 实际收到的字节数
img_offset = 图像块(0x01) data+12 的 u32
img_total  = 总长块(0x02) data+12 的 u32

copy_len = min(recv_len - img_offset, img_total - 12)
JPEG = stream[img_offset ..< img_offset + copy_len]     // 12 = 总长块的 type+len+4 头部修正
```

必须**同时出现**图像块(0x01)与总长块(0x02)才拷贝（位标志 v27 检查 bit1|bit2）。
块顺序不保证（switch 循环遍历），**先记录再拷贝**。

### 3.4 直方图块（0x03）`[已验证]`

`LmxExt_Get_LiveView_Histgram_Param_from_Buf` 解析 84 字节 → HISTGRAM 结构
（`_tag_LMX_STRUCT_LIVEVIEW_INFO_HISTGRAM`）：
- 伪代码从 dataset 的 +8/+24/+40/+56/+68 偏移拷贝 5 组 OWORD(16B) 到输出结构 ——
  即 RGB 三通道直方图 + 分布统计 `[待验证：字段语义]`；
- 输出结构容量字段 `*a4 >= 0x4C` 时才填充。

### 3.5 姿态/水平仪（0x04/0x05）`[已验证]`

- 姿态：u16（相机横竖旋转状态）；
- 水平仪：u32（倾角编码）；
- 输出容量 ≥ 2 字节才写。

### 3.6 无新帧（busy）

- 响应 0x2019 → 库错误码 **0x40004（ERR_LV_BUSY）**，返回"无帧"；
- 轮询节奏：官方 10-30fps（USB2 高画质约 10fps）；lmx.py 以 100ms 间隔轮询工作正常。

## 4. 传输尺寸设置（opcode 0x9415）`[已验证]`

`LMX_func_api_LiveView_Str_Set_Trans_Img(TRANS_IMG, uuid, &err)` @0x236a0：

```
payload（16B，phase 4 写数据）:
    u32  0x00D80011              // 参数头（tag 0x0D800011 的流内表示）
    u32  8                        // value 长度
    8B   TRANS_IMG 结构           // 传输图像尺寸/画质设置
命令: opcode=0x9415, param1=0x0D800011, nParams=1
```

- `TRANS_IMG`（`_tag_LMX_STRUCT_LIVEVIEW_STR_TRANS_IMG`）字段 `[待验证：按 DC-S5 菜单
  传输尺寸选项枚举推断，如 vga/xga/fhd]`；读取对应 `LiveView_Str_Get_Trans_Img` @0x233e4；
- `Get_LiveView_Str_Info`（0x9414 tag 体系）可查当前流配置。

## 5. ptpip LiveView（Wi-Fi，参考）

`LMX_func_api_ptpip_Get_LiveView_data` @0x2a608 —— Wi-Fi 通道的取帧走独立线程
`Lmx_lib_ptpip_Thread_Get_Liveview_Data_proc` @0xb3ac 主动推流。USB 通道无此线程。

## 6. Swift 重写要点

```swift
// 启动
sendPTP(opcode: 0x9412, params: [0x0D000010])          // phase 5
// 轮询（建议 50-100ms）
let (resp, data) = sendPTP(opcode: 0x9706, readCap: 1 << 20)
if resp == 0x2019 { return nil }                        // busy，无新帧
let frame = parseLiveViewTLV(data)                      // §3.3 算法
// 停止
sendPTP(opcode: 0x9412, params: [0x0D000011])
```

**坑位提示**：
1. JPEG 偏移是相对**整个流**的绝对偏移（不是相对图像块）；
2. `img_total - 12` 的 12 是固定修正（总长块头），不是 magic——照抄即可；
3. 0x2019 时不重试同 tid，直接下轮轮询新命令；
4. 直方图块若不需要，仍需按 len+8 前进跳过（流是紧凑的）。
