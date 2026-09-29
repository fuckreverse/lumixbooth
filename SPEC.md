# LUMIX Photobooth — 产品与技术规格书

> 版本：v0.1（待确认）
> 日期：2026-09-29
> 状态：需求已确认，Spec 待用户确认后进入开发

---

## 1. 产品概述

一个运行在 macOS 上的自助拍照亭（Photobooth）应用。活动现场宾客面对 Lumix 相机摆姿势，通过手势触发倒计时拍照，照片经自动修图（调色/美肤/换背景/边框）合成后，在 iPad 上预览确认并选择打印张数，由 Epson 打印机输出 6 寸照片。

- **主机**：Mac（macOS 14+，Apple Silicon 优先），运行本应用（Swift 6 + SwiftUI）
- **相机**：Panasonic Lumix S5（DC-S5），USB 连接，机身 USB 模式设为 Tether
- **打印机**：Epson L805 系列（macOS 已装驱动），默认 6 寸（4×6 英寸）无边距，默认每次打 2 张，可选 1–4 张
- **宾客确认屏**：iPad Safari 访问 Mac 的局域网地址（内嵌 HTTP/WebSocket 服务）
- **参考**：PhotoBoothProject（借鉴其状态机、collage 拼版、确认/打印/QR 工作流；代码不复用，本应用为 Swift 原生）

### 1.1 已确认的需求决策

| 项 | 决策 |
|---|---|
| 手势 | 三种全要：手势触发拍照（✌️/挥手启动倒计时）、姿势就绪检测（人站好才允许开始）、姿势引导（屏幕显示姿势示意图） |
| 自动 P 图 | 自动调色/美肤滤镜 + Vision 人像分割换背景（无需绿幕）+ 边框/相框模板叠加（Logo/日期水印）；贴纸玩法后置 |
| iPad 角色 | 成片确认屏（重拍/选张数/打印）+ 实时取景推送 + QR 码下载电子版 |
| 产物形态 | 单张直出 6 寸 与 连拍 4 张拼 6 寸大头贴条 双模式，开拍前可选 |
| 打印 | 6 寸无边距，默认 2 张，可选 1–4 张，打印走串行队列 |
| 界面语言 | 全中文 |

---

## 2. 总体架构

```
┌────────────────────────────── BoothApp (SwiftUI, macOS) ──────────────────────────────┐
│                                                                                        │
│  ┌──────────┐   ┌──────────────┐   ┌─────────────┐   ┌───────────┐   ┌─────────────┐ │
│  │ CameraKit│──▶│ SessionEngine│──▶│ ImagingKit  │──▶│ PrintKit  │   │ BoothServer │ │
│  │ 相机桥接 │   │ 流程状态机    │   │ 修图合成管线 │   │ 打印队列  │   │ 内嵌Web服务 │ │
│  └──────────┘   └──────────────┘   └─────────────┘   └───────────┘   └─────────────┘ │
│        │               │                                          (HTTP+WebSocket)    │
│        ▼               ▼                                                  │            │
│  libLmxptpif.dylib   VisionKit                                            ▼            │
│  (USB/PTP)        (手势/姿势/人像分割)                               iPad Safari       │
└────────────────────────────────────────────────────────────────────────────────────────┘
```

### 2.1 模块划分

| 模块 | 职责 | 关键技术 |
|---|---|---|
| **CameraKit** | 加载 `libLmxptpif.dylib`，封装连接生命周期、LiveView 拉流、拍摄、下载、事件回调、断线重连 | `dlopen`/C bridging，串行 actor 隔离相机线程 |
| **VisionKit** | 手势识别、姿势就绪检测、人脸/人体检测、人像分割 mask | Apple Vision 框架（本地、免费、低延迟） |
| **SessionEngine** | 拍照会话状态机（见 §3），倒计时、连拍编排、与 UI/iPad 双向同步 | Swift 结构化并发 + Combine/Observation |
| **ImagingKit** | 修图合成管线：调色美肤 → 人像分割换背景 → 边框/水印 → collage 拼版 → 输出打印规格位图 | CoreImage + CoreGraphics |
| **PrintKit** | 打印队列（串行），6 寸无边距排版，份数控制，失败重试与状态回报 | CUPS（`NSPrintOperation`/`lp`） |
| **BoothServer** | 内嵌 HTTP + WebSocket 服务：iPad 确认页、LiveView MJPEG 推送、QR 下载页、状态同步 | Hummingbird（或 SwiftNIO 手写轻量层） |
| **BoothApp** | SwiftUI 主界面：宾客大屏（取景/倒计时/姿势引导/成片）+ 操作员设置页 | SwiftUI |

依赖方向严格单向：BoothApp → SessionEngine → {CameraKit, VisionKit, ImagingKit, PrintKit, BoothServer}，模块间只通过 SessionEngine 的事件总线通信。

---

## 3. 核心流程状态机（SessionEngine）

借鉴 PhotoBoothProject 的有限状态机，扩展手势/姿势环节：

```
                        ┌──────────────────────────────────────────────┐
                        ▼                                              │
┌───────┐   ┌────────┐   ┌───────┐   ┌───────────┐   ┌─────────┐   ┌──┴───────┐
│ IDLE  │──▶│ ARMED  │──▶│GESTURE│──▶│ COUNTDOWN │──▶│ CAPTURE │──▶│PROCESSING│
│待机吸引│   │姿势就绪│   │等手势  │   │ 倒计时N秒  │   │快门+下载│   │修图合成   │
└───────┘   └────────┘   └───────┘   └───────────┘   └─────────┘   └────┬─────┘
    ▲          │ 检测不到人超时退回 IDLE     ▲                            │
    │          └─────────────────────────────┘                            ▼
    │  连拍模式: CAPTURE 完成一张后回到 COUNTDOWN，循环4次            ┌─────────┐
    │                                                              │ REVIEW  │
    │                                                              │iPad确认  │
    │                                                              └────┬────┘
    │         ┌──────────────────┬──────────────────┐                   │
    │         │重拍(回COUNTDOWN)  │确认+选张数         │超时无操作(自动确认)│
    │         ▼                  ▼                  ▼                   │
    │   ┌──────────┐      ┌───────────┐      ┌───────────┐              │
    └───┤(返回待机) │◀─────│ PRINTING  │◀─────│  PRINTING │──────────────┘
        └──────────┘      │ 打印队列   │      │ (默认2张) │
                          └───────────┘      └───────────┘
```

### 3.1 状态细则

| 状态 | 进入条件 | 行为 | 退出条件 |
|---|---|---|---|
| IDLE | 启动/上一轮结束 | 大屏播吸引页（可轮播历史成片），LiveView 保持开启，iPad 显示待机动画 | 检测到人进入取景区域 |
| ARMED | 检测到人体/人脸 | 姿势就绪检测：连续 N 帧（默认 15 帧≈0.5s）检测到人站定；大屏显示姿势引导示意图 + "比个耶开始拍照" | 就绪 → GESTURE；人离开超时（10s）→ IDLE |
| GESTURE | 姿势就绪 | 手势识别：✌️或挥手触发；屏幕实时反馈识别到手势 | 手势命中 → COUNTDOWN；超时（30s）→ IDLE |
| COUNTDOWN | 手势/触摸/键盘触发 | 大屏全屏倒计时数字（默认 3s，可配 3/5/10s），最后 1s 提示音+画面白闪模拟闪光灯 | 归零 → CAPTURE |
| CAPTURE | 倒计时结束 | `StilLCapture_Single` → 等 ObjectAdded 回调（超时 10s 报错重试 1 次）→ `Get_Object` 下载原图落盘 | 下载完成 → COUNTDOWN（连拍下一张）或 PROCESSING |
| PROCESSING | 全部拍摄完成 | ImagingKit 管线合成（见 §6），期间大屏+iPad 显示"正在修图…" | 合成完成 → REVIEW；失败降级为原图+边框 |
| REVIEW | 合成完成 | 大屏+iPad 同步显示成片；iPad 可操作：确认打印（选 1–4 张，默认 2）、重拍、扫码下载 | 确认 → PRINTING；重拍 → COUNTDOWN；超时（60s）→ 按默认 2 张自动打印 |
| PRINTING | 确认打印 | 任务入 PrintKit 串行队列；大屏/iPad 显示打印进度；完成后生成 QR 码停留 10s | 打印完成 → IDLE |

所有状态转移、倒计时读秒、拍摄进度实时经 WebSocket 推给 iPad，两端永远同屏同步。

### 3.2 拍摄模式

- **单张模式**：COUNTDOWN → CAPTURE 一次 → PROCESSING → 输出 6 寸单张（带边框/背景）
- **拼版模式**：4 次 (COUNTDOWN → CAPTURE) 循环，每次倒计时独立、间隔显示"还有 N 张" → PROCESSING 拼成 6 寸竖版大头贴条（4 格纵列 + 底部边框/Logo 区，PhotoBoothProject 经典 collage 形态）

模式在 IDLE 页由操作员或宾客点选，默认拼版模式（可在设置改默认）。

---

## 4. CameraKit — 相机连接

基于既有逆向成果（`../booth-analysis/ANALYSIS.md`、`lmx.py` 已实测全链路），Swift 直接加载 `Sources/CameraKit/libLmxptpif.dylib`。

### 4.1 加载方式

`dlopen("Sources/CameraKit/libLmxptpif.dylib", RTLD_NOW)` + `dlsym` 动态解析符号，封装为 `LmxLibrary` 单例。选 dlopen 而非 link-time 绑定的原因：库 install_name 为 `/usr/local/lib/...`，dlopen 绝对路径最稳；且符号解析失败可在启动时给出友好报错。所有 API 的 C 签名以 ANALYSIS.md §3 为准。注意导出符号是 C++ mangled 名（如 `_Z32LMX_func_api_StilLCapture_SinglePc`），`lmx.py` 第 94–146 行已有完整 mangled 名对照表，直接移植。

### 4.2 连接生命周期

```
LMX_func_api_Init()
LMX_func_api_Reg_NotifyCallback(0x10000040, onObjectAdded)   // 照片落卡
LMX_func_api_Reg_NotifyCallback(0x10000010, onDisconnect)    // 相机失联
loop: Search_Device → SelectPnPDevice(devId) → OpenSession(0, &sess, uuid)
Ctrl_LiveView_Start(uuid)
── 运行期 ──
StilLCapture_Single(uuid) → 回调收 handle → Get_Object(handle) → 落盘
── 退出 ──
Ctrl_LiveView_Stop → CloseDevice(uuid) → Finish()
```

- **线程模型**：整个 CameraKit 收敛在一个串行 `actor CameraSession` 内；LiveView 轮询在独立 Task 中 10–30fps 拉 `Mnt_Get_LiveView_data`，忙错误 `0x40004` 直接跳过等下一帧；事件回调（C 回调线程）只做一件事——把事件投递进 actor 队列。
- **断线处理**：收到 0x10000010 或任一 API 返回连接类错误 → 状态置"相机断开"，大屏提示，后台每 3s 重试 Search/Select/OpenSession，恢复后自动重启 LiveView 并回到 IDLE。
- **拍照超时**：`StilLCapture_Single` 后 10s 未收 ObjectAdded → 自动重试 1 次 → 仍失败则报错回 IDLE（记日志）。
- **多相机**：API 以 uuid 路由，架构上支持；v1 仅接一台，UI 不做多机管理。
- **前置条件**：机身 USB 模式 = Tether（README 已注明）；App 启动检测不到设备时给出引导提示。

### 4.3 相机参数

v1 不开放曝光参数调节（活动前用机身/官方 Tether 设好）；App 内只读展示电量/存储余量（`GetBatteryInfo`/`Get_StorageInfo`）于操作员页。

---

## 5. VisionKit — 手势与姿势

输入为 LiveView JPEG 帧（10–30fps 取 5–10fps 做检测即可，降采样到 720p 控耗）。

| 能力 | Vision API | 判定逻辑 |
|---|---|---|
| 姿势就绪 | `VNDetectHumanRectanglesRequest` + `VNDetectFaceRectanglesRequest` | 画面中存在人体且人脸朝向镜头、面积超过阈值，连续 15 帧成立 → 就绪 |
| 手势触发 | `VNDetectHumanHandPoseRequest`（手部 21 关键点） | ✌️（食指中指伸直、其余收拢）或挥手（手掌张开后横移）连续命中 5 帧 → 触发 |
| 人像分割 | `VNGeneratePersonSegmentationRequest`（qualityLevel=.accurate） | 仅在 PROCESSING 对成片原图跑一次，产出 matte 供换背景 |
| 姿势引导 | 无检测，纯 UI | 预设姿势示意图（PNG/SVG 素材，可换），ARMED/GESTURE 态轮播 |

全部本地推理，无网络依赖；检测开关与灵敏度（连续帧数、面积阈值）入配置。

---

## 6. ImagingKit — 修图合成管线

PROCESSING 状态执行，管线各步可独立开关（配置驱动），任一步失败降级跳过不阻断：

```
原图(JPEG, 6000×4000)
  → ① 自动调色：自动白平衡/曝光补偿/对比度（CoreImage CIAutoAdjust + 预设 LUT 滤镜）
  → ② 美肤：磨皮（高斯+蒙版保护五官边缘）+ 轻度提亮，强度 0–100 可配
  → ③ 换背景：Vision 人像分割 matte → 抠人合成到预设背景图（素材目录可选主题，无背景素材则跳过）
  → ④ 边框/水印：叠加边框 PNG 模板 + 活动 Logo + 日期文字（CoreGraphics 绘制）
  → ⑤ 排版：单张模式直接输出；拼版模式 4 图纵列拼 1200×1800（300dpi 6寸）+ 底部品牌条
  → ⑥ 输出：打印位图（1200×1800 @300dpi, sRGB, 无边距满幅）+ 展示位图（长边 1600）+ 电子版图（供 QR 下载）
```

- 素材体系：`~/Library/Application Support/Booth/themes/<主题名>/{background.png, frame.png, poses/*.png, config.json}`，App 设置页可选主题、可导入素材包；内置一套默认婚礼主题。
- 贴纸/道具贴图：需求已确认后置，管线预留插槽（④之后插入装饰层），v1 不做 UI。
- 性能预算：单张全流程 < 3s（M 系列芯片），拼版 < 6s；PROCESSING 超预算时在 UI 显示进度而非静默。

---

## 7. PrintKit — 打印

- **规格**：6 寸 = 4×6 英寸（101.6×152.4mm），无边距，300dpi → 1200×1800px；Epson L805 驱动经 CUPS 调用，纸张尺寸/无边距/介质类型在打印预设中固定，避免每次弹系统打印面板。
- **份数**：iPad 确认页选 1–4 张，默认 2 张；同一份数提交为一个打印任务循环 N 次（或 copies=N，实测驱动行为后定）。
- **队列**：全局串行队列，先进先打；队列深度展示在操作员页；打印失败（缺纸/脱机）保留任务、状态标红、操作员页可重试/清除。
- **防呆**：REVIEW 超时自动打印默认 2 张；连点确认按钮去重（同一成片 5s 内只入队一次）。

---

## 8. BoothServer — iPad 交互

Mac 与 iPad 同局域网，App 启动时拉起内嵌服务（Hummingbird），端口默认 8080，启动后大屏 IDLE 页常驻显示访问二维码（`http://<Mac局域网IP>:8080`）。

### 8.1 页面与接口

| 路由 | 说明 |
|---|---|
| `GET /` | iPad 主页面（单页应用，静态资源内嵌 App Bundle） |
| `GET /live` | LiveView MJPEG 流（multipart/x-mixed-replace，Safari 原生支持），供 iPad 实时取景 |
| `GET /photo/{id}` | 成片电子版图下载（QR 码指向此地址） |
| `WS /ws` | 状态同步通道：服务端推 `{state, countdown, photoUrl, queueInfo}`；iPad 发 `{action: confirm|retake|print, copies}` |

### 8.2 iPad 侧交互

- 待机/拍照阶段：镜像大屏状态（倒计时数字、姿势引导、"看镜头"），可选显示 LiveView（设置开关，省带宽可关）。
- REVIEW：全屏成片 + 三个操作：「打印」（张数步进器 1–4，默认 2）、「重拍」、「保存到手机」（即 /photo/{id}，Safari 长按保存）。
- PRINTING：打印进度与"请取照片"提示 + 成片 QR 码（其他宾客也可扫）。

QR 码本地生成（CoreImage `CIQRCodeGenerator`），无需外网。

---

## 9. BoothApp — 主界面

| 页面 | 内容 |
|---|---|
| 宾客大屏（默认全屏） | IDLE 吸引页（含 iPad 二维码）→ 姿势引导/手势提示 → 倒计时 → 拍照反馈 → 修图进度 → 成片展示 → 打印提示，随状态机切换 |
| 操作员页（密码可选） | 相机状态（连接/电量/存储）、打印队列、拍摄模式与倒计时秒数、修图开关与强度、主题选择、历史成片管理（重打/导出）、服务开关与端口 |
| 设置页 | 相机/打印/Vision 灵敏度/素材目录/自动打印超时秒数/默认份数 |

快捷键：空格=手动触发拍摄（手势失效兜底），R=重拍，Esc=退出全屏到操作员页。

---

## 10. 工程结构与数据

```
booth/
├── Package.swift                  # SwiftPM，多 target：BoothCore(CameraKit/VisionKit/
│                                  #   SessionEngine/ImagingKit/PrintKit/BoothServer) + BoothApp
├── Sources/...                    # 按模块分 target
├── Tests/...                      # 单测：状态机/管线合成/配置/协议（相机与打印用 mock）
├── Sources/CameraKit/libLmxptpif.dylib  # 既有，CameraKit dlopen 加载
├── lmx.py                        # 既有逆向验证脚本，开发参考
└── SPEC.md                        # 本文档
```

- **持久化**：成片与原图存 `~/Library/Application Support/Booth/sessions/<日期>/<会话id>/`（原图 NEF/JPEG + 合成图 + 电子版图 + meta.json）；配置存 UserDefaults + 主题目录如 §6。
- **日志**：os_log 分模块；打印与拍摄事件落 meta.json 备查。
- **依赖**：仅 Hummingbird 一个第三方依赖（SwiftPM）；其余全部系统框架。

---

## 11. 里程碑

| 里程碑 | 内容 | 验收 |
|---|---|---|
| M1 相机底座 | CameraKit Swift 封装：连接/重连/LiveView/拍照/下载 + 最简 SwiftUI 取景窗 | 等价 `lmx.py --lv --shot` 全链路在 App 内跑通 |
| M2 拍摄流程 | SessionEngine 状态机 + 倒计时 + 连拍 + 手势/姿势检测 + 姿势引导 UI | 大屏端到端：人站好→比耶→倒计时→连拍4张→落盘 |
| M3 修图合成 | ImagingKit 管线 + 主题素材体系 + 拼版 | 产出合格 1200×1800 打印位图（含换背景/边框） |
| M4 打印 | PrintKit + 6 寸无边距 + 份数 + 队列 | Epson 实际出片，默认 2 张，队列串行不卡 |
| M5 iPad | BoothServer + iPad 页 + MJPEG + WS 同步 + QR | iPad Safari 全流程：取景→确认→选张数→打印→扫码存图 |

M1–M2 串行；M3 与 M4 可并行；M5 依赖 M2。每个里程碑跑真机验证（S5 + Epson + iPad 三方联调）。

---

## 12. 风险与边界

1. **非公开 API**：`libLmxptpif.dylib` 为逆向所得，LUMIX Tether 升级可能变签名（已实测 v2.12 可用）；最坏情况按 ANALYSIS.md §3 已还原的 PTP opcode 自实现传输层。自用场景 License 风险低，商用需评估 EULA。
2. **LiveView 帧率**：USB 下 10–30fps，倒计时与构图足够；iPad MJPEG 转发再折半，属预期内。
3. **手势识别鲁棒性**：活动现场光线复杂，连续帧判定+手动触发兜底（空格键/点屏）；灵敏度参数留配置。
4. **无边距打印**：不同 macOS 版本对 Epson 驱动无边距预设支持有差异，M4 首个任务即为真机验证 6 寸无边距；若不达预期降级为有边距居中。
5. **打印超时自动确认**：REVIEW 60s 无操作自动打默认 2 张，可能被宾客误触发——操作员页可关闭自动打印改为只回 IDLE。

---

## 13. 明确不做（v1）

视频/GIF/boomerang；多相机管理；曝光参数 App 内调节；贴纸玩法（管线预留）；云端相册上传；Android/Windows 客户端；绿幕专用抠像（用 Vision 人像分割替代）。
