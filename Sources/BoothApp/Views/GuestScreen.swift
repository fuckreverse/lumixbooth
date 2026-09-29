import SwiftUI
import BoothCore
import BoothUI

// ============================================================
// 宾客大屏：随 BoothState 切换页面（SPEC §3 状态机 ↔ §9 页面表）
// ============================================================
struct GuestScreen: View {
    @Environment(\.boothTheme) private var theme
    @ObservedObject var composition: AppComposition
    @ObservedObject var vm: GuestViewModel

    var body: some View {
        ZStack {
            content
                .transition(.opacity)

            // failure 态：顶部红色 toast（状态机几秒后自动回 idle）
            if case .failure(let message) = vm.state {
                VStack {
                    FailureToast(message: message)
                        .padding(.top, 28)
                    Spacer()
                }
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(theme.bounce, value: vm.state)
    }

    @ViewBuilder
    private var content: some View {
        switch vm.state {
        case .idle, .failure:
            // failure 时底层仍停留吸引页，toast 覆盖提示
            GuestIdleView(composition: composition, vm: vm)
        case .armed:
            GuestGuidanceView(stage: .armed, store: vm.liveView)
        case .gestureWait:
            GuestGuidanceView(stage: .gesture, store: vm.liveView)
        case .countdown(let n):
            GuestCountdownView(secondsLeft: n, store: vm.liveView)
        case .capturing(let shot, let total):
            GuestCapturingView(shot: shot, total: total, store: vm.liveView)
        case .processing:
            GuestProcessingView()
        case .review(let photo):
            GuestReviewView(photo: photo, vm: vm)
        case .printing(let copies):
            GuestPrintingView(copies: copies)
        }
    }
}
