import Foundation

// ============================================================
// 留言簿指令桥：BoothServer（HTTP）→ BoothApp（GuestbookRecorder）。
// BoothServer 不依赖 BoothApp，通过闭包注入解耦：BoothApp 启动时
// 把 GuestbookRecorder 的能力装进 bridge，服务端路由直接调用。
// ============================================================

/// 一次留言簿操作的结果
public struct GuestbookResult: Sendable {
    public let ok: Bool
    public let fileName: String?
    public let error: String?
    public init(ok: Bool, fileName: String? = nil, error: String? = nil) {
        self.ok = ok; self.fileName = fileName; self.error = error
    }
}

/// 指令桥（服务端在 HTTP 路由中调用；BoothApp 装配真实实现）
public final class GuestbookCommandBridge: @unchecked Sendable {
    public static let shared = GuestbookCommandBridge()

    private let lock = NSLock()
    /// start 实现（BoothApp 注入；nil = 未配置（留言簿关闭或无相机））
    private var startImpl: (@Sendable (Int, @escaping @Sendable (GuestbookResult) -> Void) -> Void)?
    /// stop 实现
    private var stopImpl: (@Sendable (@escaping @Sendable (GuestbookResult) -> Void) -> Void)?
    /// 留言簿是否启用（配置热更新注入）
    private var enabled = false

    /// BoothApp 注入实现（AppComposition.start 时调用）
    public func install(enabled: Bool,
                        start: @escaping @Sendable (Int, @escaping @Sendable (GuestbookResult) -> Void) -> Void,
                        stop: @escaping @Sendable (@escaping @Sendable (GuestbookResult) -> Void) -> Void) {
        lock.lock()
        self.enabled = enabled
        self.startImpl = start
        self.stopImpl = stop
        lock.unlock()
    }

    /// 配置热更新：留言簿开关
    public func setEnabled(_ on: Bool) {
        lock.lock(); enabled = on; lock.unlock()
    }

    /// 开始录制（返回结果经回调；未启用/未装配时回 ok=false）
    public func start(maxSec: Int, _ completion: @escaping @Sendable (GuestbookResult) -> Void) {
        lock.lock()
        let on = enabled, impl = startImpl
        lock.unlock()
        guard on, let impl else {
            completion(GuestbookResult(ok: false, error: "留言簿未启用"))
            return
        }
        impl(maxSec, completion)
    }

    /// 停止录制
    public func stop(_ completion: @escaping @Sendable (GuestbookResult) -> Void) {
        lock.lock()
        let impl = stopImpl
        lock.unlock()
        guard let impl else {
            completion(GuestbookResult(ok: false, error: "留言簿未启用"))
            return
        }
        impl(completion)
    }
}
