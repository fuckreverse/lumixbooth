import SwiftUI
import AppKit
import BoothCore
import BoothUI
import ImagingKit
import CoreImage

// ============================================================
// 拍后选片页（SELECT 态）：选单张 / 选拼图布局 / 选修图风格 同页完成
// 左：实时预览大图（布局/单张/滤镜任一变化即时重合成）
// 右：连拍缩略图（点选单张）+ 布局样式条 + 滤镜风格条 + 确认按钮
// 预览复用 writePreviews 的 ~480px 小图 + composePreview 毫秒级合成
// ============================================================
struct GuestSelectView: View {
    @Environment(\.boothTheme) private var theme
    let selection: ShotSelection
    @ObservedObject var vm: GuestViewModel

    /// 当前点选的单张序号（nil = 整版拼图模式）
    @State private var picked: Int?
    /// 当前滤镜（选片页本地；出片时随指令提交）
    @State private var filter: PhotoFilter = .none
    /// 实时预览合成结果（NSImage）
    @State private var previewImage: NSImage?
    /// 合成序号：慢合成被新选择覆盖时丢弃（防闪烁错序）
    /// （@State 值拷贝，后台线程需引用类型才能读到最新值）
    @State private var tokenBox = PreviewTokenBox()

    var body: some View {
        ZStack {
            theme.backgroundColor.ignoresSafeArea()

            HStack(spacing: 0) {
                // 左：实时预览大图
                VStack(spacing: 12) {
                    HStack(spacing: 8) {
                        Text(picked != nil ? "就出这一张" : "就出这一版")
                        BoothIcon(emoji: picked != nil ? "💖" : "🖼️", size: 30)
                    }
                    .font(theme.titleFont(26))
                    .foregroundStyle(theme.textColor)

                    ZStack {
                        if let previewImage {
                            Image(nsImage: previewImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .transition(.opacity)
                        } else {
                            BoothIcon(emoji: "✨", size: 64)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius, style: .continuous))
                    .shadow(color: theme.textColor.opacity(0.14), radius: 24, y: 8)
                    .padding(.horizontal, 40)
                    .padding(.bottom, 24)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 20)

                // 右：选择面板
                VStack(alignment: .leading, spacing: 16) {
                    Text("挑一张喜欢的")
                        .font(theme.titleFont(30))
                        .foregroundStyle(theme.textColor)
                        .padding(.top, 24)

                    // 连拍缩略图（点选 = 只要那一张；再点取消）
                    HStack(spacing: 12) {
                        ForEach(Array(selection.previews.enumerated()), id: \.offset) { pair in
                            thumb(index: pair.offset, url: pair.element)
                        }
                    }

                    // 布局样式条
                    if vm.layoutSelectionShown {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("拼图样式")
                                .font(theme.bodyFont(16, weight: .bold))
                                .foregroundStyle(theme.textSecondaryColor)
                            VStack(spacing: 8) {
                                ForEach(CollageLayout.allCases, id: \.rawValue) { layout in
                                    layoutChip(layout)
                                }
                            }
                        }
                    }

                    // 修图风格条（与 REVIEW 页滤镜同款七档）
                    VStack(alignment: .leading, spacing: 8) {
                        Text("修图风格")
                            .font(theme.bodyFont(16, weight: .bold))
                            .foregroundStyle(theme.textSecondaryColor)
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 92), spacing: 8)], spacing: 8) {
                            ForEach(PhotoFilter.allCases, id: \.rawValue) { f in
                                filterChip(f)
                            }
                        }
                    }

                    Spacer()

                    // 出片 / 重拍
                    VStack(spacing: 12) {
                        BoothPrimaryButton(picked != nil ? "就选这张 💖" : "就选这些 💖") {
                            confirm()
                        }
                        BoothSecondaryButton("重拍", emoji: "🔄") { vm.retake() }
                    }
                    .padding(.bottom, 28)
                }
                .padding(.horizontal, 32)
                .frame(width: 430)
                .background(theme.backgroundSecondaryColor.opacity(0.5))
            }
        }
        .onAppear { filter = .none }
        // 任一选择变化 → 实时重合成预览（毫秒级）
        .task(id: previewKey) { renderPreview() }
        .onChange(of: vm.currentLayout) { _ in renderPreview() }
    }

    // 合成去重键：单张序号 / 布局 / 滤镜任一变化即触发
    private var previewKey: String {
        "\(picked ?? -1)|\(picked == nil ? vm.currentLayout.rawValue : "-")|\(filter.rawValue)"
    }

    // MARK: - 实时预览合成

    private func renderPreview() {
        tokenBox.value += 1
        let token = tokenBox.value
        let layout = vm.currentLayout
        let single = picked
        let f = filter
        let urls = selection.previews
        let bounce = theme.bounce
        let box = tokenBox   // 引用盒捕获到闭包（后台比对最新 token）
        Task.detached(priority: .userInitiated) {
            let cg = CIContext(options: [.cacheIntermediates: false])
            // 逐张解码预览小图（NSCache 缓存位图，重复合成只走一次解码）
            var photos: [CGImage] = []
            for url in urls {
                if let img = GuestSelectView.cachedCGImageBackground(url) {
                    photos.append(img)
                }
            }
            guard !photos.isEmpty else { return }
            do {
                let out = try PipelineCore.composePreview(photos: photos, layout: layout,
                                                          singleIndex: single, filter: f, ctx: cg)
                guard box.value == token else { return }   // 过期结果丢弃
                await MainActor.run { [weak box, bounce] in
                    guard box?.value == token else { return }   // 到主线程再查一次
                    let ns = NSImage(cgImage: out, size: NSSize(width: out.width, height: out.height))
                    withAnimation(bounce) { previewImage = ns }
                }
            } catch {
                Log.ui.warn("选片预览合成失败（降级旧预览）: \(error.localizedDescription)")
            }
        }
    }

    /// token 引用盒（@State 值拷贝，后台线程需引用类型才能读到最新值）
    final class PreviewTokenBox: @unchecked Sendable { var value = 0 }

    // MARK: - 缩略图

    @ViewBuilder
    private func thumb(index: Int, url: URL?) -> some View {
        let selected = picked == index
        Button {
            picked = selected ? nil : index   // 再点一次取消，回整版模式
        } label: {
            ZStack {
                if let nsImage = Self.cachedImage(url) {
                    Image(nsImage: nsImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    BoothIcon(emoji: "📷", size: 40)
                }
            }
            .frame(width: 86, height: 114)
            .background(theme.backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadiusSmall, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: theme.cornerRadiusSmall, style: .continuous)
                    .stroke(selected ? theme.accentColor : theme.accentSecondaryColor,
                            lineWidth: selected ? 4 : 2)
            )
            .overlay(alignment: .topTrailing) {
                Text("第\(index + 1)张")
                    .font(theme.bodyFont(12, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Capsule().fill(theme.textColor.opacity(0.55)))
                    .padding(4)
            }
            .scaleEffect(selected ? 1.06 : 1)
            .animation(theme.bounce, value: selected)
        }
        .buttonStyle(BoothBounceStyle())
    }

    // MARK: - 样式胶囊

    private func layoutChip(_ layout: CollageLayout) -> some View {
        let selected = picked == nil && vm.currentLayout == layout
        return Button {
            picked = nil   // 挑样式回整版模式
            vm.selectLayout(layout)
        } label: {
            HStack(spacing: 8) {
                BoothIcon(emoji: layout.emoji, size: 18)
                Text(layout.displayName)
                    .font(theme.bodyFont(16, weight: .bold))
                    .frame(maxWidth: .infinity, alignment: .leading)
                if selected { BoothIcon(emoji: "✓", size: 16) }
            }
            .foregroundStyle(selected ? theme.textColor : theme.textSecondaryColor)
            .padding(.horizontal, 14)
            .padding(.vertical, 9)
            .background(
                RoundedRectangle(cornerRadius: 999, style: .continuous)
                    .fill(selected ? theme.accentColor.opacity(0.25) : theme.backgroundColor)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 999, style: .continuous)
                    .stroke(theme.accentColor, lineWidth: selected ? 3 : 0)
            )
        }
        .buttonStyle(BoothBounceStyle())
    }

    private func filterChip(_ f: PhotoFilter) -> some View {
        let selected = filter == f
        return Button {
            filter = f
        } label: {
            HStack(spacing: 6) {
                BoothIcon(emoji: f.emoji, size: 16)
                Text(f.displayName)
            }
            .font(theme.bodyFont(14, weight: .bold))
            .foregroundStyle(selected ? theme.textColor : theme.textSecondaryColor)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 9)
            .background(
                RoundedRectangle(cornerRadius: 999, style: .continuous)
                    .fill(selected ? theme.accentColor.opacity(0.25) : theme.backgroundColor)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 999, style: .continuous)
                    .stroke(theme.accentColor, lineWidth: selected ? 3 : 0)
            )
        }
        .buttonStyle(BoothBounceStyle())
    }

    // MARK: - 确认

    private func confirm() {
        if let picked {
            vm.confirmSelection(kind: .single, indexes: [picked], filter: filter)
        } else {
            vm.confirmSelection(kind: .collage, indexes: [], filter: filter)
        }
    }

    // MARK: - 图片缓存（视图生命周期内不重复解码）

    private static let imageCache = NSCache<NSURL, NSImage>()
    static func cachedImage(_ url: URL?) -> NSImage? {
        guard let url else { return nil }
        if let hit = imageCache.object(forKey: url as NSURL) { return hit }
        guard let img = NSImage(contentsOf: url) else { return nil }
        imageCache.setObject(img, forKey: url as NSURL)
        return img
    }

    /// CGImage 缓存（预览合成管线用；NSCache 线程安全，后台线程直接调）
    private static let cgCache = NSCache<NSURL, CGImageWrapper>()
    nonisolated static func cachedCGImageBackground(_ url: URL?) -> CGImage? {
        guard let url else { return nil }
        if let hit = cgCache.object(forKey: url as NSURL) { return hit.image }
        guard let img = NSImage(contentsOf: url)?.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            return nil
        }
        cgCache.setObject(CGImageWrapper(image: img), forKey: url as NSURL)
        return img
    }

    private final class CGImageWrapper {
        let image: CGImage
        init(image: CGImage) { self.image = image }
    }
}
