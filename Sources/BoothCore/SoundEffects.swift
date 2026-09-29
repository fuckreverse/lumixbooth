import Foundation
import AppKit

// ============================================================
// 提示音体系（借鉴 photobooth-oss / LumaBooth）：无音频资源文件，
// 运行时合成 WAV（零第三方依赖、无资源打包问题）+ NSSound 播放。
// 三种效果音：倒计时哔声 / 快门音 / 打印完成叮声，
// 开关与音量跟随 config.sounds（SoundConf）。
// ============================================================

/// 效果音种类
public enum SoundEffect: String, Sendable, CaseIterable {
    case countdownBeep   // 倒计时每秒哔声（短促提示）
    case shutter         // 快门咔嚓（两段点击）
    case printDone       // 打印完成叮声（长衰减正弦）
}

/// 效果音播放器（全局单例；线程安全：合成/缓存走锁，播放交给 NSSound）
public final class SoundEffects: @unchecked Sendable {
    public static let shared = SoundEffects()
    private let lock = NSLock()
    private var cache: [SoundEffect: NSSound] = [:]
    private init() {}

    /// 按配置播放效果音（conf.enabled=false 或对应子开关关闭时静默跳过）
    public func play(_ effect: SoundEffect, conf: BoothConfig.SoundConf) {
        let on: Bool
        switch effect {
        case .countdownBeep: on = conf.enabled && conf.countdownBeep
        case .shutter:       on = conf.enabled && conf.shutterSound
        case .printDone:     on = conf.enabled && conf.printDoneSound
        }
        guard on else { return }
        guard let sound = cachedSound(effect) else {
            Log.core.warn("效果音合成失败: \(effect.rawValue)")
            return
        }
        sound.volume = Float(min(max(conf.volume, 0), 1))
        sound.play()
    }

    /// 取缓存 NSSound（首次调用时合成 WAV 并构造）
    private func cachedSound(_ effect: SoundEffect) -> NSSound? {
        lock.lock(); defer { lock.unlock() }
        if let s = cache[effect] { return s }
        guard let s = try? NSSound(data: Self.synthesizeWAV(effect)) else { return nil }
        cache[effect] = s
        return s
    }
}

// MARK: - WAV 合成（纯函数，可单测）

extension SoundEffects {

    /// 合成 16-bit 单声道 44.1kHz PCM WAV
    public static func synthesizeWAV(_ effect: SoundEffect, sampleRate: Int = 44_100) throws -> Data {
        let samples: [Float] = pcmSamples(effect)
        return wavContainer(samples: samples, sampleRate: sampleRate)
    }

    /// 各效果音的采样序列（Float [-1, 1]）
    static func pcmSamples(_ effect: SoundEffect) -> [Float] {
        switch effect {
        case .countdownBeep: return beep()
        case .shutter: return shutter()
        case .printDone: return ding()
        }
    }

    /// 哔声：880Hz / 90ms，5ms 起音 + 线性衰减
    static func beep(duration: Double = 0.09, freq: Double = 880) -> [Float] {
        let n = Int(duration * 44_100)
        return (0..<n).map { i in
            let t = Double(i) / 44_100
            let phase = 2 * .pi * freq * t
            // 起音 5ms 线性升，随后线性衰减到 0
            let attack = min(t / 0.005, 1)
            let decay = 1 - (t - 0.005) / (duration - 0.005)
            return Float(sin(phase) * attack * max(decay, 0) * 0.55)
        }
    }

    /// 快门：两段短促咔哒（1600Hz 急衰减，间隔 40ms）
    static func shutter() -> [Float] {
        var out: [Float] = []
        out += click(freq: 1600, duration: 0.02)
        out += [Float](repeating: 0, count: Int(0.04 * 44_100))
        out += click(freq: 1100, duration: 0.03)
        return out
    }

    /// 单次咔哒：指数衰减正弦
    static func click(freq: Double, duration: Double) -> [Float] {
        let n = Int(duration * 44_100)
        return (0..<n).map { i in
            let t = Double(i) / 44_100
            let env = exp(-t / (duration / 3))   // 急速衰减
            return Float(sin(2 * .pi * freq * t) * env * 0.7)
        }
    }

    /// 叮声：E6 1318.5Hz 长衰减 + 少量二次谐波（像门铃/完成音）
    static func ding(duration: Double = 0.4) -> [Float] {
        let n = Int(duration * 44_100)
        return (0..<n).map { i in
            let t = Double(i) / 44_100
            let env = exp(-t / (duration / 2.5))
            let base = sin(2 * .pi * 1318.5 * t)
            let harm = 0.25 * sin(2 * .pi * 1318.5 * 2 * t)
            return Float((base + harm) * env * 0.5)
        }
    }

    /// PCM 采样 → 完整 WAV 容器（RIFF 头 + 16-bit 量化）
    static func wavContainer(samples: [Float], sampleRate: Int) -> Data {
        var pcm = Data(capacity: samples.count * 2)
        for s in samples {
            let clamped = max(-1, min(1, s))
            var v = Int16(clamped * Float(Int16.max))
            pcm.append(Data(bytes: &v, count: 2))
        }
        let byteRate = UInt32(sampleRate * 2)          // 16-bit 单声道
        let blockSize: UInt16 = 2
        var data = Data()
        func le32(_ v: UInt32) -> Data { withUnsafeBytes(of: v.littleEndian) { Data($0) } }
        func le16(_ v: UInt16) -> Data { withUnsafeBytes(of: v.littleEndian) { Data($0) } }
        data.append(Data("RIFF".utf8))
        data.append(le32(UInt32(36 + pcm.count)))       // 文件总长 - 8
        data.append(Data("WAVE".utf8))
        data.append(Data("fmt ".utf8))
        data.append(le32(16))                           // fmt 段长度
        data.append(le16(1))                            // PCM
        data.append(le16(1))                            // 单声道
        data.append(le32(UInt32(sampleRate)))
        data.append(le32(byteRate))
        data.append(le16(blockSize))
        data.append(le16(16))                           // 位深
        data.append(Data("data".utf8))
        data.append(le32(UInt32(pcm.count)))
        data.append(pcm)
        return data
    }
}
