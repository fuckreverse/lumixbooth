import SwiftUI
import BoothCore
import BoothUI

// ============================================================
// 操作员页：状态 / 设置 / 历史 / 日志 四页签（Esc 返回宾客大屏）
// ============================================================
struct OperatorScreen: View {
    @Environment(\.boothTheme) private var theme
    @ObservedObject var composition: AppComposition

    @StateObject private var statusVM: OpStatusViewModel
    @StateObject private var settingsVM = OpSettingsViewModel()
    @StateObject private var historyVM: OpHistoryViewModel
    @StateObject private var logsVM = OpLogsViewModel()
    @StateObject private var healthVM: OpHealthViewModel

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

            TabView {
                OpStatusTab(vm: statusVM, healthVM: healthVM, serverRunning: composition.serverRunning, iPadURL: composition.iPadURL)
                    .tabItem { Label("状态", systemImage: "heart.text.square") }
                OpSettingsTab(vm: settingsVM, gate: composition.gate)
                    .tabItem { Label("设置", systemImage: "gearshape") }
                OpHistoryTab(vm: historyVM)
                    .tabItem { Label("历史", systemImage: "photo.on.rectangle") }
                OpLogsTab(vm: logsVM)
                    .tabItem { Label("日志", systemImage: "doc.text.magnifyingglass") }
            }
            .padding(.horizontal, 20)
        }
        .background(theme.backgroundColor.ignoresSafeArea())
        .task {
            statusVM.start()
            settingsVM.start()
            logsVM.start()
            historyVM.reload()
            healthVM.start()
        }
    }
}
