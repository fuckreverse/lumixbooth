import SwiftUI
import BoothUI

/// 快门反馈页：白闪 + "第 shot/of 张 📸"
struct GuestCapturingView: View {
    @Environment(\.boothTheme) private var theme
    let shot: Int
    let total: Int
    @ObservedObject var store: LiveViewStore

    @State private var flash = true

    var body: some View {
        ZStack {
            LiveViewLayer(store: store)

            // 快门白闪：进入即满亮再淡出
            theme.backgroundSecondaryColor
                .ignoresSafeArea()
                .opacity(flash ? 1 : 0)

            VStack {
                Spacer()
                HStack(spacing: 8) {
                    Text(total > 1 ? "第 \(shot)/\(total) 张" : "拍照啦")
                    BoothIcon(emoji: "📸", size: 32)
                }
                .font(theme.bodyFont(30, weight: .bold))
                    .foregroundStyle(theme.textOnAccentColor)
                    .padding(.horizontal, 32).padding(.vertical, 14)
                    .background(theme.accentColor, in: Capsule())
                    .padding(.bottom, 56)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5).delay(0.1)) { flash = false }
        }
    }
}
