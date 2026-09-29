import Foundation

/// 全局事件总线：发布/多订阅广播（每个订阅者独立流，带缓冲防慢消费者阻塞发布者）
public actor EventBus {
    public static let shared = EventBus()

    private var continuations: [UUID: AsyncStream<AppEvent>.Continuation] = [:]
    /// 最近一次状态类事件，新订阅者立即补发（避免 UI 启动错过当前状态）
    private var lastEvents: [String: AppEvent] = [:]

    public init() {}

    public func publish(_ event: AppEvent) {
        lastEvents[event.key] = event
        for c in continuations.values { c.yield(event) }
    }

    public func stream(replayLatest: Bool = true) -> AsyncStream<AppEvent> {
        let id = UUID()
        let replay = replayLatest ? Array(lastEvents.values) : []
        return AsyncStream(bufferingPolicy: .bufferingNewest(64)) { cont in
            for e in replay { cont.yield(e) }
            continuations[id] = cont
            cont.onTermination = { [weak self] _ in
                Task { await self?.removeContinuation(id) }
            }
        }
    }

    private func removeContinuation(_ id: UUID) { continuations.removeValue(forKey: id) }
}

extension AppEvent {
    /// 按事件种类去重的 key（lastEvents 只留每种最新一条）
    var key: String {
        switch self {
        case .stateChanged: return "state"
        case .cameraConnectionChanged: return "camera"
        case .printQueueChanged: return "printQueue"
        case .countdownTick: return "countdown"
        }
    }
}
