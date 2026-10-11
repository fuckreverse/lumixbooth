# 06 · 拍摄与对象（照片）传输协议

> 验证状态：**[已验证]**（`STD_StillCapture` @0x3bb4c、`LmxExt_GetObject` @0x3b874、
> `LmxExt_GetPartialObject` @0x3b9ec、`LmxExt_GetObjectInfo` @0x3b3c4、
> `std_GetObjectHandles` @0x3a2f0、`GetObjectInfoEx` @0x1159c、`GetPartialObjectEx` @0x11a84、
> `SkipObjectTransfer` @0x11bec、`StartObjectRW/EndObjectRW` @0x3edf4/@0x3ef54、
> `Save_ObjectData_to_File` @0x498b4）

## 1. 拍摄闭环全景

```
① opcode 0x100E InitiateCapture (nParams=0, phase 5)
② 相机落卡 → PTP 事件 0xC128 ObjectAdded, param1 = objectHandle
③ 0x1008 GetObjectInfo(handle)   → 文件名/大小/格式（可选，Ex 版更全）
④ 0x1009 GetObject(handle)       → 全量 JPEG/RW2 字节
   或 0x101B GetPartialObject(handle, off, len) → 分段
⑤ （可选）0x100B DeleteObject(handle, 0)
```

## 2. 拍摄（opcode 0x100E）`[已验证]`

`LMX_func_api_StilLCapture_Single` @0x19604 → `Lmx_lib_ptpif_STD_StillCapture` @0x3bb4c：

```
opcode=0x100E, nParams=0, phase=5（无数据、无参数）
响应 0x2001 = 命令受理（照片异步落卡，真正的完成信号是 0xC128 事件）
```

- 官方库准备 0x444(1092) 字节缓冲仅为通用模板（phase 3 分支），实际 phase 5 不带数据；
- 半按对焦：opcode **0x9404**（REC_CTRL.param=1 按下 / 0 松开，见 03 §4）；
- 连拍/精控走 0x9405（AF/AE）、0x9410（Other）、0x9416（带数据控制），photobooth 不需要。

## 3. ObjectAdded 事件 `[已验证]`

见 04 §2：eventCode **0xC128**，param1 = 新对象的 objectHandle（u32）。
回调链最终给用户 `(cbid=0x10000040, param=handle, uuid)`。

> 实测（lmx.py）：`StilLCapture_Single` 发出后 1-4 秒内收到 0xC128。

## 4. 对象信息

### 4.1 标准 ObjectInfo（opcode 0x1008）`[已验证]`

`LMX_func_api_Get_ObjectInfo` @0x18898 → `LmxExt_GetObjectInfo` @0x3b3c4 → 0x1008：

```
opcode=0x1008, param1=handle, phase=3
返回: 标准 PTP ObjectInfo Dataset（PIMA 15740 §C.7）:
    u32 StorageID; u16 ObjectFormat; u16 ProtectionStatus;
    u32 ObjectCompressedSize; u16 ThumbFormat; u32 ThumbCompressedSize;
    u32 ThumbPixWidth; u32 ThumbPixHeight; u32 ImagePixWidth; u32 ImagePixHeight;
    u32 ImageBitDepth; PTPSTRING Filename; PTPSTRING CaptureDate; PTPSTRING ModificationDate; u32 Keywords
（PTPSTRING = u8 字节长度 + UTF-16LE 内容，长度 0xFF 表示空）
```

便捷读取 API 的字段提取：`Get_Object_FileName`（0x1008 结果缓存取 filename）、
`Get_Object_DataSize`、`Get_Object_FormatType`——均为**纯本地解析**（不发新命令，读 0x1008 的缓存）。

### 4.2 vendor ObjectInfoEx（opcode 0x9110）`[已验证]`

`LMX_func_api_Get_ObjectInfoEx` @0x11d38 → `LmxExt_GetObjectInfoEx` @0x1159c：

```
opcode=0x9110, param1=handle, phase=3
返回: OBJECTINFO_EX dataset（扩展字段：拍摄参数、日期细节等）[待验证: 字段布局]
```

## 5. 下载

### 5.1 全量下载（opcode 0x1009）`[已验证]`

```
opcode=0x1009, param1=handle, phase=3
返回: 对象全部字节（JPEG: 0x3801 格式 / RW2: vendor 格式码）
缓冲: 先 0x1008 拿 ObjectCompressedSize 再分配
```

### 5.2 分段下载（opcode 0x101B GetPartialObject）`[已验证]`

`LMX_func_api_Get_Partial_Object` @0x18b40 → `LmxExt_GetPartialObject` @0x3b9ec：

```
opcode=0x101B, param1=handle, param2=offset(u32), param3=len, phase=3
返回: len 字节
```

官方 `Save_ObjectData_to_File` @0x498b4 的下载线程即**循环 0x101B 分块拉取** +
进度上报（DataTransferProgress 0x10000081，param=百分比）。
photobooth 内存下载用 0x1009 一步到位更简单；文件落盘/超大数据用 0x101B 分块。

### 5.3 vendor GetPartialObjectEx（opcode 0x9112）`[已验证]`

```
opcode=0x9112, param1=handle, param2=offset, param3=len（64 位版本语义 [待验证]）, phase=3
```

### 5.4 跳过传输（opcode 0x9113）`[已验证]`

`Skip_Object_Transfer`：通知相机放弃当前传输事务（用于断点/取消）。

## 6. 对象枚举与存储

### 6.1 枚举句柄（opcode 0x1007）`[已验证]`

`LMX_func_api_Get_ObjectHandleList` @0x19470 → `std_GetObjectHandles` @0x3a2f0：

```
opcode=0x1007, param1=storageID(0=所有存储), param2=format(0=所有格式), param3=handleAssoc(0=根), phase=3
返回: u32 count + count 个 u32 handles
```

`Get_ObjectNum`（0x1006 GetNumObjects，param 同上）只取数量。

### 6.2 存储

| 操作 | opcode | 说明 |
|------|--------|------|
| StorageIDs | 0x1004（标准）/ 0x9114（vendor Ex @0x3ae88） | u32 数组 |
| StorageInfo | 0x1005 | 存储类型/容量/剩余（`Get_StorageInfo` @0x1936c，`GetFreeSpaceInSec` @0x2489c） |

## 7. 删除与读写事务 `[已验证]`

- 删除：0x100B（param1=handle, param2=formatOfObject 0）`std_DeleteObject` @0x3eb14；
- `StartObjectRW`（0x9117）/ `EndObjectRW`（0x9118）：进入/退出"对象读写模式"
  （疑似挂载式访问，photobooth 不需要）。

## 8. Swift 重写要点（photobooth 拍摄→下载闭环）

```swift
// 拍照
try await send(opcode: 0x100E)                       // phase 5
// 等事件
let handle = try await waitForEvent(0xC128)          // async stream
// 信息
let info = try await sendRead(opcode: 0x1008, params: [handle])
    .map(parseObjectInfo)                            // 标准 Dataset 解析
// 下载
let jpeg = try await sendRead(opcode: 0x1009, params: [handle], cap: info.size)
```

**坑位提示**：
1. RAW+JPEG 双格式时，一次拍摄产生**两个 ObjectAdded**（两个 handle，ObjectFormat 区分 0x3801 JPEG / RW2 vendor 码）；
2. `Get_Object_FileName/DataSize/FormatType` 在库里是本地缓存解析——自实现时直接解析 0x1008 返回的 Dataset；
3. 0x1009 的接收缓冲要 ≥ ObjectCompressedSize（先查信息再下载）；
4. 大文件（RAW 40MB+）IC 层自动分 USB 包，无需干预。
