import SwiftUI
import AppKit
import BoothCore
import BoothUI

/// 设置页：全部读写 ConfigStore，改动即生效；含安全设置与危险区（防呆）
struct OpSettingsTab: View {
    @Environment(\.boothTheme) private var theme
    @ObservedObject var vm: OpSettingsViewModel
    @ObservedObject var gate: OperatorGate

    @State private var themeName = ""
    @State private var portText = ""
    @State private var showExportPanel = false
    @State private var showImportPanel = false
    @State private var securityNotice: String?
    @State private var oldPINField = ""
    @State private var newPINField1 = ""
    @State private var newPINField2 = ""

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                captureCard
                printCard
                securityCard
                imagingCard
                serverCard
                dangerZoneCard
            }
            .padding(8)
        }
        .onAppear { syncTextFields() }
        .onChange(of: vm.config) { _, _ in
            syncTextFields()
            vm.reloadBackups()   // 改动会自动备份，刷新列表
        }
        .fileExporter(isPresented: $showExportPanel, document: ConfigDocument()) { result in
            if case .success(let url) = result { vm.exportConfig(to: url) }
        }
        .fileImporter(isPresented: $showImportPanel, allowedContentTypes: [.json]) { result in
            if case .success(let url) = result {
                let secured = url.startAccessingSecurityScopedResource()
                defer { if secured { url.stopAccessingSecurityScopedResource() } }
                vm.importConfig(from: url)
            }
        }
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
                    label("拼版布局")
                    // 拼版默认布局（经典拼条 / 四宫格 / 双格大图）
                    Picker("", selection: Binding<CollageLayout>(
                        get: { vm.config.capture.defaultMode.layout },
                        set: { layout in vm.update {
                            if $0.capture.defaultMode.kind == .collage {
                                $0.capture.defaultMode = .collage($0.capture.defaultMode.shots, layout: layout)
                            }
                        } }
                    )) {
                        ForEach(CollageLayout.allCases, id: \.rawValue) { l in
                            Text(l.displayName).tag(l)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 260)
                }

                Toggle("连拍不中断（拼版仅首张倒计时）",
                       isOn: bind(\.capture.continuousCollage))
                    .font(theme.bodyFont(17))
                    .foregroundStyle(theme.textColor)

                HStack {
                    label("REVIEW 超时")
                    Stepper("\(vm.config.capture.reviewTimeoutSec) 秒",
                            value: bind(\.capture.reviewTimeoutSec), in: 10...300, step: 10)
                }

                Toggle("超时自动打印（关闭则只回待机）",
                       isOn: bind(\.capture.autoPrintOnTimeout))
                    .font(theme.bodyFont(17))
                    .foregroundStyle(theme.textColor)

                Toggle("待机屏历史成片轮播",
                       isOn: bind(\.capture.idleSlideshow))
                    .font(theme.bodyFont(17))
                    .foregroundStyle(theme.textColor)

                HStack {
                    label("轮播间隔")
                    Stepper("\(vm.config.capture.idleSlideshowSec) 秒",
                            value: bind(\.capture.idleSlideshowSec), in: 2...30)
                }
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
                HStack {
                    label("每小时打印上限")
                    Stepper(vm.config.printing.printQuotaPerHour == 0
                            ? "不限制"
                            : "\(vm.config.printing.printQuotaPerHour) 张/时",
                            value: Binding(
                                get: { max(vm.config.printing.printQuotaPerHour, 1) },
                                set: { value in vm.update { $0.printing.printQuotaPerHour = value } }),
                            in: 1...500, step: 10)
                    Toggle("启用", isOn: Binding(
                        get: { vm.config.printing.printQuotaPerHour > 0 },
                        set: { on in vm.update { $0.printing.printQuotaPerHour = on ? 60 : 0 } }))
                    .frame(width: 80)
                    Text("防脚本刷打印；超限任务标记失败")
                        .font(theme.bodyFont(13))
                        .foregroundStyle(theme.textSecondaryColor)
                }
                Toggle("成片边缘印二维码（扫码存电子版）",
                       isOn: bind(\.printing.printQRCode))
                    .font(theme.bodyFont(17))
                    .foregroundStyle(theme.textColor)
                Toggle("大屏显示打印按钮（关则仅 iPad / P 键可打印）",
                       isOn: bind(\.printing.showPrintButton))
                    .font(theme.bodyFont(17))
                    .foregroundStyle(theme.textColor)
                Toggle("P 键触发打印（操作员兜底通道）",
                       isOn: bind(\.printing.printKeyEnabled))
                    .font(theme.bodyFont(17))
                    .foregroundStyle(theme.textColor)
                HStack {
                    label("超时自动打印延迟")
                    Stepper("\(vm.config.printing.autoPrintDelaySec) 秒",
                            value: bind(\.printing.autoPrintDelaySec), in: 0...30)
                }
                HStack {
                    label("“打印中”停留时长")
                    Stepper("\(vm.config.printing.printingDwellSec) 秒",
                            value: bind(\.printing.printingDwellSec), in: 0...15)
                }
                Toggle("演示模式（不送打印机，输出 PDF 到预览目录）",
                       isOn: bind(\.printing.dryRun))
                    .font(theme.bodyFont(17))
                    .foregroundStyle(theme.textColor)
                HStack {
                    label("预览目录")
                    Button("打开 print-preview 目录") {
                        NSWorkspace.shared.open(BoothPaths.printPreviewDir)
                    }
                    .font(theme.bodyFont(15))
                    Text("dry-run 打印的 PDF 落在这里")
                        .font(theme.bodyFont(14))
                        .foregroundStyle(theme.textSecondaryColor)
                }
            }
            .font(theme.bodyFont(17))
            .foregroundStyle(theme.textColor)
        }
    }

    // MARK: - 安全

    private var securityCard: some View {
        BoothCard {
            VStack(alignment: .leading, spacing: 16) {
                cardTitle("安全与保护", emoji: "🔐")

                // PIN 状态
                HStack {
                    label("操作员 PIN")
                    if gate.hasPIN {
                        BoothStatusPill(emoji: "✅", text: "已设置", tint: theme.successColor)
                    } else if gate.protectionOptOut {
                        BoothStatusPill(emoji: "⚠️", text: "未保护（DIY 模式）", tint: theme.warningColor)
                    } else {
                        BoothStatusPill(emoji: "❌", text: "未设置", tint: theme.dangerColor)
                    }
                }

                // PIN 修改（已设置时）
                if gate.hasPIN {
                    pinChangeRow
                } else {
                    HStack {
                        Text("未设置 PIN：宾客可按 Esc 直接进入操作员页修改配置。")
                            .font(theme.bodyFont(14))
                            .foregroundStyle(theme.textSecondaryColor)
                    }
                }

                // 退出保护
                Toggle("退出保护（Cmd+Q / 关窗需验证 PIN）", isOn: bind(\.security.quitProtection))
                    .disabled(!gate.hasPIN || gate.protectionOptOut)
                Text("未设置 PIN 时无法验证，退出保护不生效；仅影响本 App，不影响其他应用。")
                    .font(theme.bodyFont(13))
                    .foregroundStyle(theme.textSecondaryColor)
            }
            .font(theme.bodyFont(17))
            .foregroundStyle(theme.textColor)
        }
    }

    private var pinChangeRow: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
                SecureField("旧 PIN", text: $oldPINField)
                    .textFieldStyle(.roundedBorder).frame(width: 100)
                SecureField("新 PIN（4-6 位）", text: $newPINField1)
                    .textFieldStyle(.roundedBorder).frame(width: 150)
                SecureField("确认新 PIN", text: $newPINField2)
                    .textFieldStyle(.roundedBorder).frame(width: 150)
                BoothSecondaryButton("修改", emoji: "✏️") { submitChangePIN() }
                    .disabled(!isValidPINFormat(newPINField1) || newPINField1 != newPINField2 || oldPINField.isEmpty)
                BoothSecondaryButton("放弃保护", emoji: "🙈") { submitDisablePIN() }
                    .disabled(oldPINField.isEmpty)
            }
            if let securityNotice {
                Text(securityNotice)
                    .font(theme.bodyFont(14))
                    .foregroundStyle(theme.warningColor)
            } else {
                Text("放弃保护后进入操作员页不再验证（回到 DIY 模式），需输入旧 PIN 确认")
                    .font(theme.bodyFont(13))
                    .foregroundStyle(theme.textSecondaryColor)
            }
        }
    }

    private func submitChangePIN() {
        let old = oldPINField, new = newPINField1
        Task {
            if let err = await gate.changePIN(old: old, new: new) {
                securityNotice = err == .wrongOldPIN ? "旧 PIN 不正确" : "新 PIN 需为 4-6 位数字"
                return
            }
            oldPINField = ""; newPINField1 = ""; newPINField2 = ""
            securityNotice = "PIN 已修改 ✅"
        }
    }

    private func submitDisablePIN() {
        let old = oldPINField
        Task {
            guard await gate.disableProtection(old: old) else {
                securityNotice = "旧 PIN 不正确，无法放弃保护"
                return
            }
            oldPINField = ""; newPINField1 = ""; newPINField2 = ""
            securityNotice = "已放弃 PIN 保护（DIY 模式）"
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
                Toggle("拍后自选滤镜（REVIEW 选择条）", isOn: bind(\.imaging.filterSelection))

                HStack {
                    label("默认滤镜")
                    Picker("", selection: bind(\.imaging.defaultFilter)) {
                        ForEach(PhotoFilter.allCases, id: \.rawValue) { f in
                            Text("\(f.emoji) \(f.displayName)").tag(f)
                        }
                    }
                    .frame(width: 260)
                }

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

    // MARK: - 危险区（防呆核心：坏改动可反悔）

    @State private var holdTask: Task<Void, Never>?
    @State private var holdProgress: Double = 0

    private var dangerZoneCard: some View {
        BoothCard {
            VStack(alignment: .leading, spacing: 16) {
                cardTitle("危险区", emoji: "⚠️")
                Text("一键重置前会自动备份当前配置（可在下方「恢复」撤销）；重置仅影响 config.json，不动主题素材、历史照片和 PIN。")
                    .font(theme.bodyFont(13))
                    .foregroundStyle(theme.textSecondaryColor)

                HStack(spacing: 16) {
                    // 长按 3 秒重置（防误触，过程中松手即取消）
                    holdToResetButton

                    BoothSecondaryButton("导出配置", emoji: "📦") { showExportPanel = true }
                    BoothSecondaryButton("导入配置", emoji: "📥") { showImportPanel = true }
                }

                backupRestoreRow
            }
            .font(theme.bodyFont(15))
            .foregroundStyle(theme.textColor)
        }
    }

    private var holdToResetButton: some View {
        VStack(spacing: 6) {
            Button {
                // 兼容键盘/辅助功能触发（等效长按到位）
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: theme.cornerRadiusSmall)
                        .fill(Color(nsColor: .controlAccentColor).opacity(holdProgress > 0 ? 1 : 0.15))
                    GeometryReader { geo in
                        RoundedRectangle(cornerRadius: theme.cornerRadiusSmall)
                            .fill(theme.dangerColor.opacity(0.85))
                            .frame(width: geo.size.width * holdProgress)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadiusSmall))
                    Text(holdProgress > 0 ? "继续按住 \(Int((1 - holdProgress) * 3 + 0.5)) 秒…" : "长按 3 秒重置配置")
                        .font(theme.bodyFont(17, weight: .bold))
                        .foregroundStyle(holdProgress > 0 ? Color.white : theme.dangerColor)
                        .padding(.horizontal, 24)
                }
                .frame(height: 44)
            }
            .buttonStyle(HoldResetStyle(
                onPress: beginHold,
                onRelease: cancelHold))
            .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadiusSmall))
        }
    }

    private func beginHold() {
        cancelHold()
        holdTask = Task {
            let total: Double = 3.0
            let start = Date()
            while !Task.isCancelled {
                let elapsed = Date().timeIntervalSince(start)
                holdProgress = min(elapsed / total, 1)
                if elapsed >= total { break }
                try? await Task.sleep(nanoseconds: 33_000_000)   // ~30fps
            }
            guard !Task.isCancelled else { return }
            holdProgress = 0
            Log.ui.warn("危险区：配置已一键重置为默认（原配置已自动备份）")
            vm.resetToDefaults()
        }
    }

    private func cancelHold() {
        holdTask?.cancel()
        holdTask = nil
        holdProgress = 0
    }

    private var backupRestoreRow: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("配置自动备份（最近 10 份，每次改动自动留存）")
                .font(theme.bodyFont(15))
                .foregroundStyle(theme.textSecondaryColor)
            if vm.backups.isEmpty {
                Text("暂无备份（首次改动后自动产生）")
                    .font(theme.bodyFont(13))
                    .foregroundStyle(theme.textSecondaryColor)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(vm.backups) { backup in
                            BoothSecondaryButton("恢复", emoji: "⏮️") {
                                vm.restoreBackup(backup.name)
                            }
                            Text(backup.timeText)
                                .font(theme.bodyFont(13))
                                .foregroundStyle(theme.textSecondaryColor)
                        }
                    }
                }
                .frame(height: 52)
            }
        }
    }

    // MARK: - 小组件

    private func cardTitle(_ text: String, emoji: String) -> some View {
        HStack(spacing: 8) {
            BoothIcon(emoji: emoji, size: 26)
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

// MARK: - 长按手势 ButtonStyle（按下回调，抬起回调）

private struct HoldResetStyle: ButtonStyle {
    let onPress: () -> Void
    let onRelease: () -> Void

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .onChange(of: configuration.isPressed) { _, pressed in
                if pressed { onPress() } else { onRelease() }
            }
    }
}

// MARK: - 备份时间展示

extension ConfigBackup {
    var timeText: String {
        let f = DateFormatter()
        f.dateFormat = "MM-dd HH:mm:ss"
        return f.string(from: date)
    }
}

// MARK: - fileExporter 配置文档

import UniformTypeIdentifiers

struct ConfigDocument: FileDocument {
    static let writableContentTypes: [UTType] = [.json]
    static let readableContentTypes: [UTType] = [.json]

    init() {}

    init(configuration: ReadConfiguration) throws {
        // 导入经 fileImporter 走，这里不需要解析
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        // 导出时写入当前配置内容
        guard let data = try? Data(contentsOf: BoothPaths.configFile) else {
            return FileWrapper(regularFileWithContents: Data())
        }
        return FileWrapper(regularFileWithContents: data)
    }
}
