import AppKit
import CoreGraphics
import CoreImage
import Foundation
import BoothCore

// ============================================================
// ImagingService — 修图合成管线（SPEC §6，契约见 Protocols.swift）
//
// 管线：解码定向 → 自动调色 → 美肤 → 搞怪装饰 → 换背景 → 排版（单张/多布局拼版）
//       → 风格化滤镜 → 边框/水印 → 打印位图 + 展示位图 + 原图落盘
//
// 拍后重打（PhotoBoothProject 借鉴）：
//  - process 会额外落盘 print-base.jpg（未滤镜未边框的排版底图）
//  - applyFilter 基于 base 重打：换滤镜 → 重新叠边框/水印 → 覆写 print/display
//  - overlayQR 打印前把 /photo/{id} 下载链接印到成片右缘
//
// 设计要点：
//  - 每步可独立开关（ConfigStore.shared 的 imaging 段驱动）
//  - 任一步失败降级跳过不阻断，只记日志；只有“无输入 / 全部解码失败 /
//    打印位图写盘失败”才抛错
//  - 换背景能力由外部注入 segmenter（App 层传 VisionKit 实现）；
//    为 nil 且配置开启时降级跳过并记日志
//  - 搞怪装饰（形变/贴纸/滤镜/字幕）同理由外部注入 landmarker，
//    装饰在换背景之前：人像 matte 与形变后的像素保持对齐
//  - 本类型是 struct、非 MainActor，async 入口自动跑在后台线程，
//    大图处理不会阻塞 UI
// ============================================================

public struct ImagingService: ImagingServing {
    /// 人像分割器（换背景能力，可选注入）
    private let segmenter: (any PersonSegmenting)?
    /// 人脸关键点检测器（搞怪装饰能力，可选注入）
    private let landmarker: (any FaceLandmarking)?
    /// 配置覆盖（测试/预览注入；nil 时读 ConfigStore.shared）
    private let configOverride: BoothConfig.ImagingConf?
    /// 主题目录覆盖（测试注入；nil 时用 BoothPaths.themesDir）
    private let themesDirOverride: URL?
    /// 装饰模板目录覆盖（测试注入；nil 时用 BoothPaths.decorationsDir）
    private let decorationsDirOverride: URL?

    public init(segmenter: (any PersonSegmenting)? = nil,
                landmarker: (any FaceLandmarking)? = nil) {
        self.init(segmenter: segmenter, landmarker: landmarker,
                  configOverride: nil, themesDirOverride: nil, decorationsDirOverride: nil)
    }

    /// 完整注入入口（测试专用：覆盖配置与目录，避免污染真实用户目录）
    init(segmenter: (any PersonSegmenting)?,
         landmarker: (any FaceLandmarking)? = nil,
         configOverride: BoothConfig.ImagingConf?,
         themesDirOverride: URL?,
         decorationsDirOverride: URL? = nil) {
        self.segmenter = segmenter
        self.landmarker = landmarker
        self.configOverride = configOverride
        self.themesDirOverride = themesDirOverride
        self.decorationsDirOverride = decorationsDirOverride
    }

    /// 水印/品牌条日期格式（拍照亭习惯带星期之外的纯日期）
    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    public func process(originals: [CameraCapture], mode: ShootMode, sessionDir: URL,
                        filter: PhotoFilter? = nil) async throws -> ProcessedPhoto {
        let pipelineStart = CFAbsoluteTimeGetCurrent()
        Log.imaging.info("修图管线开始: 模式=\(mode.kind.rawValue) 布局=\(mode.layout.rawValue) 滤镜覆盖=\(filter.map { $0.rawValue } ?? "配置默认") 输入=\(originals.count)张 目录=\(sessionDir.lastPathComponent)")
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
        let decorationsDir = decorationsDirOverride ?? BoothPaths.decorationsDir
        let dateText = Self.dateFormatter.string(from: Date())
        // 整条管线共享一个 CIContext（GPU 渲染；创建一次开销可控）
        let ciContext = CIContext(options: [.cacheIntermediates: false])

        try FileManager.default.createDirectory(at: sessionDir, withIntermediateDirectories: true)

        // MARK: ① 原图落盘 + 解码定向
        var photos: [CGImage] = []
        var originalURLs: [URL] = []
        var decodedRaw: [CGImage] = []   // GIF 帧候选（未修饰原图；修饰后的 photos 不适合做动态图）
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
                decodedRaw.append(img)
                Log.imaging.debug("解码定向 第\(index + 1)张 \(img.width)x\(img.height) \(elapsedMs(stepStart))ms")
            } catch {
                Log.imaging.error("解码失败跳过(第\(index + 1)张 \(capture.fileName)): \(error.localizedDescription)")
            }
        }
        guard !photos.isEmpty else {
            throw BoothError.imagingFailed("全部原图解码失败")
        }

        // MARK: ②③④⑤ 每张依次 自动调色 → 美肤 → 装饰 → 换背景
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

            // MARK: ③.5 搞怪装饰（形变 → 贴纸 → 滤镜 → 字幕条）
            // 装饰在换背景之前：换背景的 matte 对形变后的像素重新生成，边缘对齐
            if !conf.decorationTemplate.isEmpty {
                let stepStart = CFAbsoluteTimeGetCurrent()
                if let template = DecorationCore.loadTemplate(named: conf.decorationTemplate,
                                                               decorationsDir: decorationsDir) {
                    if template.isEmpty {
                        Log.imaging.warn("装饰模板[\(conf.decorationTemplate)]内容为空，跳过")
                    } else if let landmarker {
                        do {
                            let faces = try await landmarker.detectFaces(in: img)
                            if faces.isEmpty, !template.warps.isEmpty || !template.stickers.isEmpty {
                                Log.imaging.warn("装饰：未检出人脸，形变/贴纸跳过（滤镜/字幕照常）")
                            }
                            img = try DecorationCore.apply(
                                img, template: template, faces: faces,
                                templateDir: DecorationCore.templateDir(named: conf.decorationTemplate,
                                                                        decorationsDir: decorationsDir),
                                ctx: ciContext)
                            Log.imaging.debug("装饰 第\(i + 1)张 模板=\(conf.decorationTemplate) 人脸=\(faces.count) \(elapsedMs(stepStart))ms")
                        } catch {
                            Log.imaging.warn("装饰失败降级(第\(i + 1)张): \(error.localizedDescription)")
                        }
                    } else {
                        Log.imaging.warn("装饰已开启但未注入 landmarker，降级跳过")
                    }
                } else {
                    Log.imaging.warn("装饰模板[\(conf.decorationTemplate)]不存在或损坏，装饰降级跳过")
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

        // MARK: ⑤ 排版（单张裁切填充 / 多布局拼版）
        // 边框在排版之后叠加，按最终画布方向挑选素材。
        let accent = PipelineCore.themeAccent(themeDir: themeDir)
        let layoutStart = CFAbsoluteTimeGetCurrent()
        var canvas: CGImage
        switch mode.kind {
        case .single:
            canvas = try PipelineCore.composeSingle(photos[0])
            Log.imaging.debug("排版 单张裁切填充 \(canvas.width)x\(canvas.height) \(elapsedMs(layoutStart))ms")
        case .collage:
            if photos.count < mode.shots {
                Log.imaging.warn("拼版应收\(mode.shots)张实收\(photos.count)张，按实际张数排版")
            }
            canvas = try PipelineCore.composeCollage(photos: photos, layout: mode.layout,
                                                      themeDir: themeDir, accent: accent, dateText: dateText)
            Log.imaging.debug("排版 拼版\(mode.layout.rawValue)\(photos.count)格 \(elapsedMs(layoutStart))ms")
        }

        // MARK: ⑤b 排版底图落盘（拍后换滤镜重打用；失败只降级重打能力，不阻断）
        let baseURL = sessionDir.appendingPathComponent("print-base.jpg")
        do {
            try PipelineCore.writeJPEG(canvas, to: baseURL, quality: PipelineCore.printJPEGQuality, dpi: 300)
        } catch {
            Log.imaging.warn("排版底图落盘失败（拍后换滤镜将不可用）: \(error.localizedDescription)")
        }

        // MARK: ⑤c 滤镜 + ⑥ 边框/水印 + 输出（与 applyFilter 共用 finalize）
        // 拼版模式品牌条已含日期，右下角水印只在单张模式绘制
        let drawWatermark = conf.dateWatermark && mode.kind == .single
        // 选片页携滤镜出片时覆盖配置默认滤镜（REVIEW 页仍可重打）
        let effectiveFilter = filter ?? conf.defaultFilter
        let (printURL, displayURL) = try finalize(canvas: canvas,
                                                  filter: effectiveFilter,
                                                  conf: conf,
                                                  themeDir: themeDir,
                                                  accent: accent,
                                                  dateText: dateText,
                                                  sessionDir: sessionDir,
                                                  drawWatermark: drawWatermark,
                                                  ciContext: ciContext)

        // 性能预算检查（SPEC §6：单张 <3s，拼版 <6s）
        let totalMs = elapsedMs(pipelineStart)
        let budget = mode.kind == .single ? 3000 : 6000
        if totalMs > budget {
            Log.imaging.warn("管线超预算: \(totalMs)ms > \(budget)ms")
        }
        Log.imaging.info("修图管线完成: 总耗时 \(totalMs)ms，产物 \(printURL.lastPathComponent)")

        let hasBase = FileManager.default.fileExists(atPath: baseURL.path)

        // MARK: ⑤d GIF/Boomerang（拼版模式 + 配置开启才生成；失败只降级不阻断）
        var gifURL: URL? = nil
        if mode.kind == .collage, conf.generateGIF, decodedRaw.count >= 2 {
            let gifStart = CFAbsoluteTimeGetCurrent()
            let url = sessionDir.appendingPathComponent("boomerang.gif")
            do {
                try GIFCore.encodeBoomerang(frames: decodedRaw, to: url)
                gifURL = url
                Log.imaging.info("Boomerang GIF 生成完成: \(orderlessFrames(decodedRaw).count)帧 \(elapsedMs(gifStart))ms → boomerang.gif")
            } catch {
                Log.imaging.warn("Boomerang GIF 生成失败（QR 回退静态图）: \(error.localizedDescription)")
            }
        }

        return ProcessedPhoto(id: UUID(), printFile: printURL, displayFile: displayURL,
                              originals: originalURLs, baseFile: hasBase ? baseURL : nil,
                              gifFile: gifURL)
    }

    /// 帧计数日志辅助（防止内联表达式过长）
    private func orderlessFrames(_ frames: [CGImage]) -> [CGImage] { frames }

    // MARK: - 拍后换滤镜重打（协议扩展的真实现）

    public func applyFilter(_ filter: PhotoFilter, to photo: ProcessedPhoto, sessionDir: URL) async throws -> ProcessedPhoto {
        let start = CFAbsoluteTimeGetCurrent()
        guard let baseURL = photo.baseFile ?? fallbackBaseURL(for: photo) else {
            // 无底图：不支持重打，原样返回（调用方保持当前成片）
            Log.imaging.warn("换滤镜重打：无 print-base.jpg 底图，返回原成片")
            return photo
        }
        guard let base = PipelineCore.loadCGImage(baseURL) else {
            Log.imaging.warn("换滤镜重打：底图解码失败 \(baseURL.lastPathComponent)，返回原成片")
            return photo
        }
        let conf = await resolveConf()
        let themeDir = (themesDirOverride ?? BoothPaths.themesDir)
            .appendingPathComponent(conf.themeName, isDirectory: true)
        let accent = PipelineCore.themeAccent(themeDir: themeDir)
        let dateText = Self.dateFormatter.string(from: Date())
        // 水印判定沿用 process：多张原图 = 拼版（品牌条已含日期不画角标）
        let drawWatermark = conf.dateWatermark && photo.originals.count <= 1
        let ciContext = CIContext(options: [.cacheIntermediates: false])

        let (printURL, displayURL) = try finalize(canvas: base,
                                                  filter: filter,
                                                  conf: conf,
                                                  themeDir: themeDir,
                                                  accent: accent,
                                                  dateText: dateText,
                                                  sessionDir: sessionDir,
                                                  drawWatermark: drawWatermark,
                                                  ciContext: ciContext)
        Log.imaging.info("换滤镜重打完成: \(filter.rawValue) \(elapsedMs(start))ms → \(printURL.lastPathComponent)")
        // 新 id：新 /photo/{id} 地址，iPad 端 <img> 换 src 天然避开浏览器缓存
        return ProcessedPhoto(id: UUID(), printFile: printURL, displayFile: displayURL,
                              originals: photo.originals, baseFile: baseURL)
    }

    // MARK: - 打印 QR 叠印（协议扩展的真实现）

    public func overlayQR(content: String, on photo: ProcessedPhoto) async throws -> ProcessedPhoto {
        let start = CFAbsoluteTimeGetCurrent()
        guard let print = PipelineCore.loadCGImage(photo.printFile) else {
            Log.imaging.warn("QR 叠印：打印位图读取失败 \(photo.printFile.lastPathComponent)，用原图打印")
            return photo
        }
        let ciContext = CIContext(options: [.cacheIntermediates: false])
        let stamped = try PipelineCore.overlayQRCode(on: print, content: content, ctx: ciContext)
        let qrURL = photo.printFile.deletingLastPathComponent().appendingPathComponent("print-qr.jpg")
        try PipelineCore.writeJPEG(stamped, to: qrURL, quality: PipelineCore.printJPEGQuality, dpi: 300)
        Log.imaging.info("QR 叠印完成: \(content) \(elapsedMs(start))ms → \(qrURL.lastPathComponent)")
        var updated = photo
        updated.printFile = qrURL
        return updated
    }

    // MARK: - 拍后选片预览图（连拍完成后选片页显示用）

    /// 连拍原图 → 长边 480px 缩略 JPEG，落盘 sessionDir/shot-N.jpg。
    /// 单张解码/缩放失败降级 nil（选片页该格显示占位图）；全部失败返回空数组。
    public func writePreviews(originals: [CameraCapture], sessionDir: URL) async -> [URL?] {
        guard !originals.isEmpty else { return [] }
        try? FileManager.default.createDirectory(at: sessionDir, withIntermediateDirectories: true)
        var urls: [URL?] = []
        for (index, capture) in originals.enumerated() {
            let url = sessionDir.appendingPathComponent("shot-\(index + 1).jpg")
            do {
                let img = try PipelineCore.decodeOriented(capture.data)
                let small = try PipelineCore.scaledToLongEdge(img, 480)
                try PipelineCore.writeJPEG(small, to: url, quality: 0.8, dpi: nil)
                urls.append(url)
            } catch {
                Log.imaging.warn("选片预览生成失败(第\(index + 1)张): \(error.localizedDescription)")
                urls.append(nil)
            }
        }
        return urls
    }

    // MARK: - 内部共用

    /// 配置解析（覆盖优先）
    private func resolveConf() async -> BoothConfig.ImagingConf {
        if let configOverride { return configOverride }
        return await ConfigStore.shared.config.imaging
    }

    /// 兼容旧会话目录：printFile 同目录下找 print-base.jpg
    private func fallbackBaseURL(for photo: ProcessedPhoto) -> URL? {
        let url = photo.printFile.deletingLastPathComponent().appendingPathComponent("print-base.jpg")
        return FileManager.default.fileExists(atPath: url.path) ? url : nil
    }

    /// 收尾共用路径：风格化滤镜 → 边框/水印 → 写 print.jpg + display.jpg
    private func finalize(canvas: CGImage,
                          filter: PhotoFilter,
                          conf: BoothConfig.ImagingConf,
                          themeDir: URL,
                          accent: NSColor?,
                          dateText: String,
                          sessionDir: URL,
                          drawWatermark: Bool,
                          ciContext: CIContext) throws -> (print: URL, display: URL) {
        var image = canvas
        // 风格化滤镜（失败降级原图）
        if filter != .none {
            let stepStart = CFAbsoluteTimeGetCurrent()
            do {
                image = try PipelineCore.applyStyleFilter(image, filter: filter, ctx: ciContext)
                Log.imaging.debug("滤镜 \(filter.rawValue) \(elapsedMs(stepStart))ms")
            } catch {
                Log.imaging.warn("滤镜 \(filter.rawValue) 失败降级原图: \(error.localizedDescription)")
            }
        }
        // 边框 / 水印
        if conf.frame {
            let stepStart = CFAbsoluteTimeGetCurrent()
            let landscape = image.width > image.height
            let specificName = landscape ? "frame-landscape.png" : "frame-portrait.png"
            let specific = PipelineCore.loadCGImage(themeDir.appendingPathComponent(specificName))
            let generic = PipelineCore.loadCGImage(themeDir.appendingPathComponent("frame.png"))
            let frame = specific ?? generic.flatMap {
                ($0.width > $0.height) == landscape ? $0 : nil
            }
            if frame == nil {
                Log.imaging.warn("主题[\(conf.themeName)]缺少匹配画幅的边框，边框降级跳过（仅水印）")
            }
            image = try PipelineCore.overlayFrameAndWatermark(
                on: image, frame: frame, dateText: dateText, accent: accent,
                drawWatermark: drawWatermark)
            Log.imaging.debug("边框/水印 \(elapsedMs(stepStart))ms")
        } else if drawWatermark {
            // 边框关闭但水印开启时仍画水印
            image = try PipelineCore.overlayFrameAndWatermark(
                on: image, frame: nil, dateText: dateText, accent: accent, drawWatermark: true)
        }
        // 输出 print.jpg + display.jpg
        let outputStart = CFAbsoluteTimeGetCurrent()
        let printURL = sessionDir.appendingPathComponent("print.jpg")
        try PipelineCore.writeJPEG(image, to: printURL, quality: PipelineCore.printJPEGQuality, dpi: 300)
        let displayURL = sessionDir.appendingPathComponent("display.jpg")
        let display = try PipelineCore.scaledToLongEdge(image, PipelineCore.displayLongEdge)
        try PipelineCore.writeJPEG(display, to: displayURL, quality: PipelineCore.displayJPEGQuality, dpi: nil)
        Log.imaging.debug("输出 print.jpg/display.jpg \(elapsedMs(outputStart))ms")
        return (printURL, displayURL)
    }

    /// 毫秒耗时
    private func elapsedMs(_ start: CFAbsoluteTime) -> Int {
        Int((CFAbsoluteTimeGetCurrent() - start) * 1000)
    }
}
