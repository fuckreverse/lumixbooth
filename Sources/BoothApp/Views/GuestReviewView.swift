import SwiftUI
import BoothCore
import BoothUI

/// 成片确认页：大图 + 打印（默认份数）/ 重拍 + iPad 引导文案
struct GuestReviewView: View {
    @Environment(\.boothTheme) private var theme
    let photo: ProcessedPhoto
    @ObservedObject var vm: GuestViewModel

    @State private var image: NSImage?

    var body: some View {
        ZStack {
            theme.backgroundColor.ignoresSafeArea()

            VStack(spacing: 22) {
                Text("看看成片 🎉")
                    .font(theme.titleFont(40))
                    .foregroundStyle(theme.textColor)

                // 成片大图（展示位图）
                ZStack {
                    if let image {
                        Image(nsImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } else {
                        Text("🖼️").font(.system(size: 80))
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius, style: .continuous))
                .shadow(color: theme.textColor.opacity(0.12), radius: 20, y: 8)
                .padding(.horizontal, 60)

                Text("在 iPad 上确认打印，或点这里重拍")
                    .font(theme.bodyFont(20))
                    .foregroundStyle(theme.textSecondaryColor)

                HStack(spacing: 24) {
                    BoothSecondaryButton("重拍", emoji: "🔄") { vm.retake() }
                    BoothPrimaryButton("打印 \(vm.defaultCopies) 张", emoji: "🖨️") { vm.confirmPrint() }
                }
                .padding(.bottom, 36)
            }
            .padding(.top, 24)
        }
        .task { loadImage() }
    }

    /// 读展示位图（本地文件，小图直读即可）
    private func loadImage() {
        image = NSImage(contentsOf: photo.displayFile)
        if image == nil {
            Log.ui.warn("成片展示图读取失败: \(photo.displayFile.path)")
        }
    }
}
