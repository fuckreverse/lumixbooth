# booth — LUMIX Photobooth

基于松下官方联机控制库 `libLmxptpif.dylib`（逆向自 LUMIX Tether v2.12）的 photobooth 项目。

## 目录结构

```
booth/
├── lmx.py                    # ctypes 绑定：连接/预览/拍摄/下载 全能力（可直接跑）
├── lib/
│   └── libLmxptpif.dylib     # 原厂库 (universal x86_64+arm64，仅依赖系统框架)
└── analysis/                 # 逆向分析成果（开发参考，非运行时依赖）
    ├── ANALYSIS.md           # ★ API 地图 / 结构体布局 / 事件表 / 官方调用序列
    ├── decompiled/           # 111 个核心函数的 Hex-Rays 伪代码 (按地址_函数名.c)
    ├── all_funcs.txt         # 库内全部函数清单 (地址 + demangle 名)
    ├── summary.txt           # 反编译产物索引
    ├── dump_api.py           # IDAPython 批量反编译脚本（可复现）
    └── ida/                  # arm64 单架构 + .i64 数据库 (IDA 9.3)
```

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

## 开发要点（详见 analysis/ANALYSIS.md）

- **拍照就绪信号**：`Reg_NotifyCallback(0x10000040, cb)`，回调 `param` 即新照片 handle
- **预览帧**：轮询 `Mnt_Get_LiveView_data`，忙时返回 err=0x40004（无新帧），JPEG 约 10-30fps
- **多相机**：所有 API 以 `uuid` 字符串路由，`search()` 返回列表按 index 选
- **错误处理**：每个 API 末位 `uint* err` 出参；`0x10000`=参数空，`0x40004`=LiveView 忙
- **风险**：非公开 API，升级 LUMIX Tether 版本可能变签名；商用需评估 EULA
  （所有 PTP opcode 已还原，最坏可甩开此库自实现，见 ANALYSIS.md §3）
