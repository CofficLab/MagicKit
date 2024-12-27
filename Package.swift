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
        .library(
            name: "MagicKit",
            targets: ["MagicKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-async-algorithms", from: "0.1.0"),
    ],
    targets: [
        .target(
            name: "MagicKit",
            dependencies: [
                .product(name: "AsyncAlgorithms", package: "swift-async-algorithms"),
            ]),
        .testTarget(
            name: "MagicKitTests",
            dependencies: ["MagicKit"]),
    ]
)
