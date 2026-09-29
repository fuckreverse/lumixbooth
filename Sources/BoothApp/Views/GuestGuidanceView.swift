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
                        // 姿势引导示意图占位（主题 emoji 大字代替素材）
                        HStack(spacing: 22) {
                            Text(stage == .armed ? "🧍‍♀️" : "✌️").font(.system(size: 64))
                            Text(stage == .armed ? "🧍" : "👋").font(.system(size: 64))
                        }
                        Text(stage == .armed ? "站好啦，看着你啦 👀" : "比个耶 ✌️ 或挥手 👋 开始拍照")
                            .font(theme.bodyFont(26, weight: .bold))
                            .foregroundStyle(theme.textColor)
                    }
                }
                .padding(.bottom, 48)
            }
        }
    }
}
