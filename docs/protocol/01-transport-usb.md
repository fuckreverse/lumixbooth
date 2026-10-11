# 01 · USB 传输层 —— ImageCaptureCore + PTP 命令块格式

> 验证状态：**[已验证]**（反编译 `Controller` / `LmxSenderThread` / `LmxReceiverThread` / `PTPOperationRequest` 等类，
> 与 lmx.py 实测 USB 联机行为一致）

## 1. 核心事实：库不自实现 USB

`libLmxptpif.dylib` 的 USB 通信 100% 建立在 macOS 系统框架 **ImageCaptureCore** 之上：

- 设备发现：`ICDeviceBrowser`（`-[Controller startBrowsing]` @0x2cab4）
- 打开会话：`-[ICCameraDevice requestOpenSession]`（`-[Controller openSession:]` @0x2d190）
- 命令发送：`-[ICCameraDevice requestSendPTPCommand:outData:sendCommandDelegate:didSendCommandSelector:contextInfo:]`
  （`-[LmxSenderThread doSendRequest]` @0x2bc6c）
- 事件接收：`-[Controller cameraDevice:didReceivePTPEvent:]` @0x2c850（ICCameraDeviceDelegate）

以上全部为 **Apple 公开 API**。也就是说：**重写传输层 = 在 Swift 里正确使用 ImageCaptureCore，
不存在任何需要逆向的 USB 底层细节**（bulk 端点、USB Still Image Class 封包等由系统驱动处理）。

## 2. 设备识别

```
VID = 0x04DA (Panasonic)      PID = 0x2382（DC-S5 USB Tether 模式）
```

- `-[Controller setVendorId:]`/`setProductionId:`（@0x2f3ec/@0x2f3fc）设置期望 VID/PID；
- `-[Controller deviceBrowser:didAddDevice:moreComing:]` @0x2bfe0 过滤条件：
  ```objc
  device.type == ICDeviceTypeCamera
  && [device.capabilities containsObject:ICCameraDeviceCanAcceptPTPCommands]
  ```
  重连场景下再比对 `usbVendorID`/`usbProductID` 与 `transportType == ICTransportTypeUSB`；
- 相机机身 USB 模式必须设为 **Tether（联机拍摄）**，否则不暴露 PTP 命令能力。

## 3. PTP 命令块格式（PTPOperationRequest 协议）`[已验证]`

发送命令时传给 `requestSendPTPCommand:` 的第一个参数是实现了 Apple
`PTPOperationRequest` 协议的对象的 `commandBuffer`（NSData）。
库的实现（`-[PTPOperationRequest commandBuffer]` @0x258ec）：

```c
struct PTPCommandBlock {          // 全部小端
    uint32_t length;              // = 12 + 4*nParams（本块总字节数）
    uint16_t type;                // = 1 (Command)
    uint16_t operationCode;       // PTP opcode（如 0x9404）
    uint32_t transactionID;       // 事务号
    uint32_t parameters[nParams]; // 每个参数固定 4 字节
};
```

- 参数**每个恒为 u32**（这是 Apple 扩展格式，不是 PTP 标准的变长参数——变长由系统驱动转换）；
- `outData` 参数 = 命令的数据阶段载荷（phase 4 写数据时非空）；
- 返回数据（phase 3 读数据）通过 delegate 回调的 `inData` 交付。

## 4. 响应块格式（PTPOperationResponse）`[已验证]`

`-[PTPOperationResponse initWithData:]` @0x25c08 解析回调数据：

```c
struct PTPResponseBlock {         // 全部小端，长度 12~0x20 字节
    uint32_t length;              // = 12 + 4*nParams
    uint16_t type;                // = 3 (Response)
    uint16_t responseCode;        // 0x2001 = OK（其余见 §7）
    uint32_t transactionID;
    uint32_t parameters[nParams]; // nParams = (length - 12) / 4
};
```

## 5. 事件块格式（PTPEvent）`[已验证]`

`-[PTPEvent initWithData:]` @0x26074：

```c
struct PTPEventBlock {            // 全部小端，长度 12~0x18 字节
    uint32_t length;              // = 12 + 4*nParams
    uint16_t type;                // = 4 (Event)
    uint16_t eventCode;           // 如 0xC128 (vendor ObjectAdded)
    uint32_t transactionID;
    uint32_t parameters[nParams]; // nParams = (length - 12) / 4
};
```

事件无主动 socket —— 由 `ICCameraDeviceDelegate.cameraDevice:didReceivePTPEvent:` 推送。

## 6. 事务号（transactionID）

- `-[Controller transactionID]` / `increaseTransactionID` / `resetTransactionID`（@0x2d500/@0x2d508/@0x2d524）；
- 每发送一条命令 `tid++`；会话建立时重置；
- 底层 `Lmx_lib_wpdif_SendCommand` @0x40160 中：opcode 为 0x1001/0x1002 时 tid 字段保持 0，其余命令若为 0 则强制置 1
  （`if ((opcode - 0x1001) > 1 && tid == 0) tid = 1;`）——**自行实现时建议从 1 开始自增**。

## 7. ResponseCode 汇总 `[已验证]`

| 码 | 名称（推断自处理分支） | 出现位置 |
|----|----------------------|----------|
| 0x2001 | OK | 所有命令 |
| 0x2002 | GeneralError | 通用 |
| 0x2005 | SessionAlreadyOpen | OpenSession @0x4b138（映射为库错误 0x41002） |
| 0x2009 | (ptpip 专用) | LmxExt_OpenSession |
| 0x201E | SessionNotOpen / AccessDenied | OpenSession（映射 0x41000） |
| 0x2019 | DeviceBusy（LiveView 无新帧） | Mnt_Get_StreamData2（映射 0x40004 busy） |
| 0x2016 | TransactionCancelled | wpdif_SendCommand（与 0x2001 同视为成功） |
| 0x2013 | (ptpip OK 变体) | wpdif_SendCommand ptpip 分支（0x2016/0x2001 同） |
| 其它 | 库错误 0x40003（LiveView 通用失败） | StreamData2 |

## 8. 同步模型与线程结构 `[已验证]`

库的发送是**同步阻塞语义**，建立在异步 IC API 之上：

```
调用线程                                LmxSenderThread(独立 NSThread)
────────                                ─────────────────────────
LmxSenderThread.startSendRequest()
  isSending=1, 启动 NSThread ──────────► doSendRequest()
  while (isSending && !isTimeout)          [camera requestSendPTPCommand:
    CFRunLoopRun()   ← 当前线程跑 runloop    ... delegate=self
  (delegate 回调在 runloop 上落地)           contextInfo:request]
                                           └─► didSendPTPCommand:inData:
                                               response:error:contextInfo:
                                                → 保存 resData/ptpResponse
                                                → isSending=0 → 停 runloop
返回 resData + PTPOperationResponse
```

- 超时看门狗：`timeCheckStart`（0.01s 后启动）+ `mach_absolute_time` 计时，超时 `isTimeout=1`；
- 超时后 `-[Controller send:sendBuf:recvBuf:response:uuid:]` @0x2d530 触发**自动重连**：
  `closeSession:` → `LmxUsbSender searchAndSendRequestsForDevices`（重新枚举）→ `openSession:` → 重试发送；
- 事件接收：`LmxReceiverThread` 独立线程 + 事件数组队列，逐条 `doReceiveEvent:fromCamera:`（见 04）。

**Swift 重写建议**：用 async/await + withCheckedContinuation 包装
`requestSendPTPCommand`，回调一次即 resume；超时用 `Task` 竞速。不需要复刻三线程结构。

## 9. Swift 直连要点（本层重写清单）

```swift
import ImageCaptureCore
import IOKit.usb

// 1. 发现
let browser = ICDeviceBrowser()
browser.delegate = self   // deviceBrowser(_:didAddDevice:moreComing:)
// 过滤: device.type == .camera, capabilities 含 ICCameraDeviceCanAcceptPTPCommands
//       usbVendorID == 0x04DA, usbProductID == 0x2382（可选加严）

// 2. 会话
camera.delegate = self
camera.requestOpenSession()      // delegate: device(_:didOpenSessionWithError:)

// 3. 发命令 —— 自己实现 PTPOperationRequest 协议
final class PTPRequest: NSObject, PTPOperationRequest {
    // 必须: operationCode, numberOfParameters, parameter1..5,
    //       transactionID, commandBuffer(只读计算属性)
}

// 4. 事件
func cameraDevice(_ camera: ICCameraDevice, didReceive ptpEvent: Data) {
    // 解析 PTPEventBlock → eventCode/params（见 04）
}
```

> 注意：`requestSendPTPCommand:outData:sendCommandDelegate:didSendCommandSelector:contextInfo:`
> 的 selector 签名为 `didSendPTPCommand:inData:response:error:contextInfo:`，
> `response` 即 `PTPOperationResponse`（系统协议），`inData` 为数据阶段返回。
