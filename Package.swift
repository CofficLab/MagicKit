// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MagicKit",  // 包名称
    platforms: [
        .macOS(.v14),  // 最低支持 macOS 14
        .iOS(.v17)     // 最低支持 iOS 17
    ],
    // 定义对外提供的库（可被其他项目导入）
    products: [
        .library(name: "MagicCore", targets: ["MagicCore"]),        // 核心库
        .library(name: "MagicPlayMan", targets: ["MagicPlayMan"]),       // 播放管理模块
        .library(name: "MagicSync", targets: ["MagicSync"]),             // 同步模块
        .library(name: "MagicAsset", targets: ["MagicAsset"]),           // Asset 模块
        .library(name: "MagicWeb", targets: ["MagicWeb"]),          // Web 模块
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-async-algorithms", from: "0.1.0"),  // Apple 的异步算法库
        .package(url: "https://github.com/chicio/ID3TagEditor", from: "4.5.0"),  // ID3 标签编辑器
        .package(url: "https://github.com/weichsel/ZIPFoundation.git", from: "0.9.19")  // ZIP 文件处理库
    ],
    // 编译目标（模块）
    targets: [
       .target(
           name: "MagicAsset",
           dependencies: ["MagicCore"]
       ),
       .target(
           name: "MagicCore",
           dependencies: [
               .product(name: "AsyncAlgorithms", package: "swift-async-algorithms"), 
               "ID3TagEditor", 
               "ZIPFoundation",
           ]
       ),
       .target(
           name: "MagicPlayMan",
           dependencies: ["MagicCore"]
       ),
       .target(
           name: "MagicSync",
           dependencies: ["MagicCore"]
       ),
       .testTarget(
           name: "Tests",
           dependencies: ["MagicCore"]
       ),
       .target(
           name: "MagicWeb",
           dependencies: ["MagicCore"]
       ),
    ]
)
