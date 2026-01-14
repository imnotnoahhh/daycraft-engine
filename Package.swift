// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DaycraftEngine",
    platforms: [
        .macOS(.v14), .iOS(.v17) // 设定最低支持系统
    ],
    products: [
        // 0. 数据模型库：可被 App/CLI/第三方直接引用
        .library(
            name: "DaycraftModels",
            targets: ["DaycraftModels"]),

        // 0.1 NLP 解析库：可独立使用
        .library(
            name: "DaycraftNLP",
            targets: ["DaycraftNLP"]),

        // 1. 逻辑库：给你的 Daycraft App 引用
        .library(
            name: "DaycraftLogic",
            targets: ["DaycraftLogic"]),
        
        // 2. 命令行工具：编译出来是一个叫 'daycraft' 的可执行程序
        .executable(
            name: "daycraft",
            targets: ["DaycraftCLI"]),
    ],
    dependencies: [
        // 引入 ArgumentParser 用于解析命令行参数
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.3.0"),
    ],
    targets: [
        // 0. 数据模型层 (纯数据结构)
        .target(
            name: "DaycraftModels",
            dependencies: []),

        // 0.1 NLP 解析层 (纯解析，不依赖 CLI)
        .target(
            name: "DaycraftNLP",
            dependencies: ["DaycraftModels"]),

        // A. 核心逻辑层 (纯算法，不依赖 ArgumentParser)
        .target(
            name: "DaycraftLogic",
            dependencies: ["DaycraftModels", "DaycraftNLP"]),
        
        // B. 命令行交互层 (依赖核心逻辑 + ArgumentParser)
        .executableTarget(
            name: "DaycraftCLI",
            dependencies: [
                "DaycraftLogic", // 👈 这里连接了大脑
                "DaycraftNLP",
                "DaycraftModels",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]),
            
        // C. 测试层
        .testTarget(
            name: "DaycraftLogicTests",
            dependencies: ["DaycraftLogic", "DaycraftModels", "DaycraftNLP"]),
        .testTarget(
            name: "DaycraftModelsTests",
            dependencies: ["DaycraftModels"]),
        .testTarget(
            name: "DaycraftNLPTests",
            dependencies: ["DaycraftNLP"]),
        .testTarget(
            name: "DaycraftCLITests",
            dependencies: ["DaycraftCLI"]),
    ]
)
