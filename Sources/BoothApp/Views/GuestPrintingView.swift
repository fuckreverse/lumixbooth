import SwiftUI
import BoothUI

/// 打印中页：🖨️ + 份数提示（状态机打印完成后自动回 idle）
struct GuestPrintingView: View {
    @Environment(\.boothTheme) private var theme
    let copies: Int

    @State private var bounceUp = false

    var body: some View {
        ZStack {
            theme.backgroundColor.ignoresSafeArea()
            FloatingEmojis()
            VStack(spacing: 26) {
                BoothIcon(emoji: "🖨️", size: 116)
                    .offset(y: bounceUp ? -14 : 0)
                    .animation(.easeInOut(duration: 0.7).repeatForever(autoreverses: true), value: bounceUp)
                Text("已加入打印队列")
                    .font(theme.titleFont(40))
                    .foregroundStyle(theme.textColor)
                HStack(spacing: 6) {
                    Text("正在为你打印 \(copies) 张照片，可先让下一位开始拍照")
                    BoothIcon(emoji: "🎀", size: 24)
                }
                .font(theme.bodyFont(22))
                    .foregroundStyle(theme.textSecondaryColor)
            }
        }
        .onAppear { bounceUp = true }
    }
}
