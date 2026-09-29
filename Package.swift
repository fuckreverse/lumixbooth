// swift-tools-version:6.0
import PackageDescription

// LUMIX Photobooth — 模块契约见 SPEC.md 与 Sources/BoothCore/Protocols.swift
// 零第三方依赖：全部系统框架（OSLog / Network / Vision / CoreImage / SwiftUI）
let package = Package(
    name: "booth",
    platforms: [.macOS(.v14)],
    products: [
        .executable(name: "booth", targets: ["BoothApp"]),
        .library(name: "BoothCore", targets: ["BoothCore"]),
    ],
    targets: [
        // 地基：模型 / 协议 / 日志 / 配置 / 事件总线 / 路径
        .target(name: "BoothCore", path: "Sources/BoothCore"),
        // 设计系统：主题收口 + 可复用组件（唯一 UI 风格来源）
        .target(name: "BoothUI", dependencies: ["BoothCore"], path: "Sources/BoothUI"),
        // 相机桥接（dlopen libLmxptpif.dylib）
        .target(
            name: "CameraKit",
            dependencies: ["BoothCore"],
            path: "Sources/CameraKit",
            resources: [.copy("libLmxptpif.dylib")]
        ),
        // 手势 / 姿势 / 人像分割（Vision）
        .target(name: "VisionKit", dependencies: ["BoothCore"], path: "Sources/VisionKit"),
        // 修图合成管线（CoreImage / CoreGraphics）
        .target(name: "ImagingKit", dependencies: ["BoothCore"], path: "Sources/ImagingKit"),
        // 打印队列（CUPS / NSPrintOperation）
        .target(name: "PrintKit", dependencies: ["BoothCore"], path: "Sources/PrintKit"),
        // iPad Web 服务（Network.framework 轻量 HTTP + WebSocket）
        .target(name: "BoothServer", dependencies: ["BoothCore"], path: "Sources/BoothServer"),
        // 拍照流程状态机
        .target(name: "SessionEngine", dependencies: ["BoothCore"], path: "Sources/SessionEngine"),
        // 主程序
        .executableTarget(
            name: "BoothApp",
            dependencies: ["BoothCore", "BoothUI", "CameraKit", "VisionKit",
                           "ImagingKit", "PrintKit", "BoothServer", "SessionEngine"],
            path: "Sources/BoothApp"
        ),

        .testTarget(name: "BoothCoreTests", dependencies: ["BoothCore"], path: "Tests/BoothCoreTests"),
        .testTarget(name: "CameraKitTests", dependencies: ["CameraKit", "BoothCore"], path: "Tests/CameraKitTests"),
        .testTarget(name: "VisionKitTests", dependencies: ["VisionKit", "BoothCore"], path: "Tests/VisionKitTests"),
        .testTarget(name: "ImagingKitTests", dependencies: ["ImagingKit", "BoothCore"], path: "Tests/ImagingKitTests"),
        .testTarget(name: "PrintKitTests", dependencies: ["PrintKit", "BoothCore"], path: "Tests/PrintKitTests"),
        .testTarget(name: "BoothServerTests", dependencies: ["BoothServer", "BoothCore"], path: "Tests/BoothServerTests"),
        .testTarget(name: "SessionEngineTests", dependencies: ["SessionEngine", "BoothCore"], path: "Tests/SessionEngineTests"),
    ]
)
