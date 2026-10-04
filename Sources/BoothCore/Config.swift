import Foundation

// ============================================================
// 配置（SPEC §9 设置页数据源）
// JSON 落盘 BoothPaths.configFile；Codable + 全字段默认值。
// 向后兼容三层防线（防呆）：
//   ① 读取时先与「默认配置 JSON」深合并 → 老文件缺新字段自动补默认
//   ② 整体解码失败时逐段解码 → 单段损坏不影响其他段
//   ③ sanitized() 值域夹取 → 手改坏值不带病运行
// ============================================================

public struct BoothConfig: Codable, Sendable, Equatable {
    public var camera = CameraConf()
    public var capture = CaptureConf()
    public var vision = VisionConf()
    public var imaging = ImagingConf()
    public var printing = PrintConf()
    public var server = ServerConf()
    public var security = SecurityConf()
    public var sounds = SoundConf()
    public var share = ShareConf()
    public var guestbook = GuestbookConf()

    /// 向后兼容解码：旧 config.json 缺某段（如 security）时用默认值，不整体失败
    private enum TopLevelKeys: String, CodingKey {
        case camera, capture, vision, imaging, printing, server, security
        case sounds, share, guestbook
    }
    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: TopLevelKeys.self)
        camera = try c.decodeIfPresent(CameraConf.self, forKey: .camera) ?? CameraConf()
        capture = try c.decodeIfPresent(CaptureConf.self, forKey: .capture) ?? CaptureConf()
        vision = try c.decodeIfPresent(VisionConf.self, forKey: .vision) ?? VisionConf()
        imaging = try c.decodeIfPresent(ImagingConf.self, forKey: .imaging) ?? ImagingConf()
        printing = try c.decodeIfPresent(PrintConf.self, forKey: .printing) ?? PrintConf()
        server = try c.decodeIfPresent(ServerConf.self, forKey: .server) ?? ServerConf()
        security = try c.decodeIfPresent(SecurityConf.self, forKey: .security) ?? SecurityConf()
        sounds = try c.decodeIfPresent(SoundConf.self, forKey: .sounds) ?? SoundConf()
        share = try c.decodeIfPresent(ShareConf.self, forKey: .share) ?? ShareConf()
        guestbook = try c.decodeIfPresent(GuestbookConf.self, forKey: .guestbook) ?? GuestbookConf()
    }

    public init() {}

    public struct CameraConf: Codable, Sendable, Equatable {
        public var dylibPath = ""                 // 空 = 自动查找（bundle 资源 → 工作区 lib/）
        public var captureTimeoutSec: Double = 10
        public var captureRetry = 1               // 拍照超时自动重试次数
        public var reconnectBaseDelaySec: Double = 1   // 断线重连指数退避基数
        public var reconnectMaxDelaySec: Double = 15
        public var liveViewBufferSize = 1 << 20
        /// 电量/存储轮询间隔（秒；连接后自动开启，0 = 关闭）
        public var statusPollIntervalSec: Double = 30
        public init() {}

        // 向后兼容解码：老配置缺新字段 → 默认值
        private enum CodingKeys: String, CodingKey {
            case dylibPath, captureTimeoutSec, captureRetry
            case reconnectBaseDelaySec, reconnectMaxDelaySec, liveViewBufferSize
            case statusPollIntervalSec
        }
        public init(from decoder: Decoder) throws {
            let c = try decoder.container(keyedBy: CodingKeys.self)
            dylibPath = try c.decodeIfPresent(String.self, forKey: .dylibPath) ?? ""
            captureTimeoutSec = try c.decodeIfPresent(Double.self, forKey: .captureTimeoutSec) ?? 10
            captureRetry = try c.decodeIfPresent(Int.self, forKey: .captureRetry) ?? 1
            reconnectBaseDelaySec = try c.decodeIfPresent(Double.self, forKey: .reconnectBaseDelaySec) ?? 1
            reconnectMaxDelaySec = try c.decodeIfPresent(Double.self, forKey: .reconnectMaxDelaySec) ?? 15
            liveViewBufferSize = try c.decodeIfPresent(Int.self, forKey: .liveViewBufferSize) ?? (1 << 20)
            statusPollIntervalSec = try c.decodeIfPresent(Double.self, forKey: .statusPollIntervalSec) ?? 30
        }
    }

    public struct CaptureConf: Codable, Sendable, Equatable {
        public var countdownSec = 3               // 3/5/10
        public var defaultMode = ShootMode.collage(4)
        public var reviewTimeoutSec = 60          // REVIEW 超时
        public var autoPrintOnTimeout = false     // 超时自动打默认份数（默认关省相纸；false=只回待机，打印必须手动确认）
        public var gestureTimeoutSec = 30         // GESTURE 态超时回 idle
        public var armedTimeoutSec = 10           // ARMED 态人离开超时
        // ---- 新增（PhotoBoothProject 借鉴）----
        public var continuousCollage = false      // 拼版连拍不中断：仅首张倒计时，后续立即拍（吞吐翻倍）
        public var idleSlideshow = true           // IDLE 吸引页轮播历史成片
        public var idleSlideshowSec = 6           // 轮播间隔（秒）
        public var idleCooldownAfterPrintSec = 0  // 打印完成回待机后自动 armed 冷却（秒；0=不冷却）
        // ---- 省电模式（借鉴商业软件“idle 保护”）：待机 N 分钟调暗大屏/暂停轮播 ----
        public var idleDimAfterMin = 10           // 0 = 不启用；>0 待机超过 N 分钟进入省电调暗
        // ---- 拍照前快速设置：触发方式（大屏待机页快捷切换，持久生效）----
        public var triggerStyle = TriggerStyle.countdown  // 暂时只开放手动倒计时
        // ---- 拍后选片（连拍完成后挑一张或挑拼图样式）----
        public var layoutSelection = true         // 连拍后进入选片页（false = 直接按默认布局出片）
        public var selectTimeoutSec = 30          // 选片页超时：按默认布局自动出片
        public init() {}

        // 向后兼容解码：老配置缺新字段 → 默认值，不丢已有设置
        private enum CodingKeys: String, CodingKey {
            case countdownSec, defaultMode, reviewTimeoutSec, autoPrintOnTimeout
            case gestureTimeoutSec, armedTimeoutSec
            case continuousCollage, idleSlideshow, idleSlideshowSec
            case idleCooldownAfterPrintSec, idleDimAfterMin
            case triggerStyle, layoutSelection, selectTimeoutSec
        }
        public init(from decoder: Decoder) throws {
            let c = try decoder.container(keyedBy: CodingKeys.self)
            countdownSec = try c.decodeIfPresent(Int.self, forKey: .countdownSec) ?? 3
            defaultMode = try c.decodeIfPresent(ShootMode.self, forKey: .defaultMode) ?? .collage(4)
            reviewTimeoutSec = try c.decodeIfPresent(Int.self, forKey: .reviewTimeoutSec) ?? 60
            autoPrintOnTimeout = try c.decodeIfPresent(Bool.self, forKey: .autoPrintOnTimeout) ?? false
            gestureTimeoutSec = try c.decodeIfPresent(Int.self, forKey: .gestureTimeoutSec) ?? 30
            armedTimeoutSec = try c.decodeIfPresent(Int.self, forKey: .armedTimeoutSec) ?? 10
            continuousCollage = try c.decodeIfPresent(Bool.self, forKey: .continuousCollage) ?? false
            idleSlideshow = try c.decodeIfPresent(Bool.self, forKey: .idleSlideshow) ?? true
            idleSlideshowSec = try c.decodeIfPresent(Int.self, forKey: .idleSlideshowSec) ?? 6
            idleCooldownAfterPrintSec = try c.decodeIfPresent(Int.self, forKey: .idleCooldownAfterPrintSec) ?? 0
            idleDimAfterMin = try c.decodeIfPresent(Int.self, forKey: .idleDimAfterMin) ?? 10
            let trigger = try c.decodeIfPresent(String.self, forKey: .triggerStyle)
            triggerStyle = trigger.flatMap(TriggerStyle.init(rawValue:)) ?? .countdown
            layoutSelection = try c.decodeIfPresent(Bool.self, forKey: .layoutSelection) ?? true
            selectTimeoutSec = try c.decodeIfPresent(Int.self, forKey: .selectTimeoutSec) ?? 30
        }
    }

    public struct VisionConf: Codable, Sendable, Equatable {
        public var gestureEnabled = false
        public var poseReadinessEnabled = false
        // 防抖为时长语义（毫秒）：连续稳定 X ms 才算命中，对 LiveView 帧率波动免疫。
        // 旧配置的帧数字段（readyFrames/gestureHitFrames）已废弃，解码时忽略。
        public var readyStableMs = 1200          // 姿势就绪需连续稳定时长
        public var gestureStableMs = 350         // 手势需连续稳定时长
        public var absentStableMs = 1000         // 人离开画面判定时长（armed/gestureWait 共用）
        public var minFaceAreaRatio = 0.01       // 人脸最小面积占比
        public var detectEveryNFrames = 3        // 每 N 帧 LiveView 检测一次（控耗）
        public init() {}

        // 向后兼容解码：老配置缺新字段（或只有旧帧数字段）→ 默认值
        private enum CodingKeys: String, CodingKey {
            case gestureEnabled, poseReadinessEnabled
            case readyStableMs, gestureStableMs, absentStableMs
            case minFaceAreaRatio, detectEveryNFrames
        }
        public init(from decoder: Decoder) throws {
            let c = try decoder.container(keyedBy: CodingKeys.self)
            gestureEnabled = try c.decodeIfPresent(Bool.self, forKey: .gestureEnabled) ?? false
            poseReadinessEnabled = try c.decodeIfPresent(Bool.self, forKey: .poseReadinessEnabled) ?? false
            readyStableMs = try c.decodeIfPresent(Int.self, forKey: .readyStableMs) ?? 1200
            gestureStableMs = try c.decodeIfPresent(Int.self, forKey: .gestureStableMs) ?? 350
            absentStableMs = try c.decodeIfPresent(Int.self, forKey: .absentStableMs) ?? 1000
            minFaceAreaRatio = try c.decodeIfPresent(Double.self, forKey: .minFaceAreaRatio) ?? 0.01
            detectEveryNFrames = try c.decodeIfPresent(Int.self, forKey: .detectEveryNFrames) ?? 3
        }
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
        // ---- 新增（PhotoBoothProject 借鉴：拍后自选滤镜）----
        public var filterSelection = true         // REVIEW 态显示滤镜选择条
        public var defaultFilter = PhotoFilter.none // 拍摄流程默认滤镜（宾客可在 REVIEW 换）
        // ---- GIF/Boomerang（借鉴商业软件）：连拍原图编 GIF，QR 指向动态图 ----
        public var generateGIF = true              // 拼版模式下生成 boomerang.gif
        public init() {}

        // 向后兼容解码：老配置缺新字段 → 默认值
        private enum CodingKeys: String, CodingKey {
            case autoColor, skinSmoothing, skinStrength, replaceBackground
            case decorationTemplate
            case frame, themeName, dateWatermark, filterSelection, defaultFilter
            case generateGIF
        }
        public init(from decoder: Decoder) throws {
            let c = try decoder.container(keyedBy: CodingKeys.self)
            autoColor = try c.decodeIfPresent(Bool.self, forKey: .autoColor) ?? true
            skinSmoothing = try c.decodeIfPresent(Bool.self, forKey: .skinSmoothing) ?? true
            skinStrength = try c.decodeIfPresent(Int.self, forKey: .skinStrength) ?? 50
            replaceBackground = try c.decodeIfPresent(Bool.self, forKey: .replaceBackground) ?? false
            decorationTemplate = try c.decodeIfPresent(String.self, forKey: .decorationTemplate) ?? ""
            frame = try c.decodeIfPresent(Bool.self, forKey: .frame) ?? true
            themeName = try c.decodeIfPresent(String.self, forKey: .themeName) ?? "default"
            dateWatermark = try c.decodeIfPresent(Bool.self, forKey: .dateWatermark) ?? true
            filterSelection = try c.decodeIfPresent(Bool.self, forKey: .filterSelection) ?? true
            defaultFilter = PhotoFilter.parse(try c.decodeIfPresent(String.self, forKey: .defaultFilter))
            generateGIF = try c.decodeIfPresent(Bool.self, forKey: .generateGIF) ?? true
        }
    }

    public struct PrintConf: Codable, Sendable, Equatable {
        public var printerName = ""               // 空 = 系统默认打印机
        public var defaultCopies = 2
        public var minCopies = 1
        public var maxCopies = 4
        // ---- 新增（操作员设置页：打印尺寸/打印质量）----
        public var paperSize = PaperSize.six      // 6 寸 4×6（默认）
        public var printQuality = PrintQuality.standard  // 标准（默认）
        public var paperWidthMM = 101.6           // 遗留字段：随 paperSize 自动同步（sanitized）
        public var paperHeightMM = 152.4
        public var borderless = true              // 无边距（5 寸不支持时自动降级有边距）
        public var dedupeWindowSec = 5            // 同一成片防连点窗口
        public var printQuotaPerHour = 0          // 每小时打印张数上限，0 = 不限制（防脚本刷打印）
        // ---- 新增（借鉴 PhotoBoothProject 打印设置粒度）----
        public var printQRCode = true             // 成片右缘印 QR 码（扫码下载电子版）
        public var autoPrintDelaySec = 0          // REVIEW 超时自动打印前的延迟（给宾客最后反应时间）
        public var printingDwellSec = 3           // “打印中请稍候”提示停留时长（原硬编码 3s）
        public var printKeyEnabled = true         // 键盘 P 在 REVIEW 态触发打印（兜底）
        public var showPrintButton = true         // iPad REVIEW 页显示打印按钮（false=仅供 QR/重拍，操作员管控）
        public var dryRun = false                 // 演示模式：不送打印机，输出 PDF 到 print-preview/
        public init() {}

        // 向后兼容解码：老配置缺新字段 → 默认值
        private enum CodingKeys: String, CodingKey {
            case printerName, defaultCopies, minCopies, maxCopies
            case paperSize, printQuality
            case paperWidthMM, paperHeightMM, borderless, dedupeWindowSec, printQuotaPerHour
            case printQRCode, autoPrintDelaySec, printingDwellSec, printKeyEnabled, showPrintButton
            case dryRun
        }
        public init(from decoder: Decoder) throws {
            let c = try decoder.container(keyedBy: CodingKeys.self)
            printerName = try c.decodeIfPresent(String.self, forKey: .printerName) ?? ""
            defaultCopies = try c.decodeIfPresent(Int.self, forKey: .defaultCopies) ?? 2
            minCopies = try c.decodeIfPresent(Int.self, forKey: .minCopies) ?? 1
            maxCopies = try c.decodeIfPresent(Int.self, forKey: .maxCopies) ?? 4
            paperSize = PaperSize.parse(try c.decodeIfPresent(String.self, forKey: .paperSize))
            printQuality = PrintQuality.parse(try c.decodeIfPresent(String.self, forKey: .printQuality))
            paperWidthMM = try c.decodeIfPresent(Double.self, forKey: .paperWidthMM) ?? 101.6
            paperHeightMM = try c.decodeIfPresent(Double.self, forKey: .paperHeightMM) ?? 152.4
            borderless = try c.decodeIfPresent(Bool.self, forKey: .borderless) ?? true
            dedupeWindowSec = try c.decodeIfPresent(Int.self, forKey: .dedupeWindowSec) ?? 5
            printQuotaPerHour = try c.decodeIfPresent(Int.self, forKey: .printQuotaPerHour) ?? 0
            printQRCode = try c.decodeIfPresent(Bool.self, forKey: .printQRCode) ?? true
            autoPrintDelaySec = try c.decodeIfPresent(Int.self, forKey: .autoPrintDelaySec) ?? 0
            printingDwellSec = try c.decodeIfPresent(Int.self, forKey: .printingDwellSec) ?? 3
            printKeyEnabled = try c.decodeIfPresent(Bool.self, forKey: .printKeyEnabled) ?? true
            showPrintButton = try c.decodeIfPresent(Bool.self, forKey: .showPrintButton) ?? true
            dryRun = try c.decodeIfPresent(Bool.self, forKey: .dryRun) ?? false
        }
    }

    public struct ServerConf: Codable, Sendable, Equatable {
        public var enabled = true
        public var port: UInt16 = 8080
        public var liveViewToIpad = true          // 推 MJPEG 给 iPad
        public var ipadMaxFPS = 10
        public init() {}
    }

    /// 防呆保护（无人值守场景）：退出保护开关。
    /// PIN 哈希存独立 guard.json（PINStore），一键重置配置不会把密码冲掉。
    public struct SecurityConf: Codable, Sendable, Equatable {
        public var quitProtection = true          // Cmd+Q / 关窗需 PIN 验证
        // ---- /gallery 操作员重打口令（借鉴商业软件“操作员补打”）：验码通过才允许重打 ----
        public var reprintCode = "1234"          // 口令（明文；重打是低风险操作，仅防宾客误触）
        public init() {}

        // 向后兼容解码：老配置缺 reprintCode 字段 → 默认值
        private enum CodingKeys: String, CodingKey {
            case quitProtection, reprintCode
        }
        public init(from decoder: Decoder) throws {
            let c = try decoder.container(keyedBy: CodingKeys.self)
            quitProtection = try c.decodeIfPresent(Bool.self, forKey: .quitProtection) ?? true
            reprintCode = try c.decodeIfPresent(String.self, forKey: .reprintCode) ?? "1234"
        }
    }

    // MARK: - 提示音体系（借鉴商业软件：倒计时/快门/打印完成音）

    public struct SoundConf: Codable, Sendable, Equatable {
        public var enabled = true              // 总开关（活动现场静音用）
        public var countdownBeep = true        // 倒计时哔声（每秒一哔，最后一秒高音）
        public var shutterSound = true        // 快门音（进入 capturing 态）
        public var printDoneSound = true       // 打印完成可声（printing→idle）
        public var volume = 0.8               // 0.0-1.0
        public init() {}
    }

    // MARK: - 分享与线索采集（邮箱采集：活动营销能力，借鉴 dslrBooth/LumaBooth）

    public struct ShareConf: Codable, Sendable, Equatable {
        public var emailCapture = true         // iPad REVIEW 页显示“邮箱接收电子版”输入框
        public init() {}
    }

    // MARK: - 视频留言簿（婚礼场景：拍完照后录一段祝福视频）

    public struct GuestbookConf: Codable, Sendable, Equatable {
        public var enabled = false             // 需 Mac 有摄像头/麦克风，默认关
        public var maxDurationSec = 15         // 单段上限（自动停止）
        public var overlayText = "新婚快乐"       // 录制预览与回放页的文字 overlay
        public init() {}
    }
}

// MARK: - 值域净化（防呆：手改 config.json / 文件损坏时不带病运行）

extension BoothConfig {

    /// 全字段夹取到安全区间，返回净化后的副本
    public func sanitized() -> BoothConfig {
        var c = self
        // 相机
        c.camera.captureTimeoutSec = c.camera.captureTimeoutSec.clamped(1...60)
        c.camera.captureRetry = c.camera.captureRetry.clamped(0...5)
        c.camera.reconnectBaseDelaySec = c.camera.reconnectBaseDelaySec.clamped(0.1...60)
        c.camera.reconnectMaxDelaySec = c.camera.reconnectMaxDelaySec.clamped(0.1...120)
        c.camera.liveViewBufferSize = c.camera.liveViewBufferSize.clamped(1 << 16...1 << 24)
        // 拍摄（0 秒倒计时 = 立即拍，是合法操作员选择；只拦负数/爆炸值）
        c.capture.countdownSec = c.capture.countdownSec.clamped(0...30)
        c.capture.reviewTimeoutSec = c.capture.reviewTimeoutSec.clamped(1...600)
        c.capture.gestureTimeoutSec = c.capture.gestureTimeoutSec.clamped(5...300)
        c.capture.armedTimeoutSec = c.capture.armedTimeoutSec.clamped(3...120)
        c.capture.defaultMode.shots = c.capture.defaultMode.shots.clamped(1...8)
        // 视觉
        c.vision.readyStableMs = c.vision.readyStableMs.clamped(0...30_000)
        c.vision.gestureStableMs = c.vision.gestureStableMs.clamped(0...10_000)
        c.vision.absentStableMs = c.vision.absentStableMs.clamped(0...30_000)
        c.vision.minFaceAreaRatio = c.vision.minFaceAreaRatio.clamped(0.0001...0.25)
        c.vision.detectEveryNFrames = c.vision.detectEveryNFrames.clamped(1...30)
        // 修图
        c.imaging.skinStrength = c.imaging.skinStrength.clamped(0...100)
        // 打印
        c.printing.defaultCopies = c.printing.defaultCopies.clamped(1...4)
        c.printing.minCopies = c.printing.minCopies.clamped(1...4)
        c.printing.maxCopies = c.printing.maxCopies.clamped(1...8)
        if c.printing.minCopies > c.printing.maxCopies { c.printing.minCopies = c.printing.maxCopies }
        c.printing.paperWidthMM = c.printing.paperWidthMM.clamped(50...300)
        c.printing.paperHeightMM = c.printing.paperHeightMM.clamped(50...300)
        c.printing.dedupeWindowSec = c.printing.dedupeWindowSec.clamped(0...120)
        c.printing.printQuotaPerHour = c.printing.printQuotaPerHour.clamped(0...1000)
        c.printing.autoPrintDelaySec = c.printing.autoPrintDelaySec.clamped(0...120)
        c.printing.printingDwellSec = c.printing.printingDwellSec.clamped(0...60)
        // 尺寸单一真源：毫米遗留字段随 paperSize 同步（老配置改过 mm 不再生效）
        let mm = c.printing.paperSize.sizeMM
        c.printing.paperWidthMM = mm.width
        c.printing.paperHeightMM = mm.height
        // 拍摄/省电
        c.capture.idleSlideshowSec = c.capture.idleSlideshowSec.clamped(2...120)
        c.capture.idleCooldownAfterPrintSec = c.capture.idleCooldownAfterPrintSec.clamped(0...600)
        c.capture.idleDimAfterMin = c.capture.idleDimAfterMin.clamped(0...240)
        c.capture.selectTimeoutSec = c.capture.selectTimeoutSec.clamped(5...300)
        // 提示音
        c.sounds.volume = c.sounds.volume.clamped(0...1)
        // 留言簿
        c.guestbook.maxDurationSec = c.guestbook.maxDurationSec.clamped(5...120)
        c.guestbook.overlayText = String(c.guestbook.overlayText.prefix(20))
        // 服务
        c.server.port = UInt16(min(max(Double(c.server.port), 0), 65_535))
        c.server.ipadMaxFPS = c.server.ipadMaxFPS.clamped(1...30)
        return c
    }
}

private extension Comparable {
    func clamped(_ range: ClosedRange<Self>) -> Self {
        Swift.min(Swift.max(self, range.lowerBound), range.upperBound)
    }
}

// MARK: - 容错加载（缺字段补默认 / 坏段隔离）

extension BoothConfig {

    /// 从 JSON 数据加载配置：默认值深合并 → 整体解码 → 失败则逐段解码 → 净化
    public static func load(from data: Data) -> BoothConfig {
        let merged = mergeWithDefaults(data)
        let dec = JSONDecoder()
        if let full = try? dec.decode(BoothConfig.self, from: merged) {
            return full.sanitized()
        }
        // 整体解码失败（某段字段类型损坏）→ 逐段解码，坏段用默认
        var cfg = BoothConfig()
        if let obj = try? JSONSerialization.jsonObject(with: merged) as? [String: Any] {
            for section in ["camera", "capture", "vision", "imaging", "printing", "server", "security",
                            "sounds", "share", "guestbook"] {
                guard let sub = obj[section] else { continue }
                guard let subData = try? JSONSerialization.data(withJSONObject: sub) else { continue }
                switch section {
                case "camera":   if let s = try? dec.decode(CameraConf.self, from: subData) { cfg.camera = s }
                case "capture":  if let s = try? dec.decode(CaptureConf.self, from: subData) { cfg.capture = s }
                case "vision":   if let s = try? dec.decode(VisionConf.self, from: subData) { cfg.vision = s }
                case "imaging":  if let s = try? dec.decode(ImagingConf.self, from: subData) { cfg.imaging = s }
                case "printing": if let s = try? dec.decode(PrintConf.self, from: subData) { cfg.printing = s }
                case "server":   if let s = try? dec.decode(ServerConf.self, from: subData) { cfg.server = s }
                case "security": if let s = try? dec.decode(SecurityConf.self, from: subData) { cfg.security = s }
                case "sounds":   if let s = try? dec.decode(SoundConf.self, from: subData) { cfg.sounds = s }
                case "share":    if let s = try? dec.decode(ShareConf.self, from: subData) { cfg.share = s }
                case "guestbook": if let s = try? dec.decode(GuestbookConf.self, from: subData) { cfg.guestbook = s }
                default: break
                }
            }
        }
        Log.core.warn("配置文件部分损坏，已按段容错加载（坏段回退默认值）")
        return cfg.sanitized()
    }

    /// 老配置 JSON 与默认配置深合并（老值优先、递归合并），
    /// 使新增字段自动补默认值，不破坏已有字段
    private static func mergeWithDefaults(_ data: Data) -> Data {
        guard let defaultsData = try? JSONEncoder().encode(BoothConfig()),
              var defaultsObj = (try? JSONSerialization.jsonObject(with: defaultsData)) as? [String: Any],
              let fileObj = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any] else {
            return data
        }
        deepMerge(into: &defaultsObj, from: fileObj)
        return (try? JSONSerialization.data(withJSONObject: defaultsObj)) ?? data
    }

    /// 递归合并：from 的值覆盖 target，同名字典递归，其余类型直接覆盖
    private static func deepMerge(into target: inout [String: Any], from: [String: Any]) {
        for (key, value) in from {
            if let sub = value as? [String: Any], let existing = target[key] as? [String: Any] {
                var merged = existing
                deepMerge(into: &merged, from: sub)
                target[key] = merged
            } else {
                target[key] = value
            }
        }
    }
}

// MARK: - 配置备份描述（操作员页「恢复备份」列表数据源）

public struct ConfigBackup: Sendable, Identifiable, Equatable {
    public let name: String          // 文件名 config-yyyyMMdd-HHmmss.json
    public let date: Date
    public let sizeBytes: Int
    public var id: String { name }
}

/// 配置存取（actor 串行，改即存）
public actor ConfigStore {
    public static let shared = ConfigStore()

    public private(set) var config: BoothConfig
    private var continuations: [UUID: AsyncStream<BoothConfig>.Continuation] = [:]

    private let fileURL: URL
    private let backupsDir: URL
    private let maxBackups = 10

    public init(fileURL: URL = BoothPaths.configFile,
                backupsDir: URL = BoothPaths.configBackupsDir) {
        self.fileURL = fileURL
        self.backupsDir = backupsDir
        // 备份目录先建好（copyItem 目标目录缺失会静默失败）
        try? FileManager.default.createDirectory(at: backupsDir, withIntermediateDirectories: true)
        var cfg = BoothConfig()
        if let data = try? Data(contentsOf: fileURL) {
            cfg = BoothConfig.load(from: data)
        }
        self.config = cfg
        Log.core.info("配置已加载: \(fileURL.path)")
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
        config = config.sanitized()      // 写入侧同样净化，防 UI/代码写坏值
        persist(backup: true)
        for c in continuations.values { c.yield(config) }
    }

    // MARK: - 备份 / 恢复 / 重置 / 导入导出（防呆核心）

    /// 写盘前自动备份当前配置（时间戳命名，保留最近 maxBackups 份）
    private func persist(backup: Bool) {
        if backup, FileManager.default.fileExists(atPath: fileURL.path) {
            backupCurrentFile()
        }
        do {
            let enc = JSONEncoder()
            enc.outputFormatting = [.prettyPrinted, .sortedKeys]
            try enc.encode(config).write(to: fileURL, options: .atomic)
        } catch {
            Log.core.error("配置保存失败: \(error.localizedDescription)")
        }
    }

    private func backupCurrentFile() {
        let fm = FileManager.default
        let stamp = DateFormatter(format: "yyyyMMdd-HHmmss").string(from: Date())
        let dest = backupsDir.appendingPathComponent("config-\(stamp).json")
        do {
            // 同秒内多次改动：覆盖同一份备份，避免爆量
            if fm.fileExists(atPath: dest.path) { try fm.removeItem(at: dest) }
            try fm.copyItem(at: fileURL, to: dest)
            pruneBackups()
            Log.core.debug("配置已自动备份: \(dest.lastPathComponent)")
        } catch {
            Log.core.warn("配置备份失败（不阻断写入）: \(error.localizedDescription)")
        }
    }

    /// 只保留最近 maxBackups 份（文件名时间序即时间序）
    private func pruneBackups() {
        let fm = FileManager.default
        guard let files = try? fm.contentsOfDirectory(atPath: backupsDir.path) else { return }
        let configs = files.filter { $0.hasPrefix("config-") && $0.hasSuffix(".json") }.sorted()
        guard configs.count > maxBackups else { return }
        for name in configs.prefix(configs.count - maxBackups) {
            try? fm.removeItem(at: backupsDir.appendingPathComponent(name))
        }
    }

    /// 备份列表（新→旧）
    public func listBackups() -> [ConfigBackup] {
        let fm = FileManager.default
        guard let files = try? fm.contentsOfDirectory(atPath: backupsDir.path) else { return [] }
        var items: [ConfigBackup] = []
        for name in files where name.hasPrefix("config-") && name.hasSuffix(".json") {
            let url = backupsDir.appendingPathComponent(name)
            let dateStr = String(name.dropFirst("config-".count).dropLast(".json".count))
            let date = DateFormatter(format: "yyyyMMdd-HHmmss").date(from: dateStr)
                ?? (try? fm.attributesOfItem(atPath: url.path)[.modificationDate] as? Date)
                ?? Date.distantPast
            let size = (try? fm.attributesOfItem(atPath: url.path)[.size] as? Int) ?? 0
            items.append(ConfigBackup(name: name, date: date, sizeBytes: size))
        }
        return items.sorted { $0.date > $1.date }
    }

    /// 恢复指定备份（当前配置会先自动备份 → 恢复操作本身可撤销）
    /// 返回 false = 备份不存在或内容损坏
    @discardableResult
    public func restoreBackup(named name: String) -> Bool {
        // 防路径注入：只允许纯文件名
        guard !name.contains("/"), !name.contains("..") else { return false }
        let url = backupsDir.appendingPathComponent(name)
        guard let data = try? Data(contentsOf: url) else { return false }
        let restored = BoothConfig.load(from: data)
        update { $0 = restored }
        Log.core.info("已恢复配置备份: \(name)")
        return true
    }

    /// 一键重置为默认配置（当前配置先自动备份 → 可反悔；不影响主题素材/历史照片/PIN）
    public func resetToDefaults() {
        update { $0 = BoothConfig() }
        Log.core.notice("配置已一键重置为默认（原配置已自动备份，可从「恢复备份」撤销）")
    }

    /// 导出当前配置到指定文件（DIY：多场活动复用）
    public func exportConfig(to url: URL) throws {
        let enc = JSONEncoder()
        enc.outputFormatting = [.prettyPrinted, .sortedKeys]
        try enc.encode(config).write(to: url, options: .atomic)
        Log.core.info("配置已导出: \(url.path)")
    }

    /// 从文件导入配置（导入前自动备份当前配置 → 可撤销）
    public func importConfig(from url: URL) throws {
        let data = try Data(contentsOf: url)
        let imported = BoothConfig.load(from: data)   // 缺字段补默认 + 净化
        update { $0 = imported }
        Log.core.info("配置已导入: \(url.path)（原配置已自动备份）")
    }
}

/// 一次性 DateFormatter（备份文件名/解析用）
private extension DateFormatter {
    convenience init(format: String) {
        self.init()
        self.dateFormat = format
        self.locale = Locale(identifier: "en_US_POSIX")
    }
}
