# booth — LUMIX Photobooth

基于松下官方联机控制库 `libLmxptpif.dylib`（逆向自 LUMIX Tether v2.12）的 photobooth 项目。

## 目录结构

```
booth/
├── lmx.py                    # ctypes 绑定：连接/预览/拍摄/下载 全能力（可直接跑）
└── Sources/CameraKit/
    └── libLmxptpif.dylib     # 原厂库 (universal x86_64+arm64，仅依赖系统框架)
```

> 逆向分析成果（ANALYSIS.md / 反编译伪代码 / IDA 数据库）已从 git 历史移除，
> 保留在本机仓库外的 `../booth-analysis/`（开发参考，非运行时依赖）。

## 快速上手

```bash
# 1. 相机机身菜单：USB 模式设为 "Tether"（否则枚举不到设备）
# 2. 连接 USB，然后：
python3 lmx.py            # 枚举设备（验证连通）
python3 lmx.py --lv       # 预览 10 帧 JPEG
python3 lmx.py --shot     # 拍照 + 下载落盘
```

代码内使用：

```python
from lmx import LumixCamera

cam = LumixCamera().open()          # 搜索→选设备→开 PTP 会话
cam.start_liveview()
frame = cam.liveview_frame()        # bytes，完整 JPEG，可直接喂前端 <img>
handle = cam.capture()              # 全按快门，阻塞到 ObjectAdded 事件
data = cam.download(handle)         # 照片完整字节
cam.close()
```

## 开发要点（详见 ../booth-analysis/ANALYSIS.md）

- **拍照就绪信号**：`Reg_NotifyCallback(0x10000040, cb)`，回调 `param` 即新照片 handle
- **预览帧**：轮询 `Mnt_Get_LiveView_data`，忙时返回 err=0x40004（无新帧），JPEG 约 10-30fps
- **多相机**：所有 API 以 `uuid` 字符串路由，`search()` 返回列表按 index 选
- **错误处理**：每个 API 末位 `uint* err` 出参；`0x10000`=参数空，`0x40004`=LiveView 忙
- **风险**：非公开 API，升级 LUMIX Tether 版本可能变签名；商用需评估 EULA
  （所有 PTP opcode 已还原，最坏可甩开此库自实现，见 ANALYSIS.md §3）

## 无硬件演示（Mock 模式）

不接相机/打印机也能演示完整 GUI 流程：

```bash
make run-mock       # 直接跑：合成相机 + 姿势/手势自动命中 + 打印落 PDF
make run-mock-app   # 以 .app 形态跑（有 bundle id，可被自动化/辅助功能识别）
make open-prints    # 打开 dry-run 打印的 PDF 输出目录
```

Mock 模式（启动参数 `-mock`）的行为：

- **相机**：MockCameraService 产合成 LiveView 帧流与"成片"（渐变 + 帧号），支持延迟/失败注入
- **视觉**：MockGestureDetector/MockReadinessDetector 恒定命中，空格/点击开始后自动走完
  armed → gestureWait → countdown → capturing → processing → review 全链路，review 超时后
  回到 idle 自动开启下一轮（无人值守循环演示）
- **打印**：强制 PreviewPrintBackend，不触碰 CUPS；每次打印把 1200×1800 打印位图包成
  N 页（N=份数）4×6 英寸 PDF 落到 `~/Library/Application Support/Booth/print-preview/`
- **窗口标题**带 `[Mock]` 后缀，便于区分真机

真机模式也能单独开打印 dry-run：操作员设置页 → 打印设置 → 「演示模式」开关
（配置项 `printing.dryRun`，热更新即时生效；旁边有按钮直达 PDF 预览目录）。
