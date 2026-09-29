# 拍照流程与状态机

> 核心实现在 [Sources/SessionEngine/SessionCoordinator.swift](../Sources/SessionEngine/SessionCoordinator.swift)。状态定义见 [BoothCore/Models.swift](../Sources/BoothCore/Models.swift) 的 `BoothState`。

## 1. 状态机总览

```mermaid
stateDiagram-v2
    [*] --> idle : App 启动

    idle --> armed : 检测到人进入取景区域
    armed --> gestureWait : 姿势就绪（连续 N 帧站定）
    armed --> idle : 人离开超时（armedTimeoutSec，默认 10s）
    gestureWait --> countdown : ✌️ / 挥手命中（或空格兜底）
    gestureWait --> idle : 超时（gestureTimeoutSec，默认 30s）
    countdown --> capturing : 倒计时归零
    capturing --> countdown : 拼版模式：下一张（shot+1）
    capturing --> processing : 全部拍摄完成
    processing --> review : 合成成功
    processing --> failure : 修图失败 → 降级提示，5s 后回 idle
    review --> printing : 确认打印（选 1–4 张）
    review --> countdown : 重拍
    review --> printing : 超时无操作（reviewTimeoutSec 60s，可关自动打印）
    printing --> idle : 打印完成（含待机冷却 idleCooldownAfterPrintSec）
    failure --> idle

    note right of idle
        待机吸引页
        可轮播历史成片（idleSlideshow）
        显示 iPad 访问二维码
    end note
    note left of capturing
        快门 StilLCapture_Single
        → 等 ObjectAdded（10s 超时重试 1 次）
        → Get_Object 下载落盘
    end note
```

每次转移同步四路：日志 / 内部状态流 / EventBus / BoothServer WebSocket 广播——大屏与 iPad 永远同屏。

## 2. 宾客完整时序

```mermaid
sequenceDiagram
    actor G as 宾客
    participant Pad as iPad
    participant Eng as SessionCoordinator
    participant Cam as LUMIX 相机
    participant Img as ImagingKit
    participant Prn as PrintKit

    G->>Eng: 走近取景区域
    Eng->>Eng: 姿势就绪检测（人体+人脸连续 15 帧）
    Eng-->>G: 屏幕提示"比个耶开始拍照"
    G->>Eng: ✌️ / 挥手
    Eng-->>G: 3s 倒计时（末秒提示音+白闪）
    Eng->>Cam: 快门 ×4（拼版模式，每张独立倒计时）
    Cam-->>Eng: ObjectAdded → 下载原图
    Eng->>Img: 修图管线（调色/美肤/换背景/装饰/拼版/GIF）
    Img-->>Eng: print.jpg / display.jpg / electronic.jpg / boomerang.gif
    Eng-->>Pad: review 状态 + 成片
    G->>Pad: 选滤镜 → 确认打印（默认 2 张）/ 重拍 / 扫码存图
    Pad->>Eng: WS 指令 confirmPrint(copies)
    Eng->>Prn: 入串行队列
    Prn-->>G: 现场出片
    Eng-->>Pad: 打印完成 + QR 停留
```

手动兜底：空格键 = 与手势命中完全等价的开拍；REVIEW 态 `P` 键直接按默认张数打印。

## 3. 拍摄模式

模式在 IDLE 页点选，默认 `collage(4)`（可配置 `capture.defaultMode`）：

| ShootKind | CollageLayout | 张数 | 版面 |
|---|---|---|---|
| `single` | — | 1 | 单张直出 6 寸 |
| `collage` | `strip` 经典拼条 | 4 | 4 格纵列 + 底部品牌条 |
| `collage` | `grid2x2` 四宫格 | 4 | 2×2 宫格 |
| `collage` | `duo` 双格大图 | 2 | 上下两格 |

拼版模式每次倒计时独立，间隔显示"还有 N 张"；开启 `capture.continuousCollage` 可拍完自动回 idle 连续开拍（多人排队场景）。

## 4. 修图合成管线（PROCESSING）

管线各步配置驱动、可独立开关，**任一步失败降级跳过不阻断**：

```mermaid
flowchart TB
    Orig["原图 JPEG ×N"] --> Auto["① 自动调色<br/>白平衡/曝光/对比（可关）"]
    Auto --> Skin["② 美肤磨皮<br/>强度 skinStrength 0–100（可关）"]
    Skin --> BG["③ 换背景<br/>Vision 人像分割 matte（replaceBackground）"]
    BG --> Deco["④ 搞怪装饰<br/>人脸关键点贴纸/形变模板<br/>（decorations/ 模板驱动，可关）"]
    Deco --> Frame["⑤ 边框/主题/日期水印<br/>（frame + themeName）"]
    Frame --> Layout{"⑥ 排版"}
    Layout -->|"single"| One["单张 1200×1800"]
    Layout -->|"collage"| Collage["N 格拼版 1200×1800<br/>strip / grid2x2 / duo"]
    One --> Out
    Collage --> Out["⑦ 产物：print-base.jpg → print.jpg（打印位图）<br/>display.jpg（展示）electronic.jpg（电子版）<br/>print-qr.jpg（QR 叠印）boomerang.gif（可关）"]
    Out --> Review["REVIEW：拍后自选滤镜<br/>（applyFilter 基于 print-base.jpg 重打）"]
```

要点：`print-base.jpg` 是未滤镜未边框的底图，REVIEW 态换滤镜重打时基于它重新生成，产物换新 id 避免 iPad 浏览器缓存；GIF（Boomerang）在拼版模式下自动生成，QR 码优先指向 `.gif`。

## 5. 防抖与降级

| 环节 | 策略 |
|---|---|
| 姿势就绪 | 人体+人脸同帧检测，连续命中（默认 15 帧 ≈0.5s）才转 gestureWait |
| 手势 | ✌️ / 张开手掌连续命中 5 帧；现场光线复杂时空格键兜底 |
| 拍照 | 10s 未收 ObjectAdded 自动重试 1 次，仍失败进 failure 态（展示 5s 后回 idle，记日志） |
| 修图 | 单步失败跳过该步继续；全失败降级原图+边框 |
| 相机断线 | 事件/错误触发后指数退避重连，恢复自动重启 LiveView 回 idle |
| 连点防呆 | 同一成片 5s 内重复打印指令去重（printing.dedupeWindowSec） |

Vision 检测全部本地推理（Apple Vision），无网络依赖；灵敏度（连续帧数、面积阈值）入 `vision` 配置节。
