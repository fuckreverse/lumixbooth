import SwiftUI
import BoothCore
import BoothUI

/// 状态页：相机连接大卡片 + 打印队列列表（failed 可重试/移除）
struct OpStatusTab: View {
    @Environment(\.boothTheme) private var theme
    @ObservedObject var vm: OpStatusViewModel
    let serverRunning: Bool
    let iPadURL: String?

    private static let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HH:mm:ss"
        return f
    }()

    var body: some View {
        HStack(alignment: .top, spacing: 20) {
            // 左：相机状态大卡片
            BoothCard {
                VStack(alignment: .leading, spacing: 18) {
                    Text("相机").font(theme.bodyFont(24, weight: .bold)).foregroundStyle(theme.textColor)
                    BoothIcon(emoji: vm.cameraState.emoji, size: 68)
                    BoothStatusPill.camera(vm.cameraState, theme: theme)
                    Text(cameraHint)
                        .font(theme.bodyFont(16))
                        .foregroundStyle(theme.textSecondaryColor)
                        .fixedSize(horizontal: false, vertical: true)

                    Divider()

                    Text("iPad 服务").font(theme.bodyFont(24, weight: .bold)).foregroundStyle(theme.textColor)
                    BoothStatusPill(
                        emoji: serverRunning ? "🟢" : "🔴",
                        text: serverRunning ? "运行中" : "未运行",
                        tint: serverRunning ? theme.successColor : theme.dangerColor)
                    if let iPadURL {
                        Text(iPadURL)
                            .font(theme.bodyFont(16))
                            .foregroundStyle(theme.textSecondaryColor)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(width: 320)

            // 右：打印队列
            BoothCard {
                VStack(alignment: .leading, spacing: 14) {
                    Text("打印队列（\(vm.jobs.count)）")
                        .font(theme.bodyFont(24, weight: .bold))
                        .foregroundStyle(theme.textColor)

                    if vm.jobs.isEmpty {
                        Spacer()
                        HStack {
                            Spacer()
                            VStack(spacing: 10) {
                                BoothIcon(emoji: "🖨️", size: 50)
                                Text("队列为空，等待打印任务")
                                    .font(theme.bodyFont(18))
                                    .foregroundStyle(theme.textSecondaryColor)
                            }
                            Spacer()
                        }
                        Spacer()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 10) {
                                ForEach(vm.jobs.reversed()) { job in
                                    jobRow(job)
                                }
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(8)
    }

    private var cameraHint: String {
        switch vm.cameraState {
        case .liveView: return "取流正常，可以拍照"
        case .connected: return "已连接，LiveView 未启动"
        case .searching, .connecting: return "正在连接相机…"
        case .reconnecting: return "断线重连中，请稍候"
        case .disconnected: return "请检查 USB 与机身 Tether 模式"
        }
    }

    /// 单个打印任务行：缩略图 / 份数 / 状态 / 时间 / failed 操作
    private func jobRow(_ job: PrintJob) -> some View {
        HStack(spacing: 14) {
            jobThumb(job)
                .frame(width: 46, height: 68)
                .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadiusSmall, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text("\(job.copies) 份 · \(Self.timeFormatter.string(from: job.createdAt))")
                    .font(theme.bodyFont(17, weight: .bold))
                    .foregroundStyle(theme.textColor)
                if let err = job.lastError, job.status == .failed {
                    Text(err)
                        .font(theme.bodyFont(13))
                        .foregroundStyle(theme.dangerColor)
                        .lineLimit(2)
                }
            }

            Spacer()

            statusPill(job.status)

            if job.status == .failed {
                Button("重试") { vm.retry(jobID: job.id) }
                    .buttonStyle(BoothBounceStyle())
                    .font(theme.bodyFont(15, weight: .bold))
                Button("移除") { vm.remove(jobID: job.id) }
                    .buttonStyle(BoothBounceStyle())
                    .font(theme.bodyFont(15, weight: .bold))
                    .foregroundStyle(theme.dangerColor)
            }
        }
        .padding(10)
        .background(theme.backgroundColor,
                    in: RoundedRectangle(cornerRadius: theme.cornerRadiusSmall, style: .continuous))
    }

    private func jobThumb(_ job: PrintJob) -> some View {
        Group {
            if let img = NSImage(contentsOfFile: job.imagePath) {
                Image(nsImage: img).resizable().aspectRatio(contentMode: .fill)
            } else {
                BoothIcon(emoji: "🖼️", size: 30)
            }
        }
    }

    private func statusPill(_ status: PrintJobStatus) -> some View {
        let (emoji, text, tint): (String, String, Color) = {
            switch status {
            case .queued: return ("🕐", "排队中", theme.warningColor)
            case .printing: return ("🖨️", "打印中", theme.accentColor)
            case .done: return ("✅", "已完成", theme.successColor)
            case .failed: return ("❌", "失败", theme.dangerColor)
            case .cancelled: return ("🚫", "已取消", theme.textSecondaryColor)
            }
        }()
        return BoothStatusPill(emoji: emoji, text: text, tint: tint)
    }
}

private extension CameraConnectionState {
    var emoji: String {
        switch self {
        case .liveView: return "📸"
        case .connected: return "🔌"
        case .searching, .connecting: return "🔍"
        case .reconnecting: return "🔄"
        case .disconnected: return "😴"
        }
    }
}
