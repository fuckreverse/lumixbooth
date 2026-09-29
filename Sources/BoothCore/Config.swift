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
        // ---- 新增（PhotoBoothProject 借鉴）----
        public var continuousCollage = false      // 拼版连拍不中断：仅首张倒计时，后续立即拍（吞吐翻倍）
        public var idleSlideshow = true           // IDLE 吸引页轮播历史成片
        public var idleSlideshowSec = 6           // 轮播间隔（秒）
        public init() {}

        // 向后兼容解码：老配置缺新字段 → 默认值，不丢已有设置
        private enum CodingKeys: String, CodingKey {
            case countdownSec, defaultMode, reviewTimeoutSec, autoPrintOnTimeout
            case gestureTimeoutSec, armedTimeoutSec
            case continuousCollage, idleSlideshow, idleSlideshowSec
        }
        public init(from decoder: Decoder) throws {
            let c = try decoder.container(keyedBy: CodingKeys.self)
            countdownSec = try c.decodeIfPresent(Int.self, forKey: .countdownSec) ?? 3
            defaultMode = try c.decodeIfPresent(ShootMode.self, forKey: .defaultMode) ?? .collage(4)
            reviewTimeoutSec = try c.decodeIfPresent(Int.self, forKey: .reviewTimeoutSec) ?? 60
            autoPrintOnTimeout = try c.decodeIfPresent(Bool.self, forKey: .autoPrintOnTimeout) ?? true
            gestureTimeoutSec = try c.decodeIfPresent(Int.self, forKey: .gestureTimeoutSec) ?? 30
            armedTimeoutSec = try c.decodeIfPresent(Int.self, forKey: .armedTimeoutSec) ?? 10
            continuousCollage = try c.decodeIfPresent(Bool.self, forKey: .continuousCollage) ?? false
            idleSlideshow = try c.decodeIfPresent(Bool.self, forKey: .idleSlideshow) ?? true
            idleSlideshowSec = try c.decodeIfPresent(Int.self, forKey: .idleSlideshowSec) ?? 6
        }
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
        public var frame = true                   // 边框/水印
        public var themeName = "default"
        public var dateWatermark = true
        // ---- 新增（PhotoBoothProject 借鉴：拍后自选滤镜）----
        public var filterSelection = true         // REVIEW 态显示滤镜选择条
        public var defaultFilter = PhotoFilter.none // 拍摄流程默认滤镜（宾客可在 REVIEW 换）
        public init() {}

        // 向后兼容解码：老配置缺新字段 → 默认值
        private enum CodingKeys: String, CodingKey {
            case autoColor, skinSmoothing, skinStrength, replaceBackground
            case frame, themeName, dateWatermark, filterSelection, defaultFilter
        }
        public init(from decoder: Decoder) throws {
            let c = try decoder.container(keyedBy: CodingKeys.self)
            autoColor = try c.decodeIfPresent(Bool.self, forKey: .autoColor) ?? true
            skinSmoothing = try c.decodeIfPresent(Bool.self, forKey: .skinSmoothing) ?? true
            skinStrength = try c.decodeIfPresent(Int.self, forKey: .skinStrength) ?? 50
            replaceBackground = try c.decodeIfPresent(Bool.self, forKey: .replaceBackground) ?? false
            frame = try c.decodeIfPresent(Bool.self, forKey: .frame) ?? true
            themeName = try c.decodeIfPresent(String.self, forKey: .themeName) ?? "default"
            dateWatermark = try c.decodeIfPresent(Bool.self, forKey: .dateWatermark) ?? true
            filterSelection = try c.decodeIfPresent(Bool.self, forKey: .filterSelection) ?? true
            defaultFilter = PhotoFilter.parse(try c.decodeIfPresent(String.self, forKey: .defaultFilter))
        }
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
        // ---- 新增（借鉴 PhotoBoothProject 打印设置粒度）----
        public var printQRCode = true             // 成片右缘印 QR 码（扫码下载电子版）
        public var autoPrintDelaySec = 0          // REVIEW 超时自动打印前的延迟（给宾客最后反应时间）
        public var printingDwellSec = 3           // “打印中请稍候”提示停留时长（原硬编码 3s）
        public var printKeyEnabled = true         // 键盘 P 在 REVIEW 态触发打印（兜底）
        public var showPrintButton = true         // iPad REVIEW 页显示打印按钮（false=仅供 QR/重拍，操作员管控）
        public init() {}

        // 向后兼容解码：老配置缺新字段 → 默认值
        private enum CodingKeys: String, CodingKey {
            case printerName, defaultCopies, minCopies, maxCopies
            case paperWidthMM, paperHeightMM, borderless, dedupeWindowSec
            case printQRCode, autoPrintDelaySec, printingDwellSec, printKeyEnabled, showPrintButton
        }
        public init(from decoder: Decoder) throws {
            let c = try decoder.container(keyedBy: CodingKeys.self)
            printerName = try c.decodeIfPresent(String.self, forKey: .printerName) ?? ""
            defaultCopies = try c.decodeIfPresent(Int.self, forKey: .defaultCopies) ?? 2
            minCopies = try c.decodeIfPresent(Int.self, forKey: .minCopies) ?? 1
            maxCopies = try c.decodeIfPresent(Int.self, forKey: .maxCopies) ?? 4
            paperWidthMM = try c.decodeIfPresent(Double.self, forKey: .paperWidthMM) ?? 101.6
            paperHeightMM = try c.decodeIfPresent(Double.self, forKey: .paperHeightMM) ?? 152.4
            borderless = try c.decodeIfPresent(Bool.self, forKey: .borderless) ?? true
            dedupeWindowSec = try c.decodeIfPresent(Int.self, forKey: .dedupeWindowSec) ?? 5
            printQRCode = try c.decodeIfPresent(Bool.self, forKey: .printQRCode) ?? true
            autoPrintDelaySec = try c.decodeIfPresent(Int.self, forKey: .autoPrintDelaySec) ?? 0
            printingDwellSec = try c.decodeIfPresent(Int.self, forKey: .printingDwellSec) ?? 3
            printKeyEnabled = try c.decodeIfPresent(Bool.self, forKey: .printKeyEnabled) ?? true
            showPrintButton = try c.decodeIfPresent(Bool.self, forKey: .showPrintButton) ?? true
        }
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
