# 03 · LiveView 预览流程

> 官方预览是「命令开关 + 专线程轮询取帧」模型，与 booth 的实现同构，细节上有四处值得对齐：帧率节流算法、BUSY 处理、画质预热、以及 multiview 合成。

## 1. 组件与线程

| 组件 | 职责 | 关键函数 |
|---|---|---|
| `LiveViewManager` (LVM) | 预览编排：启停命令队列、取帧线程、multiview 画布 | `StartLive @0x1000d6418` |
| 取帧线程 | `std::thread` 跑 `LiveGetThreadFunc`，轮询 SDK 取 JPEG | `@0x1000d7a34` |
| 命令队列线程 | 处理 Start/Stop/Update 命令，200ms 节流 | `CmdQueueThreadFunc @0x1000d6324` |
| 多机位命令线程 | 逐台相机发 Ctrl_LiveView_Start/Stop，命令间 sleep 200ms | `MultiCmdThreadFunc @0x1000d8ba0` |
| `VideoAdapter` (VA) | 帧缓冲 + QTimer 节拍把 QImage 送进 QVideoSink | `SetImage @0x1000d4fdc`、`slotTick @0x1000d4bec` |

## 2. 启动序列

`LiveViewManager::StartLive` @主`0x1000d6418`（源：`decompiled/LVM_StartLive_d6418.c`）：

1. 按**分屏数**建 QImage 共享画布（单机位 640×640 起步，多机位最大 1280×1080）。
2. 构造 `vector<MULTIVIEW_PARAM>`（每机位一个：uuid、画布上的目标矩形）。
3. 起 `LiveGetThreadFunc` 的 `std::thread`。
4. 命令队列投 `1`（Start）→ `CmdQueueThreadFunc` 消费。

实际下发到相机的命令在 `MultiCmdThreadFunc` @主`0x1000d8ba0`（源：`decompiled/LVM_MultiCmdThreadFunc_d8ba0.c`）：

```c
for (auto& cam : selectedCameras) {
    LMX_func_api_Ctrl_LiveView_Start(uuid, nullptr);   // → PTP vendor 0x9412，见 05 §4.2
    sleep(200ms);                                       // 命令间隔，避免多机位同时冲击
}
```

停止路径对称：`StopLive @0x1000d57ec`、`MultiCmd_Stop @0x1000d860c`（`Ctrl_LiveView_Stop`，PTP `0x9413`）、强杀 `ForceStop @0x1000d5780`。

**画质预热**（重要，booth 未做）：`DA_getImgQualityParam @0x10004e910`（源：`decompiled/DA_getImgQualityParam_4e910.c`）在 Start 前调

```c
LMX_func_api_LiveView_Str_Get_Recom_Img(&recom, uuid, &err);   // @库0x2377c 查"推荐 LiveView 画质"
LMX_func_api_setImgQuality(...)                                  // @0x10004ddcc 设置
// multiview 模式强制 64 / 128（低画质，保证多路带宽）
```

即官方**先按相机推荐设置预览画质再开流**——这解释了官方预览帧尺寸稳定的现象。booth 目前直接 `LiveViewStart`，靠相机当前默认画质。

## 3. 取帧循环（核心）

`LiveGetThreadFunc` @主`0x1000d7a34`（源：`decompiled/LVM_LiveGetThreadFunc_d7a34.c`），单机位路径去伪存真后：

```c
uint8_t* buf = malloc(1 << 20);            // 1MB 帧缓冲
for (;;) {
    if (IsInterruptionRequested()) break;
    for (auto& cam : multiviewParams) {     // 单机位 = 1 项
        uint32_t bufsize = 0, err = 0;
        uint8_t hist[76];                   // 直方图结构 LIVEVIEW_INFO_HISTGRAM
        POSTURE posture; LEVEL level; ...   // 姿态/水平仪等 5 个附加输出结构
        int r = LMX_func_api_Get_LiveView_data(
                    hist, &histSize, &posture, &p2, &level, &p4,
                    buf, &bufsize, uuid, &err);          // 10 参数完整版 @库0x495a0
        if (r == 0) {
            if (err == 262148 /*0x40004*/) { sleep(1ms); continue; }   // BUSY：相机还没产出新帧
            // 取到帧：
            QImage img = QImage::fromData(buf, bufsize, "JPG");       // 直接按 JPEG 解码
            QPainter p(sharedCanvas);
            p.drawImage(cam.targetRect, img.scaled(...));             // 缩放绘制到共享画布
            videoAdapter->SetPaintOffset(...);
            videoAdapter->SetImage(canvasBits, w, h);                 // @0x1000d4fdc
        }
    }
    // 30fps 节流：
    elapsed = now() - t0;
    if (elapsed <= 29ms) sleep(30ms - elapsed);
    t0 = now();
}
```

要点逐条：

1. **缓冲 1MB**：单帧 LiveView JPEG 远小于此（推荐画质下 ~100-200KB），booth 的 `liveViewBufferSize`（默认 64KB 起）**偏小**，遇到高画质预览帧可能截断——官方按 1MB 分配，建议对齐。
2. **完整版 API 有 10 个参数**：直方图(76B)/姿态/水平仪等附加输出结构必须传**有效指针**（库内判空返回 `0x10000`，见 05 §4.1 反编译：`if (a1&&a2&&...&&a8)` 全判空）。booth 绑定的是 4 参数精简版 `Mnt_Get_LiveView_data @0x49388`，规避了这一坑——**保持现状即可，不要误换成 10 参数版而不传全结构**。
3. **BUSY (0x40004) 语义**：相机端尚无新帧，属正常节流信号，官方 sleep 1ms 立刻重试（不 sleep 到下一节拍）。booth 的处理（跳过本帧、等下一轮询）更省 CPU，行为等价。
4. **JPEG 起点分歧**：官方把 `buf[0..bufsize)` **原样**交给 `QImage::fromData(..., "JPG")`——即官方路径上缓冲首字节就是 JPEG SOI。booth 实测 USB 路径帧头是 PTP TLV 段（SOI 在 ~0xB4 处）后做了 SOI 扫描截取。两者不矛盾：`Mnt_Get_LiveView_data` 与 `Get_LiveView_data` 走的库内分支不同（后者是 `Mnt_Get_StreamData2` 的超集封装）。**booth 的 SOI 扫描是更鲁棒的做法，保留**。
5. **30fps 节流算法**：`elapsed ≤ 29ms → sleep(30-elapsed)ms`，即「补齐到 30ms 一轮」，而非固定 sleep 33ms。booth 的固定 33ms 会把实际帧率压到 ~30fps 且累积漂移；对齐官方算法可轻微提升流畅度。

## 4. 显示管线（VideoAdapter）

`SetImage` @主`0x1000d4fdc`：`std::recursive_mutex` 下把帧位图 memcpy 进内部缓冲（与取帧线程解耦）。
`slotTick` @主`0x1000d4bec`：QTimer 节拍 → 构造 `QVideoFrame` → `map()` → memcpy → `QVideoSink::setVideoFrame`（QML `VideoOutput` 消费）。即**取帧线程与渲染线程之间还有一个节拍器缓冲**，官方用「取帧 + 定时器」两级流水。

移植对应：booth 用 `AsyncStream<Data>.bufferingNewest(3)` 直接把 JPEG 帧推给 UI 解码，等价且更简洁，无需 QTimer 层。

## 5. 停止与异常

- 正常停止：`StopLiveAsync @0x1000d6134` → 命令队列投 `2` → 逐机位 `Ctrl_LiveView_Stop`（200ms 间隔）→ join 取帧线程。
- 异常强停：`ForceStop @0x1000d5780` 直接取消线程标志，不发 Stop 命令（相机失联场景）。
- 断线事件（0x10000010）到达时 doWork 处理器会调 ForceStop——与 booth 的 `handleConnectionLost` 一致。

## 6. 移植要点小结

1. `liveViewBufferSize` 建议提到 1MB（官方值），防高画质帧截断。
2. 节流算法改为「补齐到 33ms」，BUSY 时 1ms 快速重试可选。
3. 可选增强：Start 前经 `LiveView_Str_Get_Recom_Img` + `setImgQuality` 设定画质（符号 `@库0x2377c`，主程序包装 `@0x10004e910`），固定预览分辨率。
4. 保持 4 参数 `Mnt_Get_LiveView_data` + SOI 扫描，不要切换 10 参数版。
5. 多机位：官方同一线程串行轮询多台相机画到同一画布——如果 booth 未来要多机位，照抄该模型（一个取帧线程 + N 个 uuid 轮询）即可，无需多线程。
