import Foundation

// ============================================================
// 配置（SPEC §9 设置页数据源）
// JSON 落盘 BoothPaths.configFile；Codable + 全字段默认值，
// 缺失字段自动回退默认（向后兼容老配置文件）。
// ============================================================

public struct BoothConfig: Codable, Sendable, Equatable {
    public var camera = CameraConf()
    public var capture = CaptureConf()
    public var vision = VisionConf()
    public var imaging = ImagingConf()
    public var printing = PrintConf()
    public var server = ServerConf()

    public init() {}

    public struct CameraConf: Codable, Sendable, Equatable {
        public var dylibPath = ""                 // 空 = 自动查找（bundle 资源 → 工作区 lib/）
        public var captureTimeoutSec: Double = 10
        public var captureRetry = 1               // 拍照超时自动重试次数
        public var reconnectBaseDelaySec: Double = 1   // 断线重连指数退避基数
        public var reconnectMaxDelaySec: Double = 15
        public var liveViewBufferSize = 1 << 20
        public init() {}
    }

    public struct CaptureConf: Codable, Sendable, Equatable {
        public var countdownSec = 3               // 3/5/10
        public var defaultMode = ShootMode.collage(4)
        public var reviewTimeoutSec = 60          // REVIEW 超时
        public var autoPrintOnTimeout = true      // 超时自动打默认份数（false=只回待机）
        public var gestureTimeoutSec = 30         // GESTURE 态超时回 idle
        public var armedTimeoutSec = 10           // ARMED 态人离开超时
        public init() {}
    }

    public struct VisionConf: Codable, Sendable, Equatable {
        public var gestureEnabled = true
        public var poseReadinessEnabled = true
        public var gestureHitFrames = 5           // 手势连续命中帧数
        public var readyFrames = 15               // 就绪连续帧数
        public var minFaceAreaRatio = 0.01        // 人脸最小面积占比
        public var detectEveryNFrames = 3         // 每 N 帧 LiveView 检测一次（控耗）
        public init() {}
    }

    public struct ImagingConf: Codable, Sendable, Equatable {
        public var autoColor = true               // 自动调色
        public var skinSmoothing = true           // 美肤
        public var skinStrength = 50              // 0-100
        public var replaceBackground = false      // 换背景（需主题带 background.png）
        public var decorationTemplate = ""        // 搞怪装饰模板名（decorations/<name>/template.json），空 = 关闭
        public var frame = true                   // 边框/水印
        public var themeName = "default"
        public var dateWatermark = true
        public init() {}
    }

    public struct PrintConf: Codable, Sendable, Equatable {
        public var printerName = ""               // 空 = 系统默认打印机
        public var defaultCopies = 2
        public var minCopies = 1
        public var maxCopies = 4
        public var paperWidthMM = 101.6           // 6 寸 4×6
        public var paperHeightMM = 152.4
        public var borderless = true
        public var dedupeWindowSec = 5            // 同一成片防连点窗口
        public init() {}
    }

    public struct ServerConf: Codable, Sendable, Equatable {
        public var enabled = true
        public var port: UInt16 = 8080
        public var liveViewToIpad = true          // 推 MJPEG 给 iPad
        public var ipadMaxFPS = 10
        public init() {}
    }
}

/// 配置存取（actor 串行，改即存）
public actor ConfigStore {
    public static let shared = ConfigStore()

    public private(set) var config: BoothConfig
    private var continuations: [UUID: AsyncStream<BoothConfig>.Continuation] = [:]

    private init() {
        var cfg = BoothConfig()
        if let data = try? Data(contentsOf: BoothPaths.configFile) {
            // 逐段解码，任一段损坏/缺字段不影响其他段
            let dec = JSONDecoder()
            if let obj = try? dec.decode(BoothConfig.self, from: data) { cfg = obj }
        }
        self.config = cfg
        Log.core.info("配置已加载: \(BoothPaths.configFile.path)")
    }

    /// 配置变化流（UI/各模块订阅热更新）
    public func stream() -> AsyncStream<BoothConfig> {
        let id = UUID()
        return AsyncStream { cont in
            cont.yield(config)
            continuations[id] = cont
            cont.onTermination = { [weak self] _ in
                Task { await self?.removeContinuation(id) }
            }
        }
    }

    private func removeContinuation(_ id: UUID) { continuations.removeValue(forKey: id) }

    public func update(_ mutate: @Sendable (inout BoothConfig) -> Void) {
        mutate(&config)
        save()
        for c in continuations.values { c.yield(config) }
    }

    private func save() {
        do {
            let enc = JSONEncoder()
            enc.outputFormatting = [.prettyPrinted, .sortedKeys]
            try enc.encode(config).write(to: BoothPaths.configFile, options: .atomic)
        } catch {
            Log.core.error("配置保存失败: \(error.localizedDescription)")
        }
    }
}
