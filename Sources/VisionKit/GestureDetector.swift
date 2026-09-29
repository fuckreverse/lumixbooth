import BoothCore
import CoreGraphics
import Foundation
import Vision

// ============================================================
// GestureDetector —— VNDetectHumanHandPoseRequest 单帧手势识别
//  - 输入：LiveView JPEG Data；输出：DetectedGesture?（未检出 nil）
//  - 连续帧防抖是 SessionEngine 的职责，本类只管单帧
//  - 判定逻辑抽成纯函数 classify(joints:)，与 Vision 解耦可单测
//  - 并发：Vision perform() 阻塞线程，整体放 Task.detached 执行，
//    调用方 await 即可，绝不阻塞调用方 executor
// ============================================================

public struct GestureDetector: GestureDetecting, Sendable {

    /// 指尖到 wrist 距离 / MCP 到 wrist 距离 的伸直阈值（> 判为伸直）
    public var extendedRatio: CGFloat
    /// 关键点最低置信度，低于视为缺失（"检测不到手或置信度 < 0.3 返回 nil"）
    public var minJointConfidence: Float
    /// peace 要求食指/中指张开的最小夹角（度），防"伸直但并拢"误判
    public var minSpreadAngleDeg: CGFloat

    public init(extendedRatio: CGFloat = 1.5,
                minJointConfidence: Float = 0.3,
                minSpreadAngleDeg: CGFloat = 10) {
        self.extendedRatio = extendedRatio
        self.minJointConfidence = minJointConfidence
        self.minSpreadAngleDeg = minSpreadAngleDeg
    }

    // MARK: - GestureDetecting

    public func detectGesture(in jpeg: Data) async -> DetectedGesture? {
        let start = CFAbsoluteTimeGetCurrent()

        // ① JPEG 解码 + 降采样（.up 方向，见 ImageSupport.swift）
        guard let raw = FrameImage.decode(jpeg: jpeg) else {
            Log.vision.debug("手势：JPEG 解码失败，返回 nil")
            return nil
        }
        let image = FrameImage.downscaleForDetection(raw)
        let decodeCost = CFAbsoluteTimeGetCurrent() - start

        // ② Vision 请求放 Task.detached（perform 阻塞线程）
        let gesture: DetectedGesture? = await Task.detached(priority: .userInitiated) {
            self.performHandPose(image: image)
        }.value

        let total = CFAbsoluteTimeGetCurrent() - start
        if let g = gesture {
            Log.vision.debug("手势命中 \(g.rawValue)，输入 \(image.width)×\(image.height)，解码 \(String(format: "%.1f", decodeCost * 1000))ms，总耗时 \(String(format: "%.1f", total * 1000))ms")
        } else {
            Log.vision.debug("手势未命中（无手/低置信度/不构成已知手势），耗时 \(String(format: "%.1f", total * 1000))ms")
        }
        return gesture
    }

    // MARK: - Vision 请求（在 detached 线程执行，返回值均为 Sendable）

    /// 同步执行手部关键点请求；返回值已剥离 Vision 类型
    private func performHandPose(image: CGImage) -> DetectedGesture? {
        let request = VNDetectHumanHandPoseRequest()
        let handler = VNImageRequestHandler(cgImage: image, options: [:])
        do {
            try handler.perform([request])
        } catch {
            Log.vision.debug("手势：Vision 请求失败 \(error.localizedDescription)")
            return nil
        }
        guard let observations = request.results, !observations.isEmpty else {
            return nil   // 画面中无手
        }

        // 多只手时逐个判定，先命中先返回
        for obs in observations {
            let joints = collectJoints(from: obs)
            if let g = Self.classify(joints: joints,
                                      extendedRatio: extendedRatio,
                                      minSpreadAngleDeg: minSpreadAngleDeg) {
                return g
            }
        }
        return nil
    }

    /// 收集单只手的 21 关键点：Vision 按"关节组"返回，
    /// recognizedPoints(.all) 取全部手指组，wrist 单独补取（低置信度关节直接丢弃）
    private func collectJoints(from obs: VNHumanHandPoseObservation) -> [HandJoint: CGPoint] {
        var joints: [HandJoint: CGPoint] = [:]
        if let rawPoints = try? obs.recognizedPoints(.all) {
            for (name, point) in rawPoints {
                guard let joint = HandJoint.from(vision: name),
                      point.confidence >= minJointConfidence else { continue }
                joints[joint] = point.location
            }
        }
        // .all 组不含 wrist，单独取
        if let wrist = try? obs.recognizedPoint(.wrist), wrist.confidence >= minJointConfidence {
            joints[.wrist] = wrist.location
        }
        return joints
    }

    // MARK: - 纯函数判定（单测主入口）

    /// 单帧手势判定：
    ///  - peace：食指、中指伸直且张开成 V，无名指、小指收拢，拇指任意
    ///  - openPalm：四指 + 拇指全部伸直
    ///  - 其余（含关键点缺失/手指状态矛盾）→ nil
    ///
    /// - Parameters:
    ///   - joints: 归一化关键点字典（Vision 坐标系，原点左下，0...1）
    ///   - extendedRatio: 伸直判定系数（指尖距离 > MCP 距离 × ratio）
    ///   - minSpreadAngleDeg: peace 的 V 字最小夹角
    public static func classify(joints: [HandJoint: CGPoint],
                                extendedRatio: CGFloat = 1.5,
                                minSpreadAngleDeg: CGFloat = 10) -> DetectedGesture? {
        // wrist 是一切距离的基准，缺了直接判定失败
        guard let wrist = joints[.wrist] else { return nil }

        // 四指状态；nil 表示关键点缺失 → 无法构成任何判定
        guard let index = HandGeometry.isExtended(.index, joints: joints, ratio: extendedRatio),
              let middle = HandGeometry.isExtended(.middle, joints: joints, ratio: extendedRatio),
              let ring = HandGeometry.isExtended(.ring, joints: joints, ratio: extendedRatio),
              let little = HandGeometry.isExtended(.little, joints: joints, ratio: extendedRatio),
              let indexTip = joints[.indexTip],
              let middleTip = joints[.middleTip] else { return nil }

        // ✌️：食指+中指伸直、张开、无名指+小指收拢（拇指任意，可缺失）
        if index, middle, !ring, !little {
            let vIndex = CGPoint(x: indexTip.x - wrist.x, y: indexTip.y - wrist.y)
            let vMiddle = CGPoint(x: middleTip.x - wrist.x, y: middleTip.y - wrist.y)
            if HandGeometry.angleDeg(vIndex, vMiddle) >= minSpreadAngleDeg {
                return .peace
            }
            // 伸直但并拢：既不是 peace 也不是 openPalm
            return nil
        }

        // 张开手掌：五指全伸直（拇指关节缺失时无法确认，按 nil 处理）
        if index, middle, ring, little,
           let thumb = HandGeometry.isExtended(.thumb, joints: joints, ratio: extendedRatio),
           thumb {
            return .openPalm
        }

        return nil
    }
}
