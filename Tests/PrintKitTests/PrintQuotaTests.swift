import XCTest
import BoothCore
@testable import PrintKit

// ============================================================
// 打印配额单测 —— 防脚本/连点刷打印（printQuotaPerHour）
// 全部走 MockPrintBackend，绝不触发真实打印
// ============================================================

final class PrintQuotaTests: XCTestCase {

    private func quotaConfig(_ quota: Int) -> BoothConfig.PrintConf {
        var c = BoothConfig.PrintConf()
        c.printQuotaPerHour = quota
        return c
    }

    // MARK: - 未启用配额（默认）不影响打印

    func testQuotaDisabledAllowsAll() async {
        let mock = MockPrintBackend()
        let service = PrintService(backend: mock, config: quotaConfig(0))
        for i in 0..<6 {
            _ = await service.submit(image: URL(fileURLWithPath: "/tmp/booth-q-\(i).jpg"), copies: 4)
        }
        let jobs = await service.jobs
        XCTAssertEqual(jobs.filter { $0.status == .queued || $0.status == .printing || $0.status == .done }.count, 6)
        XCTAssertTrue(jobs.allSatisfy { $0.status != .failed })
    }

    // MARK: - 超限拒绝（不入队，标 failed）

    func testQuotaRejectsBeyondLimit() async {
        let mock = MockPrintBackend()
        let service = PrintService(backend: mock, config: quotaConfig(10))
        // 3 份 × 3 = 9 ≤ 10，放行
        for i in 0..<3 {
            let job = await service.submit(image: URL(fileURLWithPath: "/tmp/booth-q-\(i).jpg"), copies: 3)
            XCTAssertNotEqual(job.status, .failed, "第 \(i) 批（配额内）不应被拒")
        }
        // 已用 9，再打 3 份超限 → 拒绝
        let over = await service.submit(image: URL(fileURLWithPath: "/tmp/booth-q-over.jpg"), copies: 3)
        XCTAssertEqual(over.status, .failed)
        XCTAssertNotNil(over.lastError, "拒绝任务应带原因")
        // 打印机不应收到超限作业
        let records = await mock.records
        XCTAssertEqual(records.count, 3)
    }

    func testQuotaExhaustedByBoundary() async {
        let mock = MockPrintBackend()
        await mock.reset(delay: .seconds(10))   // 阻塞消费循环，前单停 queued，隔离配额判断
        // 注意：默认 maxCopies=4，请求 5 份会被夹取为 4 → 配额上限取 4 正好耗尽
        let service = PrintService(backend: mock, config: quotaConfig(4))
        // 4 份正好用完
        _ = await service.submit(image: URL(fileURLWithPath: "/tmp/booth-qb-1.jpg"), copies: 4)
        // 第 5 份拒绝
        let over = await service.submit(image: URL(fileURLWithPath: "/tmp/booth-qb-2.jpg"), copies: 1)
        XCTAssertEqual(over.status, .failed)
    }

    // MARK: - 配额热更新立即生效

    func testQuotaAppliedOnConfigUpdate() async {
        let mock = MockPrintBackend()
        await mock.reset(delay: .seconds(10))   // 阻塞消费循环，隔离配额判断
        let service = PrintService(backend: mock, config: quotaConfig(0))
        _ = await service.submit(image: URL(fileURLWithPath: "/tmp/booth-qu-1.jpg"), copies: 2)
        // 热更新打开配额 3：已用 2，只剩 1 份额度
        await service.applyConfig(quotaConfig(3))
        let over = await service.submit(image: URL(fileURLWithPath: "/tmp/booth-qu-2.jpg"), copies: 2)
        XCTAssertEqual(over.status, .failed, "配额开启后超限应被拒")
    }

    // MARK: - 超限任务重试仍受配额约束

    func testRetryRejectedWhileQuotaExhausted() async {
        let mock = MockPrintBackend()
        await mock.reset(failCount: 1)   // 第一单必失败，制造 failed 任务
        let service = PrintService(backend: mock, config: quotaConfig(2))
        _ = await service.submit(image: URL(fileURLWithPath: "/tmp/booth-qr-1.jpg"), copies: 2)
        // 等消费完成（失败）
        try? await Task.sleep(nanoseconds: 300_000_000)
        // 再打一单用完配额
        await service.applyConfig(quotaConfig(4))
        _ = await service.submit(image: URL(fileURLWithPath: "/tmp/booth-qr-2.jpg"), copies: 2)
        // 原失败任务重试：配额已满（2+2=4）→ 拒绝重试，保留 failed
        await service.retry(jobID: await service.jobs.first!.id)
        let jobs = await service.jobs
        let retried = jobs.first { $0.imagePath == "/tmp/booth-qr-1.jpg" }!
        XCTAssertEqual(retried.status, .failed)
        XCTAssertNotNil(retried.lastError)
    }

    // MARK: - 去重窗口与配额互不干扰

    func testDedupeHitDoesNotConsumeQuota() async {
        let mock = MockPrintBackend()
        let service = PrintService(backend: mock, config: quotaConfig(2))
        let url = URL(fileURLWithPath: "/tmp/booth-qd.jpg")
        _ = await service.submit(image: url, copies: 2)
        // 同一图 5s 内重复提交 → 命中去重，不消耗配额
        _ = await service.submit(image: url, copies: 2)
        let jobs = await service.jobs
        XCTAssertEqual(jobs.count, 1)
    }
}
