# 04 · 事件机制 —— PTP 事件码、类型切换与回调归并

> 验证状态：**[已验证]**（`-[LmxReceiverThread doReceiveEvent:fromCamera:]` @0x2b318、
> `LMX_func_api_Send_NotifyMsg_*` @0x445f4-0x450c4、`Get_CBID_from_CBList` @0x44554、
> cbid 表静态数据 dump）

## 1. 事件管道

```
相机 → USB interrupt（系统 PTP 驱动） → ImageCaptureCore
     → -[Controller cameraDevice:didReceivePTPEvent:] @0x2c850
     → LmxReceiverThread.addEvent 入队（独立线程）
     → doReceiveEvent:fromCamera: @0x2b318
        ├─ 按 eventCode 分发 relayCallback*
        └─ relayCallback* → Send_NotifyMsg_* → Get_CBID_from_CBList(cbid)
              → lmx_cb_info[] 查已注册回调 → cb(cbid, param, uuid)
```

事件块二进制格式见 01 §5（`{u32 len; u16 type=4; u16 eventCode; u32 tid; u32 params[]}`）。

## 2. PTP 事件码全表（doReceiveEvent 分发分支）`[已验证]`

| eventCode | 名称 | param1 | 转发到 |
|-----------|------|--------|--------|
| 0x4002 | ObjectAdded（标准，需先切换，见 §4） | objectHandle | relayCallback |
| 0x400D (16395) | DeviceReset | — | relayCallbackReset |
| 0xC003 (49155) | StoreAdded | storageID | relayCallbackStoreAdded |
| 0xC004 (49156) | StoreRemoved | storageID | relayCallbackStoreRemoved |
| 0xC006 (49158) | StorageInfoChanged | storageID | relayCallbackStorageInfoChanged |
| 0xC126 (49414) | 4K6K DataReady | — | relayCallback4K6KDataReady |
| 0xC127 (49415) | ChangeNotifyInfo | — | relayCallbackChangeNotifyInfo |
| **0xC128 (49416)** | **ObjectAdded（vendor 默认）** | **objectHandle** | relayCallbackObjectAdded |
| 0xC129 (49417) | RequestObjectTransfer | objectHandle | relayCallbackRequestObjectTransfer |
| 0xC201 | FirmwareUpdate 事件 | — | relayCallbackFwupEvent |
| 0xC203 | FirmwareUpdate 进度 | 百分比 | relayCallbackFwupProgress |
| 0xC204 | FirmwareUpdate 完成 | — | relayCallbackFwupCmp |
| 其它 | 通用透传 | param1 | relayCallback |

> **默认 ObjectAdded 是 vendor 码 0xC128**（photobooth 拍照闭环就靠它）。

## 3. 回调注册（Reg_NotifyCallback）`[已验证]`

```c
LMX_func_api_Reg_NotifyCallback(uint32_t api_event_id, int (*cb)(uint32_t cbid, uint32_t param, char* uuid));
```

- 注册表 `lmx_cb_info[128]`（每条 16B：{u32 pad; u32 cbid; void* fn}，共 2048B）；
- `Reg_NotifyMsg`（@0x44268）为底层版本：按内部事件码注册；
- `Init_NotifyMsg`（@0x44254）清空表。

**API 事件 ID**（= Reg_NotifyCallback 第一参数 = 回调第一参数 cbid）：

| api_event_id | 含义 | param |
|--------------|------|-------|
| 0x10000001 | DeviceReset | — |
| 0x10000010 | DeviceStray（失联/拔出） | — |
| 0x10000040 | **ObjectAdded（照片落卡）** | **objectHandle** |
| 0x10000081 | DataTransferProgress（下载进度） | 百分比 |
| 0x10000100 | RequestObjectTransfer | objectHandle |
| 0x0E000254 | StoreRemoved（拔卡） | — |
| 0x0E000257 | StoreAdded（插卡） | — |
| 0x200000xx / 0x300000xx | 参数/状态变更（ISO、光圈、电量…） | 新值 |
| 0x12000010 系 | CameraStatus 变更（GetCameraStatus 的 tag） | 状态值 |

## 4. 事件类型切换（opcode 0x9603 ChgEvntType）`[已验证]`

`LMX_func_api_Chg_ObjctAddEvent(flag, uuid, &err)` @0x45080
→ `LmxExt_ChgEvntType(0x4002, flag, uuid)` @0x44f04：

```
命令: opcode=0x9603（phase 5）
      param1 = 0x4002（要切换的 PTP 事件码）
      param2 = flag（0/1：标准 0x4002 ⇄ vendor 0xC128）
      nParams = 2
```

photobooth 建议**不切换**，直接监听 0xC128；切换后需同时监听 0x4002。

## 5. cbid 归并表 `lmx_tbl_cbid_list` `[已验证]`

- 静态表 301 条（dump：`~/src/booth-analysis/full/lmx_tbl_cbid_list.txt`），
  每条 12B：`{u32 内部事件码 a; u32 归并后 API 事件 id b; u32 flag}`；
- 语义：内部细化事件 a（如 0x01000011..0x01000016 设备状态族）归并上报为 b（0x01000010）；
  flag==1 时直接用 a 作为 cbid；
- **DeviceProp 变更**单独走 `lmx_tbl_cbid_devprop_list`（77 条）：
  `0x10015001-0x1001500E` 等统一归并为 `0x10010000`（DevicePropChanged 通知）；
- `Get_CBID_from_CBList` @0x44554：查表失败返回 0x20005（131077）。

归并关系摘要（b 值 ← a 值数量，全部见 dump 文件）：

| 归并目标 b | a 条数 | 含义（推断） |
|-----------|--------|--------------|
| 0x10010000 | 28 | DeviceProp 变更族 |
| 0x02000010 | 16 | 参数变更族 1 |
| 0x12000010 | 15 | CameraStatus 变更族 |
| 0x020001b0 / 0x02000120 / 0x02000110 / 0x020000e0 / 0x02000050 | 12-13 | 各参数组变更（ISO/SS/光圈/WB…） |
| 0x08000010 / 0x06000010 | 10-11 | 拍摄/驱动状态族 |
| 0x10000040 | 1 | ObjectAdded（直通） |
| 0x020001f0 | 11 | 4K6K 相关 |

## 6. Swift 重写要点

```swift
// 无需复刻三层线程与归并表。简化为:
func cameraDevice(_ camera: ICCameraDevice, didReceive ptpEvent: Data) {
    guard let ev = PTPEventBlock.parse(ptpEvent) else { return }
    switch ev.eventCode {
    case 0xC128: onObjectAdded(handle: ev.param1)          // 拍照闭环
    case 0xC003: onStoreAdded(ev.param1)
    case 0xC004: onStoreRemoved(ev.param1)
    case 0xC006: onStorageInfoChanged(ev.param1)
    case 0x400D: onDeviceReset()
    default: break   // photobooth 不需要其余
    }
}
```

> 可选增强：ICCameraDeviceDelegate 自带 `cameraDevice(_:didAdd items:)` 等对象级回调
> （Apple 已把 ObjectAdded 翻译成 item 变更），photobooth 可只用 PTP 事件保持与
> libLmxptpif 行为一致，便于对照调试。
