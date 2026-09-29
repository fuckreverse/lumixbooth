import SwiftUI
import BoothCore
import BoothUI

@main
struct BoothAppMain: App {
    @StateObject private var theme = ThemeProvider()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.boothTheme, theme.theme)
                .frame(minWidth: 900, minHeight: 640)
        }
        .windowStyle(.hiddenTitleBar)
    }
}

struct ContentView: View {
    @Environment(\.boothTheme) private var theme

    var body: some View {
        ZStack {
            theme.backgroundColor.ignoresSafeArea()
            FloatingEmojis()
            VStack(spacing: 28) {
                Text(theme.mascotEmoji).font(.system(size: 88))
                Text("LUMIX Photobooth").font(theme.titleFont(44)).foregroundStyle(theme.textColor)
                BoothStatusPill.camera(.disconnected, theme: theme)
                BoothPrimaryButton("开始拍照", emoji: "📸") {}
            }
        }
    }
}
