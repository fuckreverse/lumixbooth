import BoothCore
import CoreGraphics
import Foundation

// ============================================================
// 手部关键点几何模型 + 纯函数手势判定
//  - HandJoint：把 Vision 的 VNHumanHandPoseObservation.JointName
//    复刻成纯枚举，classify 不依赖 Vision 类型，方便单测
//  - 关键点坐标为 Vision 归一化坐标（0...1，原点左下）
// ============================================================

/// 手部 21 关键点（手腕 1 + 拇指 4 + 四指各 4）
public enum HandJoint: String, CaseIterable, Sendable, Hashable {
    case wrist

    // 命名对齐 Vision：拇指为 CMC/MP/IP/Tip（Vision 叫 thumbMP，不是 thumbMCP）
    case thumbCMC, thumbMP, thumbIP, thumbTip
    case indexMCP, indexPIP, indexDIP, indexTip
    case middleMCP, middlePIP, middleDIP, middleTip
    case ringMCP, ringPIP, ringDIP, ringTip
    case littleMCP, littlePIP, littleDIP, littleTip
}

/// 单根手指（thumb 即拇指）
public enum Finger: Sendable, Hashable {
    case thumb, index, middle, ring, little

    /// 该手指的指尖/指根(MCP)关节对
    /// （拇指用 thumbMCP 当"指根"参考，比 thumbCMC 更符合伸直几何）
    var tip: HandJoint {
        switch self {
        case .thumb:  return .thumbTip
        case .index: return .indexTip
        case .middle: return .middleTip
        case .ring:  return .ringTip
        case .little: return .littleTip
        }
    }

    var mcp: HandJoint {
        switch self {
        case .thumb:  return .thumbMP
        case .index: return .indexMCP
        case .middle: return .middleMCP
        case .ring:  return .ringMCP
        case .little: return .littleMCP
        }
    }
}

// MARK: - 判定几何小工具

enum HandGeometry {

    /// 两点距离（归一化坐标系）
    static func distance(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
        let dx = a.x - b.x
        let dy = a.y - b.y
        return (dx * dx + dy * dy).squareRoot()
    }

    /// 手指是否伸直：
    /// 指尖到 wrist 的距离 > MCP 到 wrist 的距离 × ratio（默认 1.5）
    /// （收拢时指尖折回掌侧，到 wrist 的距离几乎等于 MCP 的距离）
    static func isExtended(_ finger: Finger, joints: [HandJoint: CGPoint], ratio: CGFloat) -> Bool? {
        guard let wrist = joints[.wrist],
              let tip = joints[finger.tip],
              let mcp = joints[finger.mcp] else { return nil }   // 关键点缺失 → 无法判定
        let tipDist = distance(tip, wrist)
        let mcpDist = distance(mcp, wrist)
        guard mcpDist > 0 else { return nil }
        // 辅助条件：伸直时指尖必须比 MCP 更远离腕部（已蕴含在比值中），
        // 另外指尖 y 相对 MCP 的关系只作日志参考，不参与硬判定
        return tipDist > mcpDist * ratio
    }

    /// 两向量夹角（度）。spread 判定用：
    /// peace 要求食指与中指张开成 V 字，平行并拢不算
    static func angleDeg(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
        let dot = a.x * b.x + a.y * b.y
        let la = (a.x * a.x + a.y * a.y).squareRoot()
        let lb = (b.x * b.x + b.y * b.y).squareRoot()
        guard la > 0, lb > 0 else { return 0 }
        let cos = max(-1, min(1, dot / (la * lb)))
        return acos(cos) * 180 / .pi
    }
}

#if canImport(Vision)
import Vision

extension HandJoint {
    /// Vision 手部关节名 → HandJoint 显式映射。
    /// Vision 的 rawValue 是内部不透明键（如 VNHLKWRI），不能按 rawValue 字符串对应；
    /// 且 classic JointName 是 NS_TYPED_ENUM 导入的结构体，switch 需 default。
    /// 注意拇指的掌指关节在 Vision 叫 thumbMP（不是 thumbMCP）。
    static func from(vision name: VNHumanHandPoseObservation.JointName) -> HandJoint? {
        switch name {
        case .wrist: return .wrist
        case .thumbCMC: return .thumbCMC
        case .thumbMP: return .thumbMP
        case .thumbIP: return .thumbIP
        case .thumbTip: return .thumbTip
        case .indexMCP: return .indexMCP
        case .indexPIP: return .indexPIP
        case .indexDIP: return .indexDIP
        case .indexTip: return .indexTip
        case .middleMCP: return .middleMCP
        case .middlePIP: return .middlePIP
        case .middleDIP: return .middleDIP
        case .middleTip: return .middleTip
        case .ringMCP: return .ringMCP
        case .ringPIP: return .ringPIP
        case .ringDIP: return .ringDIP
        case .ringTip: return .ringTip
        case .littleMCP: return .littleMCP
        case .littlePIP: return .littlePIP
        case .littleDIP: return .littleDIP
        case .littleTip: return .littleTip
        default: return nil
        }
    }
}
#endif
