// 主题包安装器：把 assets/themes/<名>/ 安装到运行时主题目录。
//
// 主题包结构：
//   <src>/
//     theme.json             ← BoothTheme 覆盖值（颜色/圆角/吉祥物等）
//     icons/*.png            ← 语义 key 命名的贴纸图标（覆盖内置 emoji）
//
// 安装结果：
//   ~/Library/Application Support/Booth/themes/<名>/theme.json
//   ~/Library/Application Support/Booth/themes/<名>/icons/*.png
//
// 用法：swift tools/InstallTheme.swift <主题包目录> [目标目录]
//   目标目录缺省为 ~/Library/Application Support/Booth/themes

import Foundation

func die(_ msg: String) -> Never {
    FileHandle.standardError.write("错误：\(msg)\n".data(using: .utf8)!)
    exit(1)
}

let args = CommandLine.arguments
guard args.count >= 2 else { die("用法: swift tools/InstallTheme.swift <主题包目录> [目标目录]") }
let src = URL(fileURLWithPath: args[1], isDirectory: true)
let dst = URL(fileURLWithPath: args.count >= 3 ? args[2] :
    NSString(string: "~/Library/Application Support/Booth/themes").expandingTildeInPath,
    isDirectory: true)

let fm = FileManager.default
guard fm.fileExists(atPath: src.path) else { die("主题包目录不存在: \(src.path)") }
let name = src.lastPathComponent
let destDir = dst.appendingPathComponent(name, isDirectory: true)

try fm.createDirectory(at: dst, withIntermediateDirectories: true)
try? fm.removeItem(at: destDir)
try fm.copyItem(at: src, to: destDir)

let iconCount = ((try? fm.contentsOfDirectory(
    at: src.appendingPathComponent("icons", isDirectory: true),
    includingPropertiesForKeys: nil)) ?? [])
    .filter { $0.pathExtension == "png" }.count
print("✓ 已安装主题 \(name)（图标 \(iconCount) 张）→ \(destDir.path)")
print("  启用方式：操作员后台 → 设置 → 修图开关 → 主题名填 \(name)")
