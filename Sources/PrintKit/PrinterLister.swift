import Foundation
import BoothCore

// ============================================================
// PrinterLister — 系统打印机枚举（lpstat -p 纯解析）
//  - 操作员设置页「指定打印机」下拉数据源
//  - 纯函数解析 + 独立 runCommand：不依赖任何 PrintBackend，
//    测试可直接喂伪造 stdout 断言解析结果（不执行子进程）
//  - 设定名统一 rstrip 空白（lpstat 输出偶有尾随空格）
// ============================================================

public enum PrinterLister {

    /// 一台系统打印机的描述
    public struct Printer: Sendable, Equatable, Identifiable {
        public let name: String        // CUPS 设定名（lp -d 用这个）
        public let enabled: Bool       // lpstat 行含 enabled
        public var id: String { name }

        public init(name: String, enabled: Bool) {
            self.name = name
            self.enabled = enabled
        }
    }

    /// 枚举系统打印机（lpstat -p）。执行失败/无打印机返回空数组（设置页显示“未检测到”）。
    public static func list() -> [Printer] {
        let result = runCommand("/usr/bin/lpstat", ["-p"])
        guard result.status == 0 else {
            Log.print.warn("lpstat -p 执行失败（打印机枚举返回空）: \(result.stderr.trimmingCharacters(in: .whitespacesAndNewlines))")
            return []
        }
        return parsePrinters(result.stdout)
    }

    /// 解析 lpstat -p 输出（纯函数）。
    /// 行格式: "printer EPSON_L805 is idle.  enabled since ..." / disabled 变体
    public static func parsePrinters(_ output: String) -> [Printer] {
        var printers: [Printer] = []
        for line in output.split(separator: "\n") {
            let tokens = line.split(separator: " ", omittingEmptySubsequences: true)
            // printer <name> is ...
            guard tokens.count >= 3, tokens[0] == "printer" else { continue }
            let name = String(tokens[1]).trimmingCharacters(in: .whitespaces)
            guard !name.isEmpty else { continue }
            // 停用行: "printer X is disabled since ..."；启用行恒含 enabled since
            let enabled = line.contains("enabled")
            printers.append(Printer(name: name, enabled: enabled))
        }
        return printers
    }

    /// 异步枚举（子进程阻塞调用放后台线程）
    public static func listAsync() async -> [Printer] {
        await Task.detached(priority: .utility) { list() }.value
    }

    // MARK: 子进程执行（与 LPPrintBackend 同款小输出读取策略）

    private static func runCommand(_ executable: String, _ arguments: [String]) -> (status: Int32, stdout: String, stderr: String) {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: executable)
        process.arguments = arguments
        let outPipe = Pipe()
        let errPipe = Pipe()
        process.standardOutput = outPipe
        process.standardError = errPipe
        do {
            try process.run()
        } catch {
            return (-1, "", "无法启动 \(executable): \(error.localizedDescription)")
        }
        process.waitUntilExit()
        let out = String(data: outPipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
        let err = String(data: errPipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
        return (process.terminationStatus, out, err)
    }
}
