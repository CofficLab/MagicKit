// swift-tools-version:5.9

import PackageDescription

let package = Package(
    name: "MagicKit",
    platforms: [
        .iOS(.v17),
        .visionOS(.v1),
        .macOS(.v14)
    ],
    products: [
        .library(name: "MagicKit", targets: ["MagicKit"]),
        .library(name: "MagicUI", targets: ["MagicUI"]),
        .library(name: "MagicPlayerUI", targets: ["MagicPlayerUI"]),
        .executable(name: "MagicDemo", targets: ["MagicDemo"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-async-algorithms", from: "0.1.0"),
    ],
    targets: [
        .target(name: "MagicUI"),
        .target(
            name: "MagicKit",
            dependencies: [
                "MagicUI",
                .product(name: "AsyncAlgorithms", package: "swift-async-algorithms"),
            ]),
        .target(name: "MagicPlayerUI"),
        .executableTarget(
            name: "MagicDemo",
            dependencies: ["MagicKit", "MagicUI", "MagicPlayerUI"]),
        .testTarget(
            name: "MagicKitTests",
            dependencies: ["MagicKit"]),
    ]
)
