import SwiftUI
import BoothCore
import BoothUI

/// 历史页：sessions 目录按日期倒序列出，可一键重打
struct OpHistoryTab: View {
    @Environment(\.boothTheme) private var theme
    @ObservedObject var vm: OpHistoryViewModel

    var body: some View {
        VStack(spacing: 0) {
            // 工具条
            HStack {
                Text("历史成片（\(vm.sessions.count)）")
                    .font(theme.bodyFont(22, weight: .bold))
                    .foregroundStyle(theme.textColor)
                Spacer()
                Button("在 Finder 显示") { vm.revealInFinder() }
                    .buttonStyle(BoothBounceStyle())
                    .font(theme.bodyFont(16, weight: .bold))
                    .foregroundStyle(theme.accentColor)
                Button("刷新") { vm.reload() }
                    .buttonStyle(BoothBounceStyle())
                    .font(theme.bodyFont(16, weight: .bold))
                    .foregroundStyle(theme.accentColor)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)

            if vm.sessions.isEmpty {
                Spacer()
                VStack(spacing: 12) {
                    BoothIcon(emoji: "🖼️", size: 58)
                    Text(vm.loading ? "正在读取…" : "还没有历史成片")
                        .font(theme.bodyFont(20))
                        .foregroundStyle(theme.textSecondaryColor)
                }
                Spacer()
            } else {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 200), spacing: 18)], spacing: 18) {
                        ForEach(vm.sessions) { item in
                            sessionCard(item)
                        }
                    }
                    .padding(12)
                }
            }
        }
    }

    private func sessionCard(_ item: SessionItem) -> some View {
        BoothCard {
            VStack(spacing: 10) {
                // 缩略图（display.jpg 优先）
                if let img = NSImage(contentsOf: item.thumbURL) {
                    Image(nsImage: img)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadiusSmall, style: .continuous))
                } else {
                    BoothIcon(emoji: "🖼️", size: 58)
                        .frame(height: 200)
                }

                Text("\(item.day) \(formatTime(item.name))")
                    .font(theme.bodyFont(15, weight: .bold))
                    .foregroundStyle(theme.textColor)
                    .lineLimit(1)

                BoothSecondaryButton("重打", emoji: "🖨️") { vm.reprint(item) }
                    .scaleEffect(0.8)
            }
        }
    }

    /// 会话目录名 HHmmss-xxxxxx → HH:mm:ss
    private func formatTime(_ name: String) -> String {
        guard name.count >= 6 else { return name }
        let s = name.prefix(6)
        return "\(s.prefix(2)):\(s.dropFirst(2).prefix(2)):\(s.dropFirst(4).prefix(2))"
    }
}
