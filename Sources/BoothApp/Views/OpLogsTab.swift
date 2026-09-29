import SwiftUI
import BoothCore
import BoothUI

/// 日志页：LogStore 内存缓冲滚动列表（级别着色 / 分类过滤 / 自动滚底 / Finder 直达）
struct OpLogsTab: View {
    @Environment(\.boothTheme) private var theme
    @ObservedObject var vm: OpLogsViewModel

    private static let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HH:mm:ss.SSS"
        return f
    }()

    var body: some View {
        VStack(spacing: 0) {
            // 工具条：分类过滤 chips + Finder 按钮
            HStack(spacing: 8) {
                chip(title: "全部", tag: nil)
                ForEach(OpLogsViewModel.categories, id: \.self) { cat in
                    chip(title: cat, tag: cat)
                }
                Spacer()
                Button("在 Finder 显示") { vm.revealInFinder() }
                    .buttonStyle(BoothBounceStyle())
                    .font(theme.bodyFont(16, weight: .bold))
                    .foregroundStyle(theme.accentColor)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)

            // 日志列表（自动滚底）
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 2) {
                        ForEach(vm.filtered) { entry in
                            logLine(entry)
                                .id(entry.id)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.bottom, 8)
                }
                .background(theme.backgroundSecondaryColor,
                            in: RoundedRectangle(cornerRadius: theme.cornerRadiusSmall, style: .continuous))
                .padding(.horizontal, 12)
                .padding(.bottom, 12)
                .onChange(of: vm.filtered.count) { _, _ in
                    if let last = vm.filtered.last {
                        withAnimation(.easeOut(duration: 0.15)) {
                            proxy.scrollTo(last.id, anchor: .bottom)
                        }
                    }
                }
            }
        }
    }

    private func chip(title: String, tag: String?) -> some View {
        let selected = vm.categoryFilter == tag
        return Button {
            vm.categoryFilter = selected && tag != nil ? nil : tag
        } label: {
            Text(title)
                .font(theme.bodyFont(14, weight: .bold))
                .foregroundStyle(selected ? theme.textOnAccentColor : theme.accentColor)
                .padding(.horizontal, 12).padding(.vertical, 6)
                .background(selected ? theme.accentColor : theme.accentColor.opacity(0.12),
                            in: Capsule())
        }
        .buttonStyle(BoothBounceStyle())
    }

    private func logLine(_ entry: LogEntry) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text(Self.timeFormatter.string(from: entry.time))
                .foregroundStyle(theme.textSecondaryColor)
            Text(entry.category)
                .foregroundStyle(theme.accentColor)
                .frame(width: 64, alignment: .leading)
            Text(levelText(entry.level))
                .foregroundStyle(levelColor(entry.level))
                .frame(width: 56, alignment: .leading)
            Text(entry.message)
                .foregroundStyle(theme.textColor)
                .lineLimit(2)
            Spacer(minLength: 0)
            Text(entry.location)
                .foregroundStyle(theme.textSecondaryColor)
        }
        .font(.system(size: 12, weight: .medium, design: .monospaced))
    }

    private func levelText(_ level: LogLevel) -> String {
        switch level {
        case .debug: return "DEBUG"
        case .info: return "INFO"
        case .notice: return "NOTICE"
        case .warning: return "WARN"
        case .error: return "ERROR"
        case .fault: return "FAULT"
        }
    }

    private func levelColor(_ level: LogLevel) -> Color {
        switch level {
        case .debug: return theme.textSecondaryColor
        case .info, .notice: return theme.textColor
        case .warning: return theme.warningColor
        case .error, .fault: return theme.dangerColor
        }
    }
}
