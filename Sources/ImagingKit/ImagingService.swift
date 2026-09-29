import CoreGraphics
import CoreImage
import Foundation
import BoothCore

// ============================================================
// ImagingService — 修图合成管线（SPEC §6，契约见 Protocols.swift）
//
// 管线：解码定向 → 自动调色 → 美肤 → 换背景 → 排版（单张/拼版）
//       → 边框/水印 → 打印位图 + 展示位图 + 原图落盘
//
// 设计要点：
//  - 每步可独立开关（ConfigStore.shared 的 imaging 段驱动）
//  - 任一步失败降级跳过不阻断，只记日志；只有"无输入 / 全部解码失败 /
//    打印位图写盘失败"才抛错
//  - 换背景能力由外部注入 segmenter（App 层传 VisionKit 实现）；
//    为 nil 且配置开启时降级跳过并记日志
//  - 本类型是 struct、非 MainActor，async 入口自动跑在后台线程，
//    大图处理不会阻塞 UI
// ============================================================

public struct ImagingService: ImagingServing {
    /// 人像分割器（换背景能力，可选注入）
    private let segmenter: (any PersonSegmenting)?
    /// 配置覆盖（测试/预览注入；nil 时读 ConfigStore.shared）
    private let configOverride: BoothConfig.ImagingConf?
    /// 主题目录覆盖（测试注入；nil 时用 BoothPaths.themesDir）
    private let themesDirOverride: URL?

    public init(segmenter: (any PersonSegmenting)? = nil) {
        self.init(segmenter: segmenter, configOverride: nil, themesDirOverride: nil)
    }

    /// 完整注入入口（测试专用：覆盖配置与主题目录，避免污染真实用户目录）
    init(segmenter: (any PersonSegmenting)?,
         configOverride: BoothConfig.ImagingConf?,
         themesDirOverride: URL?) {
        self.segmenter = segmenter
        self.configOverride = configOverride
        self.themesDirOverride = themesDirOverride
    }

    /// 水印/品牌条日期格式（拍照亭习惯带星期之外的纯日期）
    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    public func process(originals: [CameraCapture], mode: ShootMode, sessionDir: URL) async throws -> ProcessedPhoto {
        let pipelineStart = CFAbsoluteTimeGetCurrent()
        Log.imaging.info("修图管线开始: 模式=\(mode.kind.rawValue) 输入=\(originals.count)张 目录=\(sessionDir.lastPathComponent)")
        guard !originals.isEmpty else {
            throw BoothError.imagingFailed("无输入原图")
        }

        let conf: BoothConfig.ImagingConf
        if let configOverride {
            conf = configOverride
        } else {
            conf = await ConfigStore.shared.config.imaging
        }
        let themeDir = (themesDirOverride ?? BoothPaths.themesDir)
            .appendingPathComponent(conf.themeName, isDirectory: true)
        let dateText = Self.dateFormatter.string(from: Date())
        // 整条管线共享一个 CIContext（GPU 渲染；创建一次开销可控）
        let ciContext = CIContext(options: [.cacheIntermediates: false])

        try FileManager.default.createDirectory(at: sessionDir, withIntermediateDirectories: true)

        // MARK: ① 原图落盘 + 解码定向
        var photos: [CGImage] = []
        var originalURLs: [URL] = []
        for (index, capture) in originals.enumerated() {
            let stepStart = CFAbsoluteTimeGetCurrent()
            // 原图落盘：sessionDir/original-<序号>-<相机文件名>
            let safeName = capture.fileName.replacingOccurrences(of: "/", with: "_")
            let originalURL = sessionDir.appendingPathComponent("original-\(index + 1)-\(safeName)")
            do {
                try capture.data.write(to: originalURL, options: .atomic)
                originalURLs.append(originalURL)
            } catch {
                // 落盘失败不阻断修图（原图已在内存），但记日志备查
                Log.imaging.warn("原图落盘失败(第\(index + 1)张): \(error.localizedDescription)")
            }
            do {
                let img = try PipelineCore.decodeOriented(capture.data)
                photos.append(img)
                Log.imaging.debug("解码定向 第\(index + 1)张 \(img.width)x\(img.height) \(elapsedMs(stepStart))ms")
            } catch {
                Log.imaging.error("解码失败跳过(第\(index + 1)张 \(capture.fileName)): \(error.localizedDescription)")
            }
        }
        guard !photos.isEmpty else {
            throw BoothError.imagingFailed("全部原图解码失败")
        }

        // MARK: ②③④ 每张依次 自动调色 → 美肤 → 换背景
        for i in photos.indices {
            var img = photos[i]

            if conf.autoColor {
                let stepStart = CFAbsoluteTimeGetCurrent()
                do {
                    img = try PipelineCore.autoColor(img, ctx: ciContext)
                    Log.imaging.debug("自动调色 第\(i + 1)张 \(elapsedMs(stepStart))ms")
                } catch {
                    Log.imaging.warn("自动调色失败降级原图(第\(i + 1)张): \(error.localizedDescription)")
                }
            }

            if conf.skinSmoothing, conf.skinStrength > 0 {
                let stepStart = CFAbsoluteTimeGetCurrent()
                do {
                    img = try PipelineCore.skinSmooth(img, strength: conf.skinStrength, ctx: ciContext)
                    Log.imaging.debug("美肤 第\(i + 1)张 强度=\(conf.skinStrength) \(elapsedMs(stepStart))ms")
                } catch {
                    Log.imaging.warn("美肤失败降级(第\(i + 1)张): \(error.localizedDescription)")
                }
            }

            if conf.replaceBackground {
                let stepStart = CFAbsoluteTimeGetCurrent()
                // 三重降级：无 segmenter / 主题无 background.png / 合成失败
                guard let segmenter else {
                    Log.imaging.warn("换背景已开启但未注入 segmenter，降级跳过")
                    photos[i] = img
                    continue
                }
                let bgURL = themeDir.appendingPathComponent("background.png")
                guard let background = PipelineCore.loadCGImage(bgURL) else {
                    Log.imaging.warn("主题[\(conf.themeName)]缺少 background.png，换背景降级跳过")
                    photos[i] = img
                    continue
                }
                do {
                    let matte = try await segmenter.segmentationMask(for: img)
                    img = try PipelineCore.replaceBackground(person: img, mask: matte, background: background, ctx: ciContext)
                    Log.imaging.debug("换背景 第\(i + 1)张 \(elapsedMs(stepStart))ms")
                } catch {
                    Log.imaging.warn("换背景失败降级保留原背景(第\(i + 1)张): \(error.localizedDescription)")
                }
            }

            photos[i] = img
        }

        // MARK: ⑤ 排版（单张裁切填充 / 拼版大头贴条）
        // 注意：边框叠加在排版之后执行 —— frame.png 是按最终 1200×1800 成片尺寸设计的
        let accent = PipelineCore.themeAccent(themeDir: themeDir)
        let layoutStart = CFAbsoluteTimeGetCurrent()
        var canvas: CGImage
        switch mode.kind {
        case .single:
            canvas = try PipelineCore.composeSingle(photos[0])
            Log.imaging.debug("排版 单张裁切填充 1200x1800 \(elapsedMs(layoutStart))ms")
        case .collage:
            if photos.count < mode.shots {
                Log.imaging.warn("拼版应收\(mode.shots)张实收\(photos.count)张，按实际张数排版")
            }
            canvas = try PipelineCore.composeCollage(photos: photos, themeDir: themeDir, accent: accent, dateText: dateText)
            Log.imaging.debug("排版 拼版\(photos.count)格大头贴条 \(elapsedMs(layoutStart))ms")
        }

        // MARK: ⑥ 边框 / 水印
        if conf.frame {
            let stepStart = CFAbsoluteTimeGetCurrent()
            let frame = PipelineCore.loadCGImage(themeDir.appendingPathComponent("frame.png"))
            if frame == nil {
                Log.imaging.warn("主题[\(conf.themeName)]缺少 frame.png，边框降级跳过（仅水印）")
            }
            // 拼版模式品牌条已含日期，右下角水印只在单张模式绘制
            canvas = try PipelineCore.overlayFrameAndWatermark(
                on: canvas, frame: frame, dateText: dateText, accent: accent,
                drawWatermark: conf.dateWatermark && mode.kind == .single
            )
            Log.imaging.debug("边框/水印 \(elapsedMs(stepStart))ms")
        } else if conf.dateWatermark, mode.kind == .single {
            // 边框关闭但水印开启时仍画水印
            canvas = try PipelineCore.overlayFrameAndWatermark(
                on: canvas, frame: nil, dateText: dateText, accent: accent, drawWatermark: true
            )
        }

        // MARK: 输出 print.jpg + display.jpg
        let outputStart = CFAbsoluteTimeGetCurrent()
        let printURL = sessionDir.appendingPathComponent("print.jpg")
        try PipelineCore.writeJPEG(canvas, to: printURL, quality: PipelineCore.printJPEGQuality, dpi: 300)
        let displayURL = sessionDir.appendingPathComponent("display.jpg")
        let display = try PipelineCore.scaledToLongEdge(canvas, PipelineCore.displayLongEdge)
        try PipelineCore.writeJPEG(display, to: displayURL, quality: PipelineCore.displayJPEGQuality, dpi: nil)
        Log.imaging.debug("输出 print.jpg/display.jpg \(elapsedMs(outputStart))ms")

        // 性能预算检查（SPEC §6：单张 <3s，拼版 <6s）
        let totalMs = elapsedMs(pipelineStart)
        let budget = mode.kind == .single ? 3000 : 6000
        if totalMs > budget {
            Log.imaging.warn("管线超预算: \(totalMs)ms > \(budget)ms")
        }
        Log.imaging.info("修图管线完成: 总耗时 \(totalMs)ms，产物 \(printURL.lastPathComponent)")

        return ProcessedPhoto(id: UUID(), printFile: printURL, displayFile: displayURL, originals: originalURLs)
    }

    /// 毫秒耗时
    private func elapsedMs(_ start: CFAbsoluteTime) -> Int {
        Int((CFAbsoluteTimeGetCurrent() - start) * 1000)
    }
}
