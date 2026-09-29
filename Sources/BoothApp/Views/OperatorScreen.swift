import SwiftUI
import BoothCore
import BoothUI

// ============================================================
// 操作员页：状态 / 设置 / 历史 / 日志 四页签（Esc 返回宾客大屏）
//  - 自定义主题页签条（不用原生 TabView：macOS TabView 的
//    StatefulTabContainer 在高频内容刷新 + 切页后会产生
//    AttributeGraph 依赖环，主线程陷入 print_cycle 死循环卡死）
// ============================================================
struct OperatorScreen: View {
    @Environment(\.boothTheme) private var theme
    @ObservedObject var composition: AppComposition

    @StateObject private var statusVM: OpStatusViewModel
    @StateObject private var settingsVM = OpSettingsViewModel()
    @StateObject private var historyVM: OpHistoryViewModel
    @StateObject private var logsVM = OpLogsViewModel()
    @StateObject private var healthVM: OpHealthViewModel

    /// 当前页签（VM 挂在本屏上，切页不销毁）
    @State private var tab: OpTab = .status

    enum OpTab: String, CaseIterable, Identifiable {
        case status, settings, history, logs
        var id: String { rawValue }
        var title: String {
            switch self {
            case .status: return "状态"
            case .settings: return "设置"
            case .history: return "历史"
            case .logs: return "日志"
            }
        }
        var emoji: String {
            switch self {
            case .status: return "🩺"
            case .settings: return "⚙️"
            case .history: return "🖼️"
            case .logs: return "📄"
            }
        }
    }

    init(composition: AppComposition) {
        _composition = ObservedObject(wrappedValue: composition)
        _statusVM = StateObject(wrappedValue: OpStatusViewModel(
            camera: composition.camera, printer: composition.printer))
        _historyVM = StateObject(wrappedValue: OpHistoryViewModel(printer: composition.printer))
        _healthVM = StateObject(wrappedValue: OpHealthViewModel(health: composition.health,
                                                               printer: composition.printer))
    }

    var body: some View {
        VStack(spacing: 0) {
            // 顶部条：标题 + 返回大屏（每次返回都会重新上锁）
            HStack {
                HStack(spacing: 10) {
                    Text("操作员后台")
                        .font(theme.titleFont(30))
                        .foregroundStyle(theme.textColor)
                    BoothIcon(emoji: "🛠️", size: 32)
                }
                Spacer()
                if composition.isMock {
                    BoothStatusPill(emoji: "🧪", text: "Mock 模式", tint: theme.warningColor)
                }
                BoothSecondaryButton("返回大屏", emoji: "🔙") {
                    composition.showingOperator = false
                }
            }
            .padding(.horizontal, 28)
            .padding(.vertical, 16)

            // 自定义页签条（主题化，与宾客界面的胶囊风格一致）
            HStack(spacing: 8) {
                ForEach(OpTab.allCases) { t in
                    tabChip(t)
                }
                Spacer()
            }
            .padding(.horizontal, 28)
            .padding(.bottom, 14)

            // 页内容（switch 切换；VM 由本屏持有，切页状态不丢）
            Group {
                switch tab {
                case .status:
                    OpStatusTab(vm: statusVM, healthVM: healthVM,
                                serverRunning: composition.serverRunning,
                                iPadURL: composition.iPadURL)
                case .settings:
                    OpSettingsTab(vm: settingsVM, gate: composition.gate)
                case .history:
                    OpHistoryTab(vm: historyVM)
                case .logs:
                    OpLogsTab(vm: logsVM)
                }
            }
            .padding(.horizontal, 20)
            .animation(theme.bounce, value: tab)
        }
        .background(theme.backgroundColor.ignoresSafeArea())
        .task {
            statusVM.start()
            settingsVM.start()
            logsVM.start()
            historyVM.reload()
            healthVM.start()
        }
        // 返回宾客大屏：退订日志增量（Mock 相机逐帧打日志，不退订会持续攒批）
        .onDisappear { logsVM.stop() }
    }

    private func tabChip(_ t: OpTab) -> some View {
        let selected = tab == t
        return Button {
            withAnimation(theme.bounce) { tab = t }
        } label: {
            HStack(spacing: 6) {
                BoothIcon(emoji: t.emoji, size: 20)
                Text(t.title).font(theme.bodyFont(18, weight: .bold))
            }
            .foregroundStyle(selected ? theme.textOnAccentColor : theme.textColor)
            .padding(.horizontal, 20).padding(.vertical, 10)
            .background(selected ? theme.accentColor : theme.backgroundSecondaryColor,
                        in: Capsule())
            .overlay(Capsule().stroke(theme.accentSecondaryColor, lineWidth: selected ? 0 : 1.5))
        }
        .buttonStyle(BoothBounceStyle())
    }
}
