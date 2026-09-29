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
                Text("🖨️")
                    .font(.system(size: 110))
                    .offset(y: bounceUp ? -14 : 0)
                    .animation(.easeInOut(duration: 0.7).repeatForever(autoreverses: true), value: bounceUp)
                Text("打印中，请稍候")
                    .font(theme.titleFont(40))
                    .foregroundStyle(theme.textColor)
                Text("正在为你打印 \(copies) 张照片 🎀")
                    .font(theme.bodyFont(22))
                    .foregroundStyle(theme.textSecondaryColor)
            }
        }
        .onAppear { bounceUp = true }
    }
}
