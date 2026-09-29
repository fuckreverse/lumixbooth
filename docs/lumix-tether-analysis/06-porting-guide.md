# 06 · 移植指南：官方行为 vs booth 现状

> 逐项对照 `~/src/booth` 现有实现（`Sources/CameraKit/{LumixCameraService, LmxLibrary, LmxTypes}.swift`、`lmx.py`）与官方 LUMIX Tether 的行为，给出可执行的移植建议。按优先级排列。

## E1 · 线程模型（最重要，决定稳定性）

**官方**：库调用来自多个线程（LiveView 取帧 std::thread、ObjectAdd 下载 QThread、事件消费 QThread），每次调用经 `DeviceAdapter` 的 `adp_LMX_func_api_*` 包装 + **per-device 互斥锁**串行化。C 回调（库内部线程）只入队不碰库。主线程只跑 Qt UI 循环。

**booth**：`LmxDriver.sync` 把全部库调用投递到**主线程**执行（LmxLibrary.swift L228-249 的演化注释记录了崩溃史：actor 协作线程崩 → 专用线程连接/LV 稳但拍照崩 → 主线程全稳）。根因注释指向库内 USB 通道基于 ImageCaptureCore，IC 回调投递主 runloop。

**评估与建议**：

- 官方证据表明库**可以**多线程调用（只要逐次串行），但官方是 Qt 应用——它的「主线程」跑的是 QCoreApplication 事件循环，与 IC 的 runloop 期望兼容；且官方主程序里大量 `adp_*` 实际由 QML/信号槽触发，未必真在纯 worker 线程。
- booth 的主线程模型是**唯一被 booth 自己端到端验证过**的配置，不必推翻。代价（主线程阻塞、UI 冻结）已知。
- 可选优化（风险自担）：把 LiveView 取帧与状态轮询留在主线程，但**缩短每次调用间隔**到 10ms 级（官方消费线程即 10ms 节拍），减少冻结感；或试验「专用串行线程 + 主线程保底 IC 回调」组合前先在真机做拍照压测。
- `libraryBusy`（拍照/下载期间暂停取帧与轮询）是 booth 独有的保守措施，官方不暂停。在主线程模型下保留它是合理的（下载整包期间主线程本来就被 `sync` 阻塞）。

## E2 · 拍照 API 路线

**官方**：`Rec_Ctrl_Release(REC_CTRL{param=0x3000011})` → PTP 0x9404。**从未调用** `StilLCapture_Single`。
**booth**：`StilLCapture_Single`（@库0x19604）。

**建议**：绑定已就绪（`LmxLibrary.RecCtrlRelease` + `LmxRecCtrl`），切换只需在 `capture()` 里改为：

```swift
var ctrl = LmxRecCtrl()
ctrl.param = 0x3000011          // one_shot
let r = LmxDriver.shared.sync { lib.RecCtrlRelease(&ctrl, uuid, &err) }
```

收益：与官方同路径（排障时行为可对标官方工具）；解锁半按对焦（`0x3000018`）、连拍、多机位同步拍。注意 `LmxTypes.swift` L65 的注释笔误（半按 opcode 应为 0x9404 而非 0x9412，0x9412 是 LiveView 开关）。

## E3 · LiveView 细节对齐

1. **帧缓冲 1MB**：官方按 `1<<20` 分配；booth `liveViewBufferSize` 默认偏小（64KB 起步）。JPEG 帧在推荐画质下可能超 64KB → 截断。改：`max(config.liveViewBufferSize, 1<<20)`。
2. **节流算法**：官方是「补齐到 30ms」（`elapsed≤29ms → sleep(30-elapsed)`）+ BUSY 时 1ms 快重试；booth 固定 33ms。可选对齐。
3. **画质预热**（可选）：`LiveView_Str_Get_Recom_Img @0x2377c` + `setImgQuality`，官方在开流前固定预览分辨率。要绑的话参考 `decompiled/DA_getImgQualityParam_4e910.c`。
4. 保持 4 参数 `Mnt_Get_LiveView_data` + SOI 扫描（03 §3 已论证，比官方直解更鲁棒）。

## E4 · 保存目标（fileTarget）与无卡拍摄

官方在 Select 后立刻 `setFileTargetById`，且 ObjectAdded 处理器按 `fileTarget≠1 / 无卡` 判定是否自动下载（04 §3）。photobooth 场景（插不插卡都要出货）建议：

- 若目标机型支持无卡拍摄（`registerRecWithNoSd @0x100045784` 路径，兜底名 `CARDLESS.JPG`），绑定 fileTarget 设置可让相机直接把照片推给 PC，省去 Get_Object 整包拉取；
- 最小改动版：维持现状（存卡 + ObjectAdded + Get_Object），只是把兜底文件名语义对齐 `CARDLESS`。

## E5 · RAW / 大文件下载

官方：JPEG 整包 `Get_Object`；RAW 分段 `Get_Partial_Object`（30MB 块，规则 `remaining > 29360128 ? 31457280 : remaining`，支持中断检查）。
booth：只有整包。

**建议**：photobooth 只需要 JPEG 时可不动；若拍 RAW+JPEG 双格式，需补 `Get_Partial_Object` 绑定（mangled `_Z33LMX_func_api_Get_Partial_ObjectjPhjjPcS0_`? 以 `nm -arch arm64` 实测为准：`LMX_func_api_Get_Partial_Object(unsigned int, unsigned char*, unsigned int, unsigned int, char*, unsigned int*)` @0x18b40）并在 `downloadObject` 前用 `Get_Object_FormatType` 分流。

## E6 · 事件常量勘误与增强（库内 11 个 Send_NotifyMsg 出口已逐个反编译验证）

1. `LmxTypes.swift` 的 `reqObjTransfer=0x10000100` → 真值 **`0x10000043`**（`Send_NotifyMsg_ReqObjTrnsfer @库0x44d3c` 硬编码）。当前注册了这个不存在的事件，等于从没生效。lmx.py 的 `0x0E000257/0x0E000254` 同样作废。
2. `deviceReset=0x10000001` → 真值 **`0x1FF20003`**（`Send_NotifyMsg_Device_Reset @0x44c88` 硬编码）。**当前值与 `storeRemoved` 撞值**——相机复位会被误判为拔卡。
3. `dataTransferProg=0x10000081` → 常量路径真值 **`0x11000000`**（`Send_NotifyMsg_DataTransferProgress @0x450c4` 硬编码，静态表内不存在 0x10000081）。建议双监听 `0x11000000` + `0x10000081` 实测验证。
4. `deviceStray=0x10000010`：USB 实测有效，但库内常量路径是 `0x1FF20001`（`Send_NotifyMsg_Device_Stray @0x44ba4`）——建议两个都注册监听，断线检测更稳。
5. 可选增强（替代状态轮询）：注册 devprop `0x10015001`（BatteryLevel）实测电量推送；官方 62 条 devprop 全注册。
6. 官方还注册了 `0x20000A0`（StillImageInfo）——拍照前后的静态图像信息（曝光参数回读），photobooth 打印参数叠加可用。

## E7 · 连接健壮性

1. 官方 100ms 轮询设备枚举；booth 重连用指数退避。可以在「从未连上」阶段改用 100-200ms 短轮询（`searchDevices` 开销极小），连上后维持现有逻辑。
2. 官方连接状态机（1 搜索中 / 2 连接中 / 3 已连接 + `notifyConnectErrMsg` 错误文案上抛）比 booth 的五态更贴近 UI 需要的粒度，booth 现有五态更细，无需改。
3. `OpenSession(0)` + 会话 UUID 传递：booth 与官方一致，无需动。

## E8 · 现有实现「正确性已验证」清单（不要动的部分）

- `CONNECT_DEVICE_INFO` 缓冲区布局（stride 0x80C / devId +0x208 / model +0x20C / serial +0x610 / UTF-32 wchar）——与库侧 0x335c4 反编译逐字段一致。
- `LmxPTPArrayString` / `LmxRecCtrl` / `LmxBatteryInfo` 结构布局。
- `LmxEventRouter`（回调只转发不碰库）——与官方 registerCallback 同构。
- `Mnt_Get_LiveView_data` 4 参数绑定 + SOI 扫描。
- OpenSession/SelectPnPDevice/CloseDevice 的参数与返回值处理（`0x20003` 容错）。

## 附 · 需要新增绑定的符号速查

| 符号（nm 实测） | 地址 | 用途 |
|---|---|---|
| `LMX_func_api_Get_Partial_Object(u32, u8*, u32 offset, u32 chunk, char*, u32*)` | 0x18b40 | RAW 分段下载 |
| `LMX_func_api_Get_Partial_ObjectEx(...)` | 0x11e18 | 分段扩展版 |
| `LMX_func_api_Get_Object_AssociatType(u32, u32*, char*, u32*)` | 0x18db4 | 关联类型（RAW+JPEG 判定） |
| `LMX_func_api_LiveView_Str_Get_Recom_Img(struct*, char*, u32*)` | 0x2377c | LiveView 推荐画质 |
| `LMX_func_api_Rec_Ctrl_Release(struct*, char*, u32*)` | 0x436f0 | 官方拍照路径（已绑定，待切换使用） |
| `LMX_func_api_Get_LiveView_data(10 参数)` | 0x495a0 | 完整版取帧（含直方图/姿态，暂不建议） |
