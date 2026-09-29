import BoothCore
import CoreGraphics
import CoreText
import Foundation
import ImageIO

// ============================================================
// MockCameraService — CameraServicing 假实现（SessionEngine/UI 测试用）
//  - 不碰 dylib、不接真机，行为全部可编程（延迟 / 失败注入）
//  - liveViewFrames 产合成 JPEG：CoreGraphics 画渐变 + 帧号文字（1280×720）
//  - capture() 返回合成 JPEG：1920×1280（真机是 6000×4000 24MP，
//    太大拖慢测试与 UI 预览，Mock 用等比缩小尺寸即可，宽高比 3:2 保持一致）
// ============================================================

public actor MockCameraService: CameraServicing {

    // MARK: - 可编程行为（测试注入点）

    /// connect() 各阶段延迟
    public var connectDelay: TimeInterval = 0.05
    /// connect() 注入错误（如 cameraNotFound），置 nil 恢复正常
    public var connectError: (any Error)?
    /// capture() 快门延迟（模拟等待 ObjectAdded）
    public var captureDelay: TimeInterval = 0.1
    /// capture() 注入错误（如 captureTimeout），消费一次后自动清除
    public var captureError: (any Error)?
    /// LiveView 帧间隔（默认 ~15fps，比真机 30Hz 慢一半省 CPU）
    public var frameInterval: TimeInterval = 1.0 / 15.0
    /// 模拟设备信息
    public var mockDevice = CameraDeviceInfo(devId: 1, uuid: "MOCK-LUMIX-S5-0000",
                                             model: "DC-S5", serial: "MOCKSERIAL")

    // MARK: - 内部状态

    private var state: CameraConnectionState = .disconnected
    private var liveViewTask: Task<Void, Never>?
    private var frameNumber: UInt64 = 0
    private var captureCount: UInt32 = 0

    private var eventContinuations: [UUID: AsyncStream<CameraEvent>.Continuation] = [:]
    private var frameContinuations: [UUID: AsyncStream<Data>.Continuation] = [:]

    // MARK: - 协议属性

    public nonisolated var events: AsyncStream<CameraEvent> {
        AsyncStream { continuation in
            let id = UUID()
            Task { await self.addEventContinuation(id: id, continuation: continuation) }
            continuation.onTermination = { _ in
                Task { await self.removeEventContinuation(id: id) }
            }
        }
    }

    public nonisolated var liveViewFrames: AsyncStream<Data> {
        AsyncStream(bufferingPolicy: .bufferingNewest(3)) { continuation in
            let id = UUID()
            Task { await self.addFrameContinuation(id: id, continuation: continuation) }
            continuation.onTermination = { _ in
                Task { await self.removeFrameContinuation(id: id) }
            }
        }
    }

    public var connectionState: CameraConnectionState { state }

    public init() {}

    // MARK: - 订阅管理

    private func addEventContinuation(id: UUID, continuation: AsyncStream<CameraEvent>.Continuation) {
        eventContinuations[id] = continuation
    }
    private func removeEventContinuation(id: UUID) {
        eventContinuations.removeValue(forKey: id)
    }
    private func addFrameContinuation(id: UUID, continuation: AsyncStream<Data>.Continuation) {
        frameContinuations[id] = continuation
    }
    private func removeFrameContinuation(id: UUID) {
        frameContinuations.removeValue(forKey: id)
    }
    private func emit(_ event: CameraEvent) {
        for c in eventContinuations.values { c.yield(event) }
    }

    private func setState(_ new: CameraConnectionState) {
        guard new != state else { return }
        state = new
        Log.camera.debug("[Mock] 状态 → \(new.rawValue)")
    }

    // MARK: - 连接

    public func connect() async throws {
        setState(.searching)
        try await sleep(connectDelay)
        if let e = connectError {
            setState(.disconnected)
            Log.camera.warn("[Mock] connect 注入失败: \(e.localizedDescription)")
            throw e
        }
        setState(.connecting)
        try await sleep(connectDelay)
        setState(.connected)
        Log.camera.info("[Mock] 已连接 \(mockDevice.model) (\(mockDevice.uuid))")
        emit(.connected(mockDevice))
    }

    public func disconnect() async {
        liveViewTask?.cancel(); liveViewTask = nil
        setState(.disconnected)
        Log.camera.info("[Mock] 已断开")
        emit(.disconnected(reason: "主动断开"))
    }

    // MARK: - LiveView

    public func startLiveView() async throws {
        guard state == .connected else {
            if state == .liveView { return }
            throw BoothError.liveViewFailed("[Mock] 相机未连接")
        }
        setState(.liveView)
        liveViewTask?.cancel()
        liveViewTask = Task { [weak self] in
            while !Task.isCancelled {
                guard let self else { return }
                let frame = await self.nextFrame()
                if let frame { await self.broadcastFrame(frame) }
                try? await Task.sleep(nanoseconds: UInt64(max(0.01, await self.frameInterval) * 1_000_000_000))
            }
        }
        Log.camera.info("[Mock] LiveView 已开启")
    }

    public func stopLiveView() async {
        liveViewTask?.cancel(); liveViewTask = nil
        if state == .liveView { setState(.connected) }
        Log.camera.info("[Mock] LiveView 已停止")
    }

    private func nextFrame() -> Data? {
        frameNumber += 1
        return MockImageFactory.liveViewJPEG(frame: frameNumber)
    }

    private func broadcastFrame(_ data: Data) {
        for c in frameContinuations.values { c.yield(data) }
    }

    // MARK: - 拍照

    public func capture() async throws -> CameraCapture {
        guard state == .connected || state == .liveView else {
            throw BoothError.captureFailed("[Mock] 相机未连接（状态 \(state.rawValue)）")
        }
        try await sleep(captureDelay)
        if let e = captureError {
            captureError = nil   // 一次性注入
            Log.camera.warn("[Mock] capture 注入失败: \(e.localizedDescription)")
            throw e
        }
        captureCount += 1
        let handle = 1000 + captureCount
        emit(.objectAdded(handle: handle))
        let fileName = String(format: "P100%04d.JPG", captureCount)
        guard let data = MockImageFactory.captureJPEG(sequence: captureCount) else {
            throw BoothError.captureFailed("[Mock] 合成 JPEG 生成失败")
        }
        Log.camera.info("[Mock] 拍照完成 \(fileName) \(data.count) 字节")
        return CameraCapture(handle: handle, data: data, fileName: fileName)
    }

    private func sleep(_ sec: TimeInterval) async throws {
        try await Task.sleep(nanoseconds: UInt64(max(sec, 0) * 1_000_000_000))
    }
}

// MARK: - 合成 JPEG 工厂

/// CoreGraphics 渐变 + CoreText 帧号 → JPEG。
/// 尺寸刻意小于真机：LiveView 1280×720（真机约 960×640~1920×1080）、
/// 成片 1920×1280（真机 6000×4000，太大拖慢测试/UI，宽高比 3:2 保持一致）。
public enum MockImageFactory {

    public static func liveViewJPEG(frame: UInt64) -> Data? {
        // 色相随帧号转动，肉眼/断言可区分连续帧
        let hue1 = CGFloat(frame % 360) / 360.0
        let hue2 = CGFloat((frame + 120) % 360) / 360.0
        return makeJPEG(width: 1280, height: 720,
                        top: NSColorFromHue(hue1), bottom: NSColorFromHue(hue2),
                        label: "LIVE #\(frame)")
    }

    public static func captureJPEG(sequence: UInt32) -> Data? {
        let hue = CGFloat(sequence % 360) / 360.0
        return makeJPEG(width: 1920, height: 1280,
                        top: NSColorFromHue(hue), bottom: NSColorFromHue((hue + 0.33).truncatingRemainder(dividingBy: 1)),
                        label: "SHOT \(sequence)")
    }

    private static func NSColorFromHue(_ hue: CGFloat) -> CGColor {
        CGColor(srgbRed: red(hue), green: green(hue), blue: blue(hue), alpha: 1)
    }
    // 简易 HSV(h,0.6,0.9) → RGB（避免引入 AppKit）
    private static func red(_ h: CGFloat) -> CGFloat { hsv(h, offset: 0) }
    private static func green(_ h: CGFloat) -> CGFloat { hsv(h, offset: 2.0 / 3.0) }
    private static func blue(_ h: CGFloat) -> CGFloat { hsv(h, offset: 1.0 / 3.0) }
    private static func hsv(_ h: CGFloat, offset: CGFloat) -> CGFloat {
        let x = ((h + offset).truncatingRemainder(dividingBy: 1)) * 6
        let c: CGFloat = 0.9 * 0.6
        let m: CGFloat = 0.9 - c
        let xx = c * (1 - abs(x.truncatingRemainder(dividingBy: 2) - 1))
        switch Int(x) % 6 {
        case 0: return CGFloat(c + m)
        case 1: return CGFloat(xx + m)
        case 2: return CGFloat(m)
        case 3: return CGFloat(m)
        case 4: return CGFloat(xx + m)
        default: return CGFloat(c + m)
        }
    }

    private static func makeJPEG(width: Int, height: Int,
                                 top: CGColor, bottom: CGColor, label: String) -> Data? {
        guard let space = CGColorSpace(name: CGColorSpace.sRGB),
              let ctx = CGContext(data: nil, width: width, height: height,
                                  bitsPerComponent: 8, bytesPerRow: 0, space: space,
                                  bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue) else { return nil }

        // 渐变背景
        let gradient = CGGradient(colorsSpace: space, colors: [top, bottom] as CFArray, locations: [0, 1])!
        ctx.drawLinearGradient(gradient,
                               start: CGPoint(x: 0, y: 0),
                               end: CGPoint(x: 0, y: CGFloat(height)),
                               options: [])

        // 帧号文字（CoreText，避免 AppKit 依赖）
        let font = CTFontCreateWithName("Menlo-Bold" as CFString, CGFloat(height) / 10, nil)
        // CoreText 属性字典（不引入 AppKit 的 NSAttributedString.Key.foregroundColor）
        let attrs = [
            kCTFontAttributeName: font,
            kCTForegroundColorAttributeName: CGColor(gray: 1, alpha: 1),
        ] as CFDictionary
        let attrStr = CFAttributedStringCreate(nil, label as CFString, attrs)!
        let line = CTLineCreateWithAttributedString(attrStr)
        // bitmap context 原点在左下，文字矩阵翻转使其正立
        ctx.textMatrix = CGAffineTransform(scaleX: 1, y: -1)
        ctx.textPosition = CGPoint(x: CGFloat(width) * 0.06, y: CGFloat(height) * 0.1)
        CTLineDraw(line, ctx)

        guard let image = ctx.makeImage() else { return nil }
        let data = NSMutableData()
        guard let dest = CGImageDestinationCreateWithData(data as CFMutableData, "public.jpeg" as CFString, 1, nil)
        else { return nil }
        CGImageDestinationAddImage(dest, image, [kCGImageDestinationLossyCompressionQuality: 0.8] as CFDictionary)
        guard CGImageDestinationFinalize(dest) else { return nil }
        return data as Data
    }
}
