import SwiftUI
import BoothUI

/// 姿势引导 / 手势等待页：LiveView 全屏 + 中央底部提示卡 + 姿势引导示意（emoji 占位素材）
struct GuestGuidanceView: View {
    enum Stage {
        case armed     // 人已进入画面，等姿势就绪
        case gesture   // 姿势就绪，等手势触发
    }

    @Environment(\.boothTheme) private var theme
    let stage: Stage
    @ObservedObject var store: LiveViewStore

    var body: some View {
        ZStack {
            LiveViewLayer(store: store)

            VStack {
                Spacer()
                BoothCard {
                    VStack(spacing: 12) {
                        // 姿势引导示意图（主题插画，无主题图回退 emoji）
                        HStack(spacing: 26) {
                            BoothIcon(emoji: stage == .armed ? "🧍‍♀️" : "✌️", size: 72)
                            BoothIcon(emoji: stage == .armed ? "🧍" : "👋", size: 72)
                        }
                        HStack(spacing: 6) {
                            if stage == .armed {
                                Text("站好啦，看着你啦")
                                BoothIcon(emoji: "👀", size: 26)
                            } else {
                                Text("比个耶")
                                BoothIcon(emoji: "✌️", size: 26)
                                Text("或挥手")
                                BoothIcon(emoji: "👋", size: 26)
                                Text("开始拍照")
                            }
                        }
                        .font(theme.bodyFont(26, weight: .bold))
                        .foregroundStyle(theme.textColor)
                    }
                }
                .padding(.bottom, 48)
            }
        }
    }
}
