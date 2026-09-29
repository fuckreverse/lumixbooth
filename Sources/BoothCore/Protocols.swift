import Foundation
import CoreGraphics

// ============================================================
// 模块契约 —— 所有并行实现的"接口宪法"。
// 各模块（CameraKit/VisionKit/ImagingKit/PrintKit）只依赖本文件协议，
// 互不 import；SessionEngine 通过协议组装，测试用 Mock 实现。
// ============================================================

// MARK: - 相机（CameraKit 实现）

/// 相机服务。实现必须是 actor 或内部串行化——dylib 非线程安全。
/// 稳定性要求（SPEC §4）：
///  - 断线自动重连（指数退避），恢复后自动重启 LiveView
///  - 拍照 10s 未收 ObjectAdded → 抛 captureTimeout（上层决定重试）
///  - LiveView 忙错误 0x40004 属正常，跳过等下一帧
public protocol CameraServicing: Sendable {
    /// 相机事件流（连接/断开/ObjectAdded/错误），多次订阅各自独立
    var events: AsyncStream<CameraEvent> { get }
    /// LiveView JPEG 帧流（startLiveView 后开始产出，stopLiveView 后结束）
    var liveViewFrames: AsyncStream<Data> { get }
    var connectionState: CameraConnectionState { get async }

    /// 搜索→选设备→开会话。找不到相机抛 cameraNotFound
    func connect() async throws
    func disconnect() async
    func startLiveView() async throws
    func stopLiveView() async
    /// 全按快门拍一张：阻塞到 ObjectAdded（默认 10s 超时），下载全图返回
    func capture() async throws -> CameraCapture
}

// MARK: - 手势 / 姿势（VisionKit 实现）

/// 手势识别：对单帧 LiveView JPEG 做检测，未检出返回 nil。
/// 连续帧防抖由 SessionEngine 负责（实现方只输出单帧结果）。
public protocol GestureDetecting: Sendable {
    func detectGesture(in jpeg: Data) async -> DetectedGesture?
}

/// 姿势就绪：人是否在画面中站定
public protocol PoseReadinessDetecting: Sendable {
    func detectReadiness(in jpeg: Data) async -> PoseReadiness
}

/// 人像分割：对成片原图跑一次，输出 8bit 灰度 matte（与输入同尺寸）
public protocol PersonSegmenting: Sendable {
    func segmentationMask(for image: CGImage) async throws -> CGImage
}

/// 人脸关键点检测（搞怪装饰/贴纸/形变用）：对成片原图跑一次。
/// 输出 FaceGeometry，坐标为原图像素、原点左下、y 向上；
/// 未检出人脸不抛错，返回空数组（上层降级跳过需人脸的装饰）。
public protocol FaceLandmarking: Sendable {
    func detectFaces(in image: CGImage) async throws -> [FaceGeometry]
}

// MARK: - 修图合成（ImagingKit 实现）

/// 修图合成管线（SPEC §6）：
/// 调色美肤 → 人像分割换背景 → 边框/水印 → 单张或拼版 → 打印位图+展示位图。
/// 要求：任一步失败降级跳过不阻断；产物写入 sessionDir 并返回 ProcessedPhoto。
public protocol ImagingServing: Sendable {
    func process(originals: [CameraCapture], mode: ShootMode, sessionDir: URL) async throws -> ProcessedPhoto
}

// MARK: - 打印（PrintKit 实现）

/// 打印服务：全局串行队列，6 寸无边距（SPEC §7）。
public protocol PrintServing: Sendable {
    /// 队列快照流（每次变化推送全量）
    var queue: AsyncStream<[PrintJob]> { get }
    var jobs: [PrintJob] { get async }
    @discardableResult func submit(image: URL, copies: Int) async -> PrintJob
    func retry(jobID: UUID) async
    func remove(jobID: UUID) async
}

// MARK: - iPad Web 服务（BoothServer 实现）

/// 内嵌 HTTP/WebSocket 服务（SPEC §8）：
///  GET /        iPad 单页应用
///  GET /live    LiveView MJPEG
///  GET /photo/{id}  成片下载（QR 指向）
///  WS  /ws      状态同步 + iPad 指令
public protocol BoothWebServing: Sendable {
    var port: UInt16 { get }
    /// iPad 指令流（confirm/retake/print）
    var commands: AsyncStream<iPadCommand> { get }
    func start() async throws
    func stop() async
    /// 推送当前流程状态（服务端广播给所有 iPad 客户端）
    func broadcast(state: BoothState) async
    /// 推送一帧 LiveView JPEG（MJPEG 转发；内部做降频/丢帧）
    func pushLiveViewFrame(_ jpeg: Data) async
    /// 注册成片供 /photo/{id} 下载
    func publishPhoto(_ photo: ProcessedPhoto) async
}

public enum iPadCommand: Sendable, Equatable {
    case confirmPrint(copies: Int)
    case retake
    case selectMode(ShootMode)
}
