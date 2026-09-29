import SwiftUI
import BoothUI

/// 倒计时页：LiveView 全屏 + 弹性大数字 + 最后 1s 柔光白闪（模拟闪光灯）
struct GuestCountdownView: View {
    @Environment(\.boothTheme) private var theme
    let secondsLeft: Int
    @ObservedObject var store: LiveViewStore

    @State private var flash = false

    var body: some View {
        ZStack {
            LiveViewLayer(store: store)

            CountdownNumber(secondsLeft)
                .animation(theme.bounce, value: secondsLeft)

            // 柔光白闪（最后 1s 触发）
            theme.backgroundSecondaryColor
                .ignoresSafeArea()
                .opacity(flash ? 0.85 : 0)
        }
        .onAppear { triggerFlashIfNeeded() }
        .onChange(of: secondsLeft) { _, _ in triggerFlashIfNeeded() }
    }

    private func triggerFlashIfNeeded() {
        guard secondsLeft == 1 else { return }
        withAnimation(.easeOut(duration: 0.15)) { flash = true }
        withAnimation(.easeOut(duration: 0.6).delay(0.15)) { flash = false }
    }
}
