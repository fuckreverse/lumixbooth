import SwiftUI
import BoothCore
import BoothUI

/// 成片确认页：大图 + 滤镜选择条（可选）+ 打印（默认份数）/ 重拍 + iPad 引导文案
struct GuestReviewView: View {
    @Environment(\.boothTheme) private var theme
    let photo: ProcessedPhoto
    @ObservedObject var vm: GuestViewModel

    @State private var image: NSImage?

    var body: some View {
        ZStack {
            theme.backgroundColor.ignoresSafeArea()

            VStack(spacing: 18) {
                HStack(spacing: 10) {
                    Text("看看成片")
                    BoothIcon(emoji: "🎉", size: 42)
                }
                .font(theme.titleFont(40))
                .foregroundStyle(theme.textColor)

                // 成片大图（展示位图；换滤镜后 photoId 变化自然重载）
                ZStack {
                    if let image {
                        Image(nsImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .id(photo.id)   // 重打后新 id → 强制重建重读文件
                    } else {
                        BoothIcon(emoji: "🖼️", size: 84)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius, style: .continuous))
                .shadow(color: theme.textColor.opacity(0.12), radius: 20, y: 8)
                .padding(.horizontal, 60)

                // 拍后自选滤镜（配置关闭则不显示）
                if vm.filterSelection {
                    filterBar
                }

                Text("在 iPad 上确认打印，或点这里重拍")
                    .font(theme.bodyFont(20))
                    .foregroundStyle(theme.textSecondaryColor)

                HStack(spacing: 24) {
                    BoothSecondaryButton("重拍", emoji: "🔄") { vm.retake() }
                    if vm.showPrintButton {
                        BoothPrimaryButton("打印 \(vm.defaultCopies) 张", emoji: "🖨️") { vm.confirmPrint() }
                    }
                }
                .padding(.bottom, 36)
            }
            .padding(.top, 24)
        }
        .task(id: photo.id) { loadImage() }
    }

    /// 滤镜选择条：自适应网格排布，宽度够时单行、不够自动换行
    private var filterBar: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 96), spacing: 10)], spacing: 10) {
            ForEach(PhotoFilter.allCases, id: \.rawValue) { f in
                filterChip(f)
            }
        }
        .padding(.horizontal, 60)
    }

    private func filterChip(_ f: PhotoFilter) -> some View {
        let selected = vm.currentFilter == f
        return Button {
            vm.selectFilter(f)
        } label: {
            HStack(spacing: 6) {
                BoothIcon(emoji: f.emoji, size: 20)
                Text(f.displayName)
            }
            .font(theme.bodyFont(17, weight: .bold))
                .foregroundStyle(selected ? theme.textColor : theme.textSecondaryColor)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 999, style: .continuous)
                        .fill(selected ? theme.accentColor.opacity(0.22) : theme.backgroundSecondaryColor)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 999, style: .continuous)
                        .stroke(theme.accentColor, lineWidth: selected ? 3 : 0)
                )
        }
        .buttonStyle(BoothBounceStyle())
    }

    /// 读展示位图（本地文件，小图直读即可）
    private func loadImage() {
        image = NSImage(contentsOf: photo.displayFile)
        if image == nil {
            Log.ui.warn("成片展示图读取失败: \(photo.displayFile.path)")
        }
    }
}
