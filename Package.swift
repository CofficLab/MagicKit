// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MagicKit",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "MagicKit",
            targets: ["MagicKit"]),
        .library(
            name: "MagicPlayMan",
            targets: ["MagicPlayMan"]),
        .library(
            name: "MagicWeb",
            targets: ["MagicWeb"]),
        .library(
            name: "MagicSync",
            targets: ["MagicSync"]),
        .library(
            name: "MagicAsset",
            targets: ["MagicAsset"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-async-algorithms", from: "0.1.0"),
        .package(url: "https://github.com/chicio/ID3TagEditor", from: "4.5.0")
    ],
    targets: [
        .target(
            name: "MagicKit",
            dependencies: [
                .product(name: "AsyncAlgorithms", package: "swift-async-algorithms"),
                "ID3TagEditor"
            ]
        ),
        .target(
            name: "MagicPlayMan",
            dependencies: ["MagicKit"]
        ),
        .target(
            name: "MagicWeb",
            dependencies: ["MagicKit"]
        ),
        .target(
            name: "MagicSync",
            dependencies: ["MagicKit"]
        ),
        .target(
            name: "MagicAsset",
            dependencies: ["MagicKit"]
        ),
        .testTarget(
            name: "MagicKitTests",
            dependencies: ["MagicKit"]),
    ]
) 
