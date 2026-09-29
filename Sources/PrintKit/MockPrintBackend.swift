import Foundation
import BoothCore

// ============================================================
// 测试用 Mock 打印后端：可编程延迟 / 失败 / 打印机不可用，
// 并记录收到的每个作业（顺序即真实消费顺序）。
// 绝不触碰子进程，测试永不触发真实打印。
// ============================================================

actor MockPrintBackend: PrintBackend {

    /// 一次收到的打印请求（append 时机 = 后端开始处理该作业）
    struct Record: Sendable, Equatable {
        let imagePath: String
        let copies: Int
    }

    /// 每个作业的人为延迟（模拟打印机出片耗时）
    var delay: Duration = .zero

    /// 接下来 N 次打印抛错（>0 时递减；模拟缺纸/脱机）
    var failCount: Int = 0

    /// 模拟"打印机不可用"：非 nil 时抛 BoothError.printerUnavailable(此消息)
    var unavailableMessage: String?

    /// 收到的作业记录（顺序敏感，串行性测试用）
    private(set) var records: [Record] = []

    init() {}

    func print(imagePath: String, copies: Int, config: BoothConfig.PrintConf) async throws {
        if let message = unavailableMessage {
            throw BoothError.printerUnavailable(message)
        }
        records.append(Record(imagePath: imagePath, copies: copies))
        if delay > .zero {
            try await Task.sleep(for: delay)
        }
        if failCount > 0 {
            failCount -= 1
            throw PrintBackendError.lpFailed(exitCode: 1, stderr: "mock: 模拟打印失败（缺纸/脱机）")
        }
    }

    /// 重置所有可编程状态与记录
    func reset(delay: Duration = .zero, failCount: Int = 0, unavailableMessage: String? = nil) {
        self.delay = delay
        self.failCount = failCount
        self.unavailableMessage = unavailableMessage
        records.removeAll()
    }
}
