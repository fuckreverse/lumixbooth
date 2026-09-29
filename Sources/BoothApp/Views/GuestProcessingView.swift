import SwiftUI
import BoothUI

/// 修图中：旋转 ✨ + 文案
struct GuestProcessingView: View {
    @Environment(\.boothTheme) private var theme
    @State private var spin = false

    var body: some View {
        ZStack {
            theme.backgroundColor.ignoresSafeArea()
            FloatingEmojis()
            VStack(spacing: 26) {
                BoothIcon(emoji: "✨", size: 124)
                    .rotationEffect(.degrees(spin ? 360 : 0))
                    .animation(.linear(duration: 1.4).repeatForever(autoreverses: false), value: spin)
                HStack(spacing: 8) {
                    Text("正在修图")
                    BoothIcon(emoji: "✨", size: 40)
                }
                .font(theme.titleFont(40))
                    .foregroundStyle(theme.textColor)
                Text("变美需要一点点时间…")
                    .font(theme.bodyFont(22))
                    .foregroundStyle(theme.textSecondaryColor)
            }
        }
        .onAppear { spin = true }
    }
}
