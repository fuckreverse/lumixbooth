import AppKit
import BoothCore

// ============================================================
// OperatorGate — 操作员门禁（@MainActor）
//  - 进入操作员页必须验证 PIN（每次都验；放弃保护者除外）
//  - 防爆破：连续错 5 次锁定，时长 30s 起指数退避，封顶 10 分钟
//  - 退出保护：Cmd+Q / 关窗被拦下时置 pendingQuit，
//    锁屏验证通过后放行退出；Esc 取消即放弃退出
// ============================================================

@MainActor
final class OperatorGate: ObservableObject {

    /// 锁定状态（每次进入操作员页重置为 false）
    @Published private(set) var isUnlocked = false
    /// 是否已设置 PIN（guard.json）
    @Published private(set) var hasPIN = false
    /// DIY 模式：明确放弃 PIN 保护（首次引导里选「暂不设置」）
    @Published private(set) var protectionOptOut = false
    /// 连续错误次数（防爆破计数）
    @Published private(set) var wrongAttempts = 0
    /// 锁定截止时间（nil = 未锁定）
    @Published private(set) var lockoutUntil: Date?
    /// 退出保护：Cmd+Q / 关窗被拦截后等待 PIN 验证
    @Published var pendingQuit = false

    private let store: PINStore
    private var lockoutStep = 0

    let maxWrongAttempts = 5
    private let baseLockoutSec: TimeInterval = 30
    private let maxLockoutSec: TimeInterval = 600

    init(store: PINStore = .shared) {
        self.store = store
    }

    // MARK: - 状态

    var isLocked: Bool { !isUnlocked }
    /// 退出保护是否实际生效（未设 PIN / 放弃保护时无法验证 → 不拦截）
    var quitGuardActive: Bool { hasPIN && !protectionOptOut }
    /// 当前锁定剩余秒数
    var lockoutRemainingSec: TimeInterval {
        max(0, lockoutUntil?.timeIntervalSinceNow ?? 0)
    }

    /// 启动/需要时从 PINStore 刷新快照
    func refreshState() async {
        hasPIN = await store.hasPIN
        protectionOptOut = await store.protectionOptOut
    }

    /// 进入操作员页：放弃保护者直接放行，其余保持锁定等验证
    func entryRequested() async {
        await refreshState()
        isUnlocked = protectionOptOut
    }

    /// 返回宾客大屏：重新上锁（每次进入都要重新验证）
    func lock() {
        isUnlocked = false
        pendingQuit = false
        Log.ui.info("操作员门禁已上锁")
    }

    // MARK: - 验证

    /// 提交 PIN；成功解锁（pendingQuit 时顺带放行退出），失败累计并可能触发锁定
    func submitPIN(_ pin: String) async -> Bool {
        if lockoutRemainingSec > 0 { return false }
        guard isValidPINFormat(pin) else { return false }
        let ok = await store.verify(pin)
        if ok {
            isUnlocked = true
            wrongAttempts = 0
            lockoutUntil = nil
            lockoutStep = 0
            Log.ui.info("操作员 PIN 验证通过")
            if pendingQuit {
                pendingQuit = false
                Log.ui.info("PIN 验证通过，放行退出")
                NSApp.terminate(nil)
            }
            return true
        }
        wrongAttempts += 1
        Log.ui.warn("操作员 PIN 验证失败（第 \(wrongAttempts) 次）")
        if wrongAttempts >= maxWrongAttempts {
            lockoutStep += 1
            let duration = min(baseLockoutSec * pow(2, Double(lockoutStep - 1)), maxLockoutSec)
            lockoutUntil = Date().addingTimeInterval(duration)
            wrongAttempts = 0
            Log.ui.warn("PIN 连续错误达上限，门禁锁定 \(Int(duration)) 秒")
        }
        return false
    }

    // MARK: - 设置 / 引导

    /// 首次引导：设置 PIN（成功即解锁）
    func completeSetup(pin: String) async -> Bool {
        do {
            try await store.setPIN(pin, oldPIN: nil)
            await refreshState()
            isUnlocked = true
            Log.ui.info("首次 PIN 设置完成，保护已启用")
            return true
        } catch {
            return false
        }
    }

    /// 首次引导：暂不设置保护（DIY 模式，持久化 optOut）
    func skipSetup() async {
        try? await store.disableProtection(oldPIN: nil)
        await refreshState()
        isUnlocked = true
        Log.ui.warn("操作员保护已跳过（DIY 模式：进入操作员页不再验证）")
    }

    /// 设置页：修改 PIN（需验证旧 PIN）
    func changePIN(old: String, new: String) async -> PINError? {
        do {
            try await store.setPIN(new, oldPIN: old)
            await refreshState()
            Log.ui.info("操作员 PIN 已修改")
            return nil
        } catch let e as PINError {
            return e
        } catch {
            return .invalidFormat
        }
    }

    /// 设置页：放弃保护（需验证旧 PIN）
    func disableProtection(old: String) async -> Bool {
        do {
            try await store.disableProtection(oldPIN: old)
            await refreshState()
            Log.ui.warn("操作员 PIN 保护已放弃")
            return true
        } catch {
            return false
        }
    }

    /// 退出被拦截（AppDelegate 调用）：置位等待锁屏验证
    func requestQuit() {
        pendingQuit = true
        Log.ui.info("退出被退出保护拦截，等待 PIN 验证（Esc 可取消）")
    }
}
