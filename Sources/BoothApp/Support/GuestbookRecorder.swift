import Foundation
@preconcurrency import AVFoundation
import CoreGraphics
import AppKit
import BoothCore

// ============================================================
// 视频留言簿（婚礼场景，借鉴 Curator/DIY photo booth guestbook）：
//   Mac 相机（AVCaptureSession，独立于 LUMIX 拍照机）录制短视频，
//   落盘 guestbook/guestbook-<HHmmss>.mp4，
//   叠印祝福语（overlayText）由回放页 CSS 覆盖显示（非烘焙进视频，
//   换祝福语不用重录）。
//   iPad 打开 /guestbook 录制页：预览 + 录制按钮 + 倒计时结束；
//   回放列表页 /guestbook/list 由 /api/guestbook 提供清单。
// ============================================================

/// 留言簿录制器（Mac 端共享相机；一次仅一路会话）
final class GuestbookRecorder: @unchecked Sendable {
    static let shared = GuestbookRecorder()

    private let lock = NSLock()
    private let session = AVCaptureSession()
    private let movieOutput = AVCaptureMovieFileOutput()
    private let sessionQueue = DispatchQueue(label: "booth.guestbook")
    private var configured = false
    /// 当前录制中的输出文件（nil = 未在录）
    private var currentFile: URL?
    /// 录制开始时刻（限长守护任务用）
    private var guardTask: Task<Void, Never>?

    private init() {}

    /// 配置会话（首次调用时找前置/默认相机 + 麦克风；失败返回 false）
    func configure() -> Bool {
        lock.lock(); defer { lock.unlock() }
        if configured { return true }

        session.beginConfiguration()
        session.sessionPreset = .high

        // 视频：优先外接 USB 相机（面对宾客），回退内置
        let videoDevice = AVCaptureDevice.default(.external, for: .video, position: .unspecified)
            ?? AVCaptureDevice.default(for: .video)
        guard let videoDevice,
              let videoInput = try? AVCaptureDeviceInput(device: videoDevice),
              session.canAddInput(videoInput) else {
            session.commitConfiguration()
            Log.ui.error("留言簿：无可用视频输入设备")
            return false
        }
        session.addInput(videoInput)

        // 音频：留言必须能听见
        if let audioDevice = AVCaptureDevice.default(for: .audio),
           let audioInput = try? AVCaptureDeviceInput(device: audioDevice),
           session.canAddInput(audioInput) {
            session.addInput(audioInput)
        } else {
            Log.ui.warn("留言簿：无麦克风输入（仅录像无声）")
        }

        guard session.canAddOutput(movieOutput) else {
            session.commitConfiguration()
            Log.ui.error("留言簿：无法添加视频输出")
            return false
        }
        session.addOutput(movieOutput)
        session.commitConfiguration()

        session.startRunning()
        configured = true
        Log.ui.info("留言簿：相机会话已启动")
        return true
    }

    /// 停止会话（App 退出 / 配置关闭留言簿时）
    func shutdown() {
        lock.lock(); defer { lock.unlock() }
        stopInternal()
        guard configured else { return }
        sessionQueue.async { [session] in
            if session.isRunning { session.stopRunning() }
        }
        configured = false
    }

    /// MJPEG 预览流输出（供 /guestbook/preview 转发；返回 nil = 未配置）
    /// 说明：预览走 AVCaptureVideoDataOutput，每帧转 JPEG 由服务端分发
    func startPreview() -> Bool {
        guard configure() else { return false }
        // 会话已 running，预览由 PreviewHub 单独实现（见下）
        return true
    }

    /// 开始录制（maxSec 到自动停）。返回输出文件 URL；nil = 启动失败。
    func start(maxSec: Int) -> URL? {
        lock.lock(); defer { lock.unlock() }
        guard configured else { return nil }
        if currentFile != nil { return nil }   // 已在录（防并发）

        let stamp = Self.stampFormatter.string(from: Date())
        let file = BoothPaths.guestbookDir
            .appendingPathComponent("guestbook-\(stamp)-\(UUID().uuidString.prefix(6).lowercased()).mov")
        sessionQueue.async { [movieOutput] in
            movieOutput.startRecording(to: file, recordingDelegate: RecordingDelegate.shared)
        }
        currentFile = file
        // 限长守护：maxSec 后自动停（防宾客忘按停止）
        let deadlineNs = UInt64(max(1, maxSec)) * 1_000_000_000
        guardTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: deadlineNs)
            guard !Task.isCancelled else { return }
            self?.stop()
        }
        Log.ui.info("留言簿：开始录制 → \(file.lastPathComponent)（最长 \(maxSec)s）")
        return file
    }

    /// 停止录制。返回刚结束的文件（nil = 本来就没在录）
    @discardableResult
    func stop() -> URL? {
        lock.lock(); defer { lock.unlock() }
        return stopInternal()
    }

    private func stopInternal() -> URL? {
        guardTask?.cancel(); guardTask = nil
        let file = currentFile
        currentFile = nil
        if file != nil {
            sessionQueue.async { [movieOutput] in
                if movieOutput.isRecording { movieOutput.stopRecording() }
            }
            Log.ui.info("留言簿：停止录制 → \(file!.lastPathComponent)")
        }
        return file
    }

    /// 录制文件名时间戳（HHmmss）
    private static let stampFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HHmmss"
        return f
    }()

    /// 是否正在录制
    var isRecording: Bool {
        lock.lock(); defer { lock.unlock() }
        return currentFile != nil
    }
}

/// 录制完成代理（转 mp4 容器转换在 finish 后触发；mov → 保留原容器即可，QuickTime 兼容）
private final class RecordingDelegate: NSObject, AVCaptureFileOutputRecordingDelegate, @unchecked Sendable {
    static let shared = RecordingDelegate()

    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL,
                    from connections: [AVCaptureConnection], error: Error?) {
        if let error {
            Log.ui.warn("留言簿录制结束（有错误）: \(error.localizedDescription)")
        } else {
            Log.ui.info("留言簿录制完成: \(outputFileURL.lastPathComponent)")
        }
        // 通知状态（GuestbookRecorder.isRecording 已由 stop() 清；这里只记日志）
    }
}
