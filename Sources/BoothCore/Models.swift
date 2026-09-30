import Foundation

// MARK: - 相机

/// 枚举到的 USB 相机
public struct CameraDeviceInfo: Sendable, Equatable, Codable {
    public var devId: UInt32
    public var uuid: String
    public var model: String
    public var serial: String
    public init(devId: UInt32, uuid: String, model: String, serial: String) {
        self.devId = devId; self.uuid = uuid; self.model = model; self.serial = serial
    }
}

/// 相机连接状态（UI 顶部状态条 / 操作员页展示）
public enum CameraConnectionState: String, Sendable, Equatable, Codable {
    case disconnected   // 未连接（含搜索不到）
    case searching      // 正在枚举设备
    case connecting     // SelectPnPDevice / OpenSession 中
    case connected      // 会话已开，未开 LiveView
    case liveView       // LiveView 取流中（可拍照）
    case reconnecting   // 断线重连中
}

/// 相机状态报告（电量/存储）。连接后定时轮询 + 存储事件触发刷新产生。
/// 电池原始字段来自 PTP vendor 0x9414（16B：tag/size + 4×u16），
/// 4 个 u16 的精确语义未在库内找到映射（主程序才消费），保守全量暴露 + 启发式百分比。
public struct CameraStatusReport: Sendable, Equatable {
    /// 电池原始字段（4×u16，语义待真机标定；常见布局疑为 [百分比, 电源/状态标志, 电压?, 温度?]）
    public var batteryFields: [UInt16]
    /// 电池百分比估算：取第一个落在 0...100 的字段；无候选时 nil
    public var batteryPercent: Int?
    /// 剩余可录秒数（GetFreeSpaceInSec，按当前画质折算；nil = 查询失败/不支持）
    public var freeRecordSeconds: UInt32?
    public var at: Date

    public init(batteryFields: [UInt16], freeRecordSeconds: UInt32?, at: Date = Date()) {
        self.batteryFields = batteryFields
        self.freeRecordSeconds = freeRecordSeconds
        self.at = at
        self.batteryPercent = Self.estimatePercent(batteryFields)
    }

    /// 启发式：0-100 是百分比唯一合理区间；取首个命中字段
    static func estimatePercent(_ fields: [UInt16]) -> Int? {
        fields.first { Int($0) <= 100 }.map(Int.init)
    }

    /// 电量告警阈值（photobooth 无人值守场景：提前提醒换电池）
    public var batteryLow: Bool { (batteryPercent ?? 100) <= 15 }
}

/// 相机层事件（相机专属流，SessionEngine/UI 订阅）
public enum CameraEvent: Sendable, Equatable {
    case connected(CameraDeviceInfo)
    case disconnected(reason: String)
    case objectAdded(handle: UInt32)
    case transferProgress(percent: UInt32)
    case statusReport(CameraStatusReport)
    case storeAdded(storageID: UInt32)        // 存储卡插入（param=storageID）
    case storeRemoved(storageID: UInt32)      // 存储卡拔出（param=storageID）
    case failure(String)
}

/// 一次快门的结果（JPEG 已在内存）
public struct CameraCapture: Sendable {
    public var handle: UInt32
    public var data: Data
    public var fileName: String   // 相机侧文件名，如 P1000123.JPG
    public init(handle: UInt32, data: Data, fileName: String) {
        self.handle = handle; self.data = data; self.fileName = fileName
    }
}

// MARK: - 拍摄模式与流程状态

public enum ShootKind: String, Sendable, Codable, Equatable {
    case single   // 单张直出 6 寸
    case collage  // 连拍 N 张拼 6 寸大头贴条
}

/// 拼版布局（借鉴 PhotoBoothProject 的多 collage 布局）
public enum CollageLayout: String, Sendable, Codable, Equatable, CaseIterable {
    case strip    // 经典大头贴条：N 格纵列
    case grid2x2  // 2×2 四宫格
    case duo      // 双格大图（上下两格）
    case trio     // 三格纵列
    case onePlusThree  // 主图在上 + 三小图横排在下

    /// 布局网格（列数 × 行数）；strip/trio 行数随张数自适应
    public var columns: Int {
        switch self {
        case .strip, .duo, .trio: return 1
        case .grid2x2: return 2
        case .onePlusThree: return 3   // 下排三小图列数（主图满宽）
        }
    }

    /// 该布局的推荐拍摄张数
    public var recommendedShots: Int {
        switch self {
        case .strip: return 4
        case .grid2x2: return 4
        case .duo: return 2
        case .trio: return 3
        case .onePlusThree: return 4
        }
    }

    /// 拍后选片时该布局需要选几张（nil = 全部连拍张数都上）
    public var requiredShots: Int? {
        switch self {
        case .strip: return nil
        case .grid2x2: return 4
        case .duo: return 2
        case .trio: return 3
        case .onePlusThree: return 4
        }
    }

    /// 中文显示名（UI 用）
    public var displayName: String {
        switch self {
        case .strip: return "经典拼条"
        case .grid2x2: return "四宫格"
        case .duo: return "双格大图"
        case .trio: return "三格拼条"
        case .onePlusThree: return "主图三拼"
        }
    }

    /// 布局图标 emoji（UI 用）
    public var emoji: String {
        switch self {
        case .strip: return "🎞️"
        case .grid2x2: return "🔲"
        case .duo: return "📐"
        case .trio: return "📊"
        case .onePlusThree: return "🏔️"
        }
    }
}

public struct ShootMode: Sendable, Codable, Equatable {
    public var kind: ShootKind
    public var shots: Int          // collage 用，single 恒为 1
    public var layout: CollageLayout // collage 布局（single 忽略）
    public static let single = ShootMode(kind: .single, shots: 1, layout: .strip)
    public static func collage(_ shots: Int = 4, layout: CollageLayout = .strip) -> ShootMode {
        ShootMode(kind: .collage, shots: shots, layout: layout)
    }
    public init(kind: ShootKind, shots: Int, layout: CollageLayout = .strip) {
        self.kind = kind; self.shots = shots; self.layout = layout
    }

    // 自定义解码：旧配置/旧指令 JSON 没有 layout 字段时回退 .strip
    private enum CodingKeys: String, CodingKey {
        case kind, shots, layout
    }
    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        kind = try c.decode(ShootKind.self, forKey: .kind)
        shots = try c.decode(Int.self, forKey: .shots)
        layout = try c.decodeIfPresent(CollageLayout.self, forKey: .layout) ?? .strip
    }
}

/// 拍后自选滤镜（借鉴 PhotoBoothProject "Choose an image filter after taking a picture"）
/// rawValue 是 iPad 指令 / 配置持久化用的英文 id，中文标签走 displayName
public enum PhotoFilter: String, Sendable, Codable, Equatable, CaseIterable {
    case none       // 原图（不做风格化）
    case vivid      // 鲜艳
    case warm       // 暖阳
    case cool       // 冷调
    case mono       // 黑白
    case nostalgia  // 复古
    case vintage    // 老相片（重褪色泛黄 + 暗角 + 颗粒）
    case fuji       // 富士（胶片感：轻冷青调 + 低反差 + 柔光空气感）
    case glam       // 妆照（磨皮加强+柔光+轻提亮）

    /// 中文显示名（UI 用）
    public var displayName: String {
        switch self {
        case .none: return "原图"
        case .vivid: return "鲜艳"
        case .warm: return "暖阳"
        case .cool: return "冷调"
        case .mono: return "黑白"
        case .nostalgia: return "复古"
        case .vintage: return "老相片"
        case .fuji: return "富士"
        case .glam: return "妆照"
        }
    }

    /// 滤镜图标 emoji（UI 用）
    public var emoji: String {
        switch self {
        case .none: return "🖼️"
        case .vivid: return "🌈"
        case .warm: return "🌅"
        case .cool: return "❄️"
        case .mono: return "⚫️"
        case .nostalgia: return "📻"
        case .vintage: return "🕰️"
        case .fuji: return "🏔️"
        case .glam: return "💄"
        }
    }

    /// 未知字符串安全解析（iPad 指令/老配置容错）
    public static func parse(_ raw: String?) -> PhotoFilter {
        guard let raw else { return .none }
        return PhotoFilter(rawValue: raw) ?? .none
    }
}

/// 修图产物
public struct ProcessedPhoto: Sendable, Equatable {
    public var id: UUID
    public var printFile: URL      // 1200×1800 @300dpi 打印位图
    public var displayFile: URL    // 长边 1600 展示位图（大屏/iPad/QR 下载）
    public var originals: [URL]    // 落盘原图
    /// 未滤镜未边框的排版底图（print-base.jpg；拍后换滤镜重打用，nil = 不支持重打）
    public var baseFile: URL?
    /// boomerang.gif 动态图路径（连拍模式生成；nil = 无动态图，QR 回退静态图）
    public var gifFile: URL?
    public init(id: UUID, printFile: URL, displayFile: URL, originals: [URL],
                baseFile: URL? = nil, gifFile: URL? = nil) {
        self.id = id; self.printFile = printFile; self.displayFile = displayFile
        self.originals = originals; self.baseFile = baseFile; self.gifFile = gifFile
    }
}

/// 拍后选片数据（连拍完成后让宾客挑一张或挑拼图样式）
public struct ShotSelection: Sendable, Equatable {
    /// 本次会话目录（拍后重拍/取消用）
    public var sessionDir: URL
    /// 连拍张缩略预览（与连拍张一一对应；生成失败时该张缺失）
    public var previews: [URL?]
    /// 预览图下载 id（与 previews 对齐；iPad 网页用 /photo/{id} 拉图）
    public var previewIDs: [UUID?]
    /// 超时回退的默认布局
    public var defaultLayout: CollageLayout
    public init(sessionDir: URL, previews: [URL?], previewIDs: [UUID?], defaultLayout: CollageLayout) {
        self.sessionDir = sessionDir
        self.previews = previews
        self.previewIDs = previewIDs
        self.defaultLayout = defaultLayout
    }
}

/// 拍照流程状态机（SPEC §3），Equatable 便于单测断言
public enum BoothState: Sendable, Equatable {
    case idle                              // 待机吸引页
    case armed                             // 检测到人，姿势引导中
    case gestureWait                       // 等待手势触发
    case countdown(secondsLeft: Int)       // 倒计时
    case capturing(shot: Int, of: Int)     // 快门+下载中
    case select(ShotSelection)             // 连拍完成，选片/选拼图样式
    case processing                        // 修图合成中
    case review(ProcessedPhoto)            // iPad/大屏确认
    case printing(copies: Int)             // 打印中
    case failure(String)                   // 可恢复错误（自动回 idle）
}

// MARK: - 触发方式（拍照前快速设置）

/// 拍照触发方式：手势拍照 = 姿势就绪后比手势/挥手开拍；
/// 倒计时拍照 = 姿势就绪后直接进倒计时（无需比手势）。
/// rawValue 为英文 id（配置持久化用），中文标签走 displayName。
public enum TriggerStyle: String, Sendable, Codable, Equatable, CaseIterable {
    case gesture
    case countdown

    public var displayName: String {
        switch self {
        case .gesture: return "手势拍照"
        case .countdown: return "倒计时拍照"
        }
    }

    public var emoji: String {
        switch self {
        case .gesture: return "✌️"
        case .countdown: return "⏱️"
        }
    }

    /// 未知字符串安全解析（老配置容错）
    public static func parse(_ raw: String?) -> TriggerStyle {
        guard let raw else { return .gesture }
        return TriggerStyle(rawValue: raw) ?? .gesture
    }
}

// MARK: - 手势与姿势

public enum DetectedGesture: String, Sendable, Equatable, Codable {
    case peace      // ✌️
    case openPalm   // 张开手掌（挥手的静态判定基础）
}

public struct PoseReadiness: Sendable, Equatable {
    public var humanPresent: Bool
    public var facePresent: Bool
    public var faceAreaRatio: Double   // 人脸面积 / 画面面积
    public var isReady: Bool           // VisionKit 按阈值综合判定
    public static let empty = PoseReadiness(humanPresent: false, facePresent: false, faceAreaRatio: 0, isReady: false)
    public init(humanPresent: Bool, facePresent: Bool, faceAreaRatio: Double, isReady: Bool) {
        self.humanPresent = humanPresent; self.facePresent = facePresent
        self.faceAreaRatio = faceAreaRatio; self.isReady = isReady
    }
}

// MARK: - 打印

public enum PrintJobStatus: String, Sendable, Codable, Equatable {
    case queued, printing, done, failed, cancelled
}

public struct PrintJob: Sendable, Codable, Equatable, Identifiable {
    public var id: UUID
    public var imagePath: String     // 打印位图绝对路径
    public var copies: Int
    public var status: PrintJobStatus
    public var createdAt: Date
    public var finishedAt: Date?
    public var lastError: String?
    public init(id: UUID = UUID(), imagePath: String, copies: Int,
                status: PrintJobStatus = .queued, createdAt: Date = Date(),
                finishedAt: Date? = nil, lastError: String? = nil) {
        self.id = id; self.imagePath = imagePath; self.copies = copies; self.status = status
        self.createdAt = createdAt; self.finishedAt = finishedAt; self.lastError = lastError
    }
}

// MARK: - 人脸关键点几何（搞怪装饰用）

/// 单张人脸的关键点几何。
/// 坐标系约定：**原图像素坐标，原点左下、y 向上**（与 Vision 归一化坐标、
/// CIImage extent、CGContext 一致，装饰算子之间无需任何翻转换算）。
public struct FaceGeometry: Sendable, Equatable {

    /// 关键点区域（区域缺失表示未检出，算子自行降级）
    public enum Region: String, Sendable, CaseIterable, Codable, Equatable {
        case faceContour, leftEye, rightEye, leftEyebrow, rightEyebrow
        case nose, outerLips, innerLips
    }

    /// 人脸框（像素，原点左下）
    public var rect: CGRect
    /// 头部侧倾角（弧度，逆时针为正；贴纸跟随旋转用）
    public var rollAngle: Double
    /// 各区域关键点（像素坐标）；未检出的区域缺省
    public var points: [Region: [CGPoint]]

    public init(rect: CGRect, rollAngle: Double = 0, points: [Region: [CGPoint]] = [:]) {
        self.rect = rect
        self.rollAngle = rollAngle
        self.points = points
    }

    /// 脸部中心
    public var faceCenter: CGPoint { CGPoint(x: rect.midX, y: rect.midY) }

    /// 左眼中心（左眼区域质心）
    public var leftEyeCenter: CGPoint? { Self.centroid(of: points[.leftEye]) }

    /// 右眼中心
    public var rightEyeCenter: CGPoint? { Self.centroid(of: points[.rightEye]) }

    /// 双眼中点
    public var eyeMidpoint: CGPoint? {
        guard let l = leftEyeCenter, let r = rightEyeCenter else { return nil }
        return CGPoint(x: (l.x + r.x) / 2, y: (l.y + r.y) / 2)
    }

    /// 两眼间距（贴纸缩放/形变半径的基准长度）
    public var eyeDistance: CGFloat? {
        guard let l = leftEyeCenter, let r = rightEyeCenter else { return nil }
        return hypot(r.x - l.x, r.y - l.y)
    }

    /// 嘴部中心（外唇区域质心）
    public var mouthCenter: CGPoint? { Self.centroid(of: points[.outerLips]) }

    private static func centroid(of points: [CGPoint]?) -> CGPoint? {
        guard let pts = points, !pts.isEmpty else { return nil }
        let sum = pts.reduce(into: CGPoint.zero) { $0.x += $1.x; $0.y += $1.y }
        return CGPoint(x: sum.x / CGFloat(pts.count), y: sum.y / CGFloat(pts.count))
    }
}

// MARK: - 全局事件总线事件

public enum AppEvent: Sendable, Equatable {
    case stateChanged(BoothState)
    case cameraConnectionChanged(CameraConnectionState)
    case printQueueChanged([PrintJob])
    case countdownTick(Int)
}

// MARK: - 通用错误

public enum BoothError: Error, Sendable, Equatable {
    case cameraNotFound
    case cameraConnectFailed(String)
    case captureTimeout
    case captureFailed(String)
    case liveViewFailed(String)
    case imagingFailed(String)
    case printerUnavailable(String)
    case serverFailed(String)
}
