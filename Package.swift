// swift-tools-version:5.9

import PackageDescription

let package = Package(
    name: "MagicKit",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "MagicKit",
            targets: ["MagicKit"]),
    ],
    dependencies: [
        // 如果有外部依赖,在这里添加
    ],
    targets: [
        .target(
            name: "MagicKit",
            dependencies: []),
        .testTarget(
            name: "MagicKitTests",
            dependencies: ["MagicKit"]),
    ]
)
