import SwiftUI
import BoothUI

/// LiveView 画面层：最新帧 + 镜像翻转（像镜子），无帧时显示等待占位
struct LiveViewLayer: View {
    @Environment(\.boothTheme) private var theme
    @ObservedObject var store: LiveViewStore

    var body: some View {
        ZStack {
            theme.backgroundColor.ignoresSafeArea()
            if let image = store.image {
                Image(nsImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .scaleEffect(x: -1, y: 1)   // 镜像：像照镜子
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                VStack(spacing: 16) {
                    BoothIcon(emoji: "📷", size: 76)
                    Text("等待相机画面…")
                        .font(theme.bodyFont(24))
                        .foregroundStyle(theme.textSecondaryColor)
                }
            }
        }
    }
}
