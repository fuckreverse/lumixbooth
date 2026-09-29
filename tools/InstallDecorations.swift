// 装饰模板安装器：把素材包安装到运行时的 decorations 目录。
//
// 素材包结构（由 MakeWeddingStickers.swift 等生成）：
//   <src>/
//     *.png                  ← 全部贴纸（平铺在根目录）
//     <template-name>/template.json
//
// 安装结果（DecorationCore 的加载约定：贴纸必须与 template.json 同目录）：
//   <dst>/<template-name>/template.json
//   <dst>/<template-name>/<引用到的贴纸>.png
//
// 用法：swift tools/InstallDecorations.swift <素材包目录> [目标目录]
//   目标目录缺省为 ~/Library/Application Support/Booth/decorations

import Foundation

func die(_ msg: String) -> Never {
    FileHandle.standardError.write("错误：\(msg)\n".data(using: .utf8)!)
    exit(1)
}

let args = CommandLine.arguments
guard args.count >= 2 else { die("用法: swift tools/InstallDecorations.swift <素材包目录> [目标目录]") }
let src = URL(fileURLWithPath: args[1], isDirectory: true)
let dst = URL(fileURLWithPath: args.count >= 3 ? args[2] :
    NSString(string: "~/Library/Application Support/Booth/decorations").expandingTildeInPath,
    isDirectory: true)

let fm = FileManager.default
guard fm.fileExists(atPath: src.path) else { die("素材包目录不存在: \(src.path)") }

// ① 扫描模板目录（含 template.json 的一级子目录）
let contents = (try? fm.contentsOfDirectory(at: src, includingPropertiesForKeys: [.isDirectoryKey])) ?? []
let templateDirs = contents.filter {
    (try? $0.resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == true
        && fm.fileExists(atPath: $0.appendingPathComponent("template.json").path)
}
guard !templateDirs.isEmpty else { die("素材包中未找到任何 template.json: \(src.path)") }

// ② 逐模板：解析引用的贴纸 → 从素材包根目录复制 → 整目录安装到 dst
try fm.createDirectory(at: dst, withIntermediateDirectories: true)
var installed = 0
for tdir in templateDirs {
    let name = tdir.lastPathComponent
    let json = try String(contentsOf: tdir.appendingPathComponent("template.json"), encoding: .utf8)
    // 提取所有 "file": "xxx.png" 引用（stickers 数组字段）
    let regex = try NSRegularExpression(pattern: "\"file\"\\s*:\\s*\"([^\"]+\\.png)\"")
    let refs = Set(regex.matches(in: json, range: NSRange(json.startIndex..., in: json))
        .compactMap { Range($0.range(at: 1), in: json).map { String(json[$0]) } })

    let destDir = dst.appendingPathComponent(name, isDirectory: true)
    try? fm.removeItem(at: destDir)
    try fm.copyItem(at: tdir, to: destDir)

    var missing: [String] = []
    for file in refs.sorted() {
        let dest = destDir.appendingPathComponent(file)
        // 素材包自包含时模板目录已带贴纸，跳过；否则从素材包根目录补
        if fm.fileExists(atPath: dest.path) { continue }
        let s = src.appendingPathComponent(file)
        guard fm.fileExists(atPath: s.path) else { missing.append(file); continue }
        try fm.copyItem(at: s, to: dest)
    }
    if missing.isEmpty {
        print("  ✓ \(name)（贴纸 \(refs.count) 张）")
        installed += 1
    } else {
        print("  ⚠️ \(name) 已安装，但缺失贴纸: \(missing.joined(separator: ", "))")
    }
}
print("完成：安装 \(installed)/\(templateDirs.count) 个模板 → \(dst.path)")
