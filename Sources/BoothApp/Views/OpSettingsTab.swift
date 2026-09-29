import SwiftUI
import BoothCore
import BoothUI

/// 设置页：全部读写 ConfigStore，改动即生效
struct OpSettingsTab: View {
    @Environment(\.boothTheme) private var theme
    @ObservedObject var vm: OpSettingsViewModel

    @State private var themeName = ""
    @State private var portText = ""

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                captureCard
                printCard
                imagingCard
                serverCard
            }
            .padding(8)
        }
        .onAppear { syncTextFields() }
        .onChange(of: vm.config) { _, _ in syncTextFields() }
    }

    /// 文本框与配置同步（外部热更新时刷新；编辑中不打断靠 onSubmit 提交）
    private func syncTextFields() {
        if themeName != vm.config.imaging.themeName { themeName = vm.config.imaging.themeName }
        if portText != String(vm.config.server.port) { portText = String(vm.config.server.port) }
    }

    /// KeyPath 的 Sendable 包装（KeyPath 不可变，跨域传递安全）
    private struct SendableKeyPath<V>: @unchecked Sendable {
        let value: WritableKeyPath<BoothConfig, V>
    }

    /// 通用配置 Binding：get 读快照，set 经 ConfigStore.update 写回（改即存）
    private func bind<V: Equatable & Sendable>(_ keyPath: WritableKeyPath<BoothConfig, V>) -> Binding<V> {
        let safePath = SendableKeyPath(value: keyPath)
        return Binding(
            get: { vm.config[keyPath: keyPath] },
            set: { value in vm.update { $0[keyPath: safePath.value] = value } }
        )
    }

    // MARK: - 拍摄

    private var captureCard: some View {
        BoothCard {
            VStack(alignment: .leading, spacing: 16) {
                cardTitle("拍摄设置", emoji: "📸")

                HStack {
                    label("倒计时秒数")
                    Picker("", selection: bind(\.capture.countdownSec)) {
                        Text("3 秒").tag(3)
                        Text("5 秒").tag(5)
                        Text("10 秒").tag(10)
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 260)
                }

                HStack {
                    label("默认模式")
                    // 整模式替换（单张 shots=1 / 拼版 shots=4），避免只改 kind 留下不一致
                    Picker("", selection: Binding<ShootKind>(
                        get: { vm.config.capture.defaultMode.kind },
                        set: { kind in vm.update {
                            $0.capture.defaultMode = kind == .single ? .single : .collage(4)
                        } }
                    )) {
                        Text("单张美照").tag(ShootKind.single)
                        Text("四连拍拼版").tag(ShootKind.collage)
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 260)
                }

                HStack {
                    label("REVIEW 超时")
                    Stepper("\(vm.config.capture.reviewTimeoutSec) 秒",
                            value: bind(\.capture.reviewTimeoutSec), in: 10...300, step: 10)
                }

                Toggle("超时自动打印（关闭则只回待机）",
                       isOn: bind(\.capture.autoPrintOnTimeout))
                    .font(theme.bodyFont(17))
                    .foregroundStyle(theme.textColor)
            }
        }
    }

    // MARK: - 打印

    private var printCard: some View {
        BoothCard {
            VStack(alignment: .leading, spacing: 16) {
                cardTitle("打印设置", emoji: "🖨️")
                HStack {
                    label("默认打印份数")
                    Stepper("\(vm.config.printing.defaultCopies) 份",
                            value: bind(\.printing.defaultCopies), in: 1...4)
                }
            }
        }
    }

    // MARK: - 修图

    private var imagingCard: some View {
        BoothCard {
            VStack(alignment: .leading, spacing: 14) {
                cardTitle("修图开关", emoji: "✨")
                Toggle("自动调色", isOn: bind(\.imaging.autoColor))
                Toggle("美肤磨皮", isOn: bind(\.imaging.skinSmoothing))
                Toggle("人像换背景（需主题带 background.png）", isOn: bind(\.imaging.replaceBackground))
                Toggle("边框 / 相框", isOn: bind(\.imaging.frame))
                Toggle("日期水印", isOn: bind(\.imaging.dateWatermark))

                HStack {
                    label("主题名")
                    TextField("default", text: $themeName)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 220)
                        .onSubmit {
                            // onSubmit 闭包是 Sendable 非隔离的，视图状态实际跑在主线程
                            MainActor.assumeIsolated {
                                let name = themeName
                                vm.update { $0.imaging.themeName = name }
                                Log.ui.info("主题名已修改：\(name)")
                            }
                        }
                    Text("修改后回车生效")
                        .font(theme.bodyFont(14))
                        .foregroundStyle(theme.textSecondaryColor)
                }
            }
            .font(theme.bodyFont(17))
            .foregroundStyle(theme.textColor)
        }
    }

    // MARK: - 服务器

    private var serverCard: some View {
        BoothCard {
            VStack(alignment: .leading, spacing: 16) {
                cardTitle("iPad 服务", emoji: "📱")
                Toggle("启用内嵌 Web 服务", isOn: bind(\.server.enabled))
                    .font(theme.bodyFont(17))
                    .foregroundStyle(theme.textColor)
                HStack {
                    label("端口")
                    TextField("8080", text: $portText)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 120)
                        .onSubmit {
                            MainActor.assumeIsolated {
                                if let port = UInt16(portText) {
                                    vm.update { $0.server.port = port }
                                    Log.ui.info("服务端口已修改：\(port)（重启 App 后生效）")
                                } else {
                                    portText = String(vm.config.server.port)
                                }
                            }
                        }
                    Text("端口修改需重启 App 生效")
                        .font(theme.bodyFont(14))
                        .foregroundStyle(theme.warningColor)
                }
            }
        }
    }

    // MARK: - 小组件

    private func cardTitle(_ text: String, emoji: String) -> some View {
        HStack(spacing: 8) {
            Text(emoji).font(.system(size: 24))
            Text(text).font(theme.bodyFont(22, weight: .bold)).foregroundStyle(theme.textColor)
        }
    }

    private func label(_ text: String) -> some View {
        Text(text)
            .font(theme.bodyFont(17))
            .foregroundStyle(theme.textColor)
            .frame(width: 130, alignment: .leading)
    }
}
