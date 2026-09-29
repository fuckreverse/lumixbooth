import Foundation
import BoothCore

// ============================================================
// PrintKit 内部打印后端协议（与 BoothCore 契约无关）
//  - 后端只负责"把一张图按份数送到打印机"这一件事
//  - 可用性探测失败 → BoothError.printerUnavailable（日志带 lpstat 原始输出）
//  - lp 退出码非 0   → PrintBackendError.lpFailed（stderr 记入 lastError）
//  - 队列/去重/夹取/重试全部由 PrintService 负责，后端无状态
// ============================================================

protocol PrintBackend: Sendable {
    /// 执行一次打印（含打印机可用性探测）。失败抛错。
    func print(imagePath: String, copies: Int, config: BoothConfig.PrintConf) async throws
}

/// lp 失败 / 文件缺失等本地错误（打印机不可用统一用 BoothError.printerUnavailable）
enum PrintBackendError: Error, Sendable {
    /// lp 命令退出码非 0（stderr 附带在关联值里，最终落到 job.lastError）
    case lpFailed(exitCode: Int32, stderr: String)
    /// 打印位图文件不存在（ImagingKit 产物被清理/移动等场景）
    case fileNotFound(String)
}

extension PrintBackendError: CustomStringConvertible {
    var description: String {
        switch self {
        case .lpFailed(let code, let stderr):
            let trimmed = stderr.trimmingCharacters(in: .whitespacesAndNewlines)
            return "lp 退出码 \(code)\(trimmed.isEmpty ? "" : ": \(trimmed)")"
        case .fileNotFound(let path):
            return "打印文件不存在: \(path)"
        }
    }
}

// MARK: - CUPS lp 命令后端（生产实现）

/// 走 macOS CUPS 命令行工具：
///  1. `lpstat -d` / `lpstat -p` 探测打印机可用性（不可用抛 BoothError.printerUnavailable）
///  2. `lp -d <打印机名> -n <份数> -o media=<4x6.Borderless|4x6> -o fit-to-page <文件>`
/// 打印机名为空时省略 -d（用系统默认打印机）。
/// 图片本体已是 1200×1800 @300dpi 的 6 寸位图，fit-to-page 保证满幅不裁切错位。
struct LPPrintBackend: PrintBackend {

    func print(imagePath: String, copies: Int, config: BoothConfig.PrintConf) async throws {
        // 子进程是阻塞调用，放到 detached task 里跑，避免把 PrintService actor 卡死
        let path = imagePath
        let cfg = config
        try await Task.detached(priority: .utility) {
            try Self.execute(path, copies: copies, config: cfg)
        }.value
    }

    // MARK: 同步执行体（仅在后台线程运行）

    private static func execute(_ imagePath: String, copies: Int, config: BoothConfig.PrintConf) throws {
        // ① 文件必须先存在，避免把奇怪错误留给 CUPS
        guard FileManager.default.fileExists(atPath: imagePath) else {
            Log.print.error("打印文件不存在，拒绝提交: \(imagePath)")
            throw PrintBackendError.fileNotFound(imagePath)
        }

        // ② 探测打印机可用性（lpstat -d / lpstat -p）
        try checkAvailability(config: config)

        // ③ 组装并执行 lp
        let args = lpArguments(imagePath: imagePath, copies: copies, config: config)
        Log.print.info("执行 lp: /usr/bin/lp \(args.joined(separator: " "))")
        let result = runCommand("/usr/bin/lp", args)
        Log.print.info("lp 退出码=\(result.status) stdout=\(result.stdout.trimmingCharacters(in: .whitespacesAndNewlines)) stderr=\(result.stderr.trimmingCharacters(in: .whitespacesAndNewlines))")

        guard result.status == 0 else {
            throw PrintBackendError.lpFailed(exitCode: result.status, stderr: result.stderr)
        }
        // lp 成功输出形如 "request id is EPSON_L805-42 (1 file(s))"，上面日志已带上
    }

    /// 组装 lp 参数（独立成纯函数便于单测；不执行任何子进程）
    /// -d 仅在配置了打印机名时出现（空 = 用系统默认）；media 按无边距开关二选一。
    static func lpArguments(imagePath: String, copies: Int, config: BoothConfig.PrintConf) -> [String] {
        var args: [String] = []
        if !config.printerName.isEmpty {
            args += ["-d", config.printerName]
        }
        args += ["-n", String(copies)]
        // 无边距用 4x6.Borderless；有边距降级 4x6（SPEC §12 风险 4 的降级路径）
        args += ["-o", config.borderless ? "media=4x6.Borderless" : "media=4x6"]
        args += ["-o", "fit-to-page"]
        args.append(imagePath)
        return args
    }

    /// 打印机可用性探测：
    ///  - 配置了 printerName → 直接去 `lpstat -p` 里找它
    ///  - 未配置 → `lpstat -d` 解析系统默认打印机，找不到默认即不可用
    /// 任何一步失败都抛 BoothError.printerUnavailable，日志保留 lpstat 原始输出供排查
    private static func checkAvailability(config: BoothConfig.PrintConf) throws {
        // 默认打印机探测
        let dest = runCommand("/usr/bin/lpstat", ["-d"])
        Log.print.info("lpstat -d 退出码=\(dest.status) 输出=\(dest.stdout.trimmingCharacters(in: .whitespacesAndNewlines)) \(dest.stderr.trimmingCharacters(in: .whitespacesAndNewlines))")

        let target: String
        if !config.printerName.isEmpty {
            target = config.printerName
        } else {
            // 输出形如 "system default destination: EPSON_L805"
            let line = dest.stdout
                .split(separator: "\n")
                .first { $0.contains("system default destination") }
            let name = line?
                .split(separator: ":")
                .last?
                .trimmingCharacters(in: .whitespaces) ?? ""
            guard !name.isEmpty else {
                throw BoothError.printerUnavailable(
                    "未配置打印机名且系统无默认打印机（lpstat -d: \(dest.stdout.trimmingCharacters(in: .whitespacesAndNewlines))）")
            }
            target = name
        }

        // 打印机状态探测
        let printers = runCommand("/usr/bin/lpstat", ["-p"])
        Log.print.info("lpstat -p 退出码=\(printers.status) 输出=\(printers.stdout.trimmingCharacters(in: .whitespacesAndNewlines)) \(printers.stderr.trimmingCharacters(in: .whitespacesAndNewlines))")

        guard printers.status == 0 else {
            throw BoothError.printerUnavailable("lpstat -p 执行失败: \(printers.stderr.trimmingCharacters(in: .whitespacesAndNewlines))")
        }

        // 行格式: "printer EPSON_L805 is idle.  enabled since ..." / disabled 变体
        let entry = printers.stdout
            .split(separator: "\n")
            .first { line in
                let tokens = line.split(separator: " ")
                return tokens.count >= 2 && tokens[0] == "printer" && tokens[1] == target
            }
        guard let entry else {
            throw BoothError.printerUnavailable("打印机 '\(target)' 未出现在 lpstat -p 输出中（可能未安装/未共享）。输出:\n\(printers.stdout.trimmingCharacters(in: .whitespacesAndNewlines))")
        }
        guard entry.contains("enabled") else {
            throw BoothError.printerUnavailable("打印机 '\(target)' 处于停用状态: \(entry)")
        }
        Log.print.info("打印机可用: \(entry)")
    }

    // MARK: 子进程执行

    /// 运行外部命令并收集 stdout/stderr。
    /// lp/lpstat 输出都很小（远小于管道 64KB 缓冲），先 waitUntilExit 再整段读取即可，
    /// 不做 readabilityHandler 流式读（避免 Swift 6 并发下跨线程可变捕获）。
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
