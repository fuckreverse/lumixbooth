# 09 · 去 dylib 实现路线图（Swift 原生）

> 目标：删除 `Sources/CameraKit/libLmxptpif.dylib`（6.9MB）与 `LmxLibrary.swift` 的 dlopen 绑定，
> 换成纯 Swift + ImageCaptureCore 的 PTP 客户端。协议事实见 01-07。

## 1. 可行性结论

- **USB 传输层零成本**：`ICDeviceBrowser` / `ICCameraDevice.requestSendPTPCommand` /
  `cameraDevice:didReceivePTPEvent:` 全部是 macOS 公开 API（ImageCaptureCore），
  系统 PTP 驱动替我们处理 USB Still Image Class 封包；
- 需要自写的只有：PTP 命令块序列化（~40 行）、事件解析（~30 行）、
  vendor opcode 编排（见 §3 最小集）、TLV/ Dataset 解析；
- **风险**：`PTPOperationRequest` 协议在 Swift 里实现时，`commandBuffer` 等
  只读属性桥接为 `NSData`（详见 §5 注意事项）。lmx.py 已实测全部 opcode 在 DC-S5 (v2.12 固件) 上有效。

## 2. 模块划分（建议）

```
Sources/CameraKit/
├── PTP/
│   ├── PTPBlock.swift            # Command/Response/Event 块编解码（01 §3-5）
│   ├── PTPSession.swift          # ICDeviceBrowser + ICCameraDevice 封装、tid 管理、超时
│   ├── PTPOperationRequestImpl.swift  # 实现 Apple PTPOperationRequest 协议
│   └── PTPError.swift            # responseCode → 错误映射（0x2019→busy 等）
├── Lumix/
│   ├── LumixOpcodes.swift        # opcode/tag/事件码常量表（03/04/07 的表搬进来）
│   ├── LumixCameraService.swift  # 现有接口保持：connect/liveview/capture/download
│   ├── LumixLiveView.swift       # 0x9412 启停 + 0x9706 TLV 解析（05）
│   ├── LumixObject.swift         # 0x100E/0xC128/0x1008/0x1009/0x101B（06）
│   └── LumixParams.swift         # 0x9403/0x9414 tag 参数（07）
└── MockCameraService.swift       # 保留（现成）
```

对现有 `LumixCameraService` 的调用方（SessionEngine/Vision 触发链）**接口不变**，纯内部替换。

## 3. 最小闭环序列（photobooth 必需集）

```
连接:
  ICDeviceBrowser.startBrowsing
  → didAddDevice: type==camera && canAcceptPTPCommands && (VID==0x04DA)
  → camera.requestOpenSession() → didOpenSessionWithError(nil)
  → send 0x9102 param[session_id]                # vendor 会话（可选，IC 层可能已足够，实测确认）
  → send 0x1001 (GetDeviceInfo)                  # 记录能力（可选）

预览:
  loop { send 0x9706 (读 1MB) → TLV 解析出 JPEG → Vision 流水线 }
  （0x2019 = 无新帧，直接下一轮）
  开始前: send 0x9412 param[0x0D000010]；结束后: param[0x0D000011]

拍摄:
  send 0x100E                                    # 受理
  → 事件 0xC128 (param=handle)                   # 落卡
  → send 0x1008 param[handle]                    # ObjectInfo（大小/文件名/格式）
  → send 0x1009 param[handle]                    # 全量 JPEG

健康监控（沿用现有 HealthCheck）:
  send 0x9414 param[0x12000010]                  # CameraStatus
  事件 0x10000010 系 → ICDeviceBrowser didRemoveDevice 兜底

收尾:
  send 0x9412 param[0x0D000011]                  # 停 LiveView
  send 0x9103                                    # vendor 会话关
  camera.requestCloseSession()
```

## 4. PTP 命令核心代码骨架

```swift
import ImageCaptureCore

actor PTPSession {
    private var tid: UInt32 = 1
    private var pending: [UInt32: CheckedContinuation<(PTPResponse, Data), Error>] = [:]

    func send(opcode: UInt16, params: [UInt32] = [], data: Data? = nil,
              readCap: Int = 0) async throws -> (PTPResponse, Data) {
        let myTid = tid; tid += 1
        let req = PTPOperationRequestImpl(opcode: opcode, params: params, tid: myTid)
        return try await withCheckedThrowingContinuation { cont in
            pending[myTid] = cont
            camera.requestSendPTPCommand(req.commandBuffer, outData: data as NSData?,
                sendCommandDelegate: delegate,
                didSendCommandSelector: #selector(...), contextInfo: nil)
        }
    }
    // delegate 回调: 按 response.transactionID 匹配 pending，resume
}

struct PTPOperationRequestImpl: NSObject, PTPOperationRequest {
    // commandBuffer:
    // u32(12 + 4*n) + u16(1) + u16(opcode) + u32(tid) + [u32 × n]
}
```

## 5. 注意事项与坑（按严重度排序）

1. **ICCameraDevice 会自动枚举对象**：`deviceDidBecomeReady` 后 IC 会拉全卡目录（`contentCatalog`）。
   大卡会很慢。可用 `camera.requestEnableTethering`?/设置 `capabilities` 抑制
   （查证：`ICCameraDeviceCanAcceptPTPCommands` 即可，必要时 `requestSyncClock` 跳过）——
   **实测项**：对照 libLmxptpif 是否禁用了 catalog（`deviceDidBecomeReadyWithCompleteContentCatalog` 在库里为空实现 @0x2c8c0，说明库不管 catalog）。
2. **didSendPTPCommand 的 inData 为空 vs 长度 0**：phase 3 命令返回数据在 `inData`；
   `response` 的 `parameters` 是 **u32 数组**（Apple 协议 `PTPOperationResponse` 暴露 parameter1-5）。
3. **tid 匹配**：回调里 `response.transactionID` 必须与请求匹配（库就是靠 dispatch_sync 串行化回避了并发错配；actor 串行 + tid 字典即可）。
4. **0x2019 busy 不是错误**：LiveView 轮询里静默跳过。
5. **一拍双事件**：RAW+JPEG 双落卡会产生两个 0xC128，按 ObjectFormat 过滤 JPEG（0x3801）。
6. **事件可能不跨线程**：`didReceivePTPEvent` 在 IC 的 runloop 线程，桥接到 actor 时 `nonisolated(unsafe)` 或 AsyncStream。
7. **LSUIElement/沙盒**：App 已是普通 GUI app，ICDeviceBrowser 无需额外 entitlement（USB 相机不需要 USB entitlement）。
8. **超时**：库默认 `SendCommand_TimeOutValue`（`Lmx_cfg_SendCommand_TimeOutValue_Init` @0x27228），实测 10s 量级；Swift 建议 5-10s + 一次重试。

## 6. 迁移步骤（建议顺序）

1. `PTPBlock` + `PTPOperationRequestImpl` + 最小 `send()`（硬编码 opcode 跑通 0x1001 GetDeviceInfo）——**1 天**
2. 事件管道（0xC128/0xC003/0x400D）+ tid 匹配 ——**0.5 天**
3. LiveView：0x9412 + 0x9706 + TLV → JPEG（对照现 Swift 实现的帧率/首帧延迟）——**1 天**
4. 拍摄闭环：0x100E → 事件 → 0x1008/0x1009（对照 lmx.py `capture_and_download`）——**0.5 天**
5. 状态/健康：0x9414(0x12000010) + 断线重连（didRemoveDevice → 重新 open）——**0.5 天**
6. （可选）参数：0x9403/0x9414（若 photobooth 未来要固定 ISO/光圈）——**1 天**
7. 删除 dylib + `LmxLibrary.swift`/`LmxTypes.swift` 清理，`MockCameraService` 保留 ——**0.5 天**

每步用 `MockCameraService` 并行跑现有单测（Tests/ 下 7 个 target）+ 真机冒烟。

## 7. 验证手段

- **对照 oracle**：lmx.py（ctypes 走原库）与新 Swift 实现对同一台相机逐命令比对
  （responseCode、返回字节、事件时序）；
- 抓包：`USB Prober`/虚拟端口不可用（IC 走内核驱动），退而求其次在
  `didReceivePTPEvent` 与 `didSendPTPCommand` 打点记录全双工字节流，与 lmx.py 的日志比对；
- 现有 `LumixCameraService` 接口契约（`CameraService` protocol）不变 ⇒ SessionEngine/BoothUI 零改动。
