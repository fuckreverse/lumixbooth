import SwiftUI
import BoothUI

/// 错误 toast：顶部红色胶囊（failure 态期间展示，状态机自动回 idle 后消失）
struct FailureToast: View {
    @Environment(\.boothTheme) private var theme
    let message: String

    var body: some View {
        HStack(spacing: 10) {
            BoothIcon(emoji: "😵", size: 24)
            Text(message)
                .font(theme.bodyFont(20, weight: .bold))
                .lineLimit(2)
        }
        .foregroundStyle(theme.textOnAccentColor)
        .padding(.horizontal, 28).padding(.vertical, 14)
        .background(theme.dangerColor, in: Capsule())
        .shadow(color: theme.dangerColor.opacity(0.4), radius: 12, y: 6)
    }
}
