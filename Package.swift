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
            name: "MagicSync",
            targets: ["MagicSync"]),
        .library(
            name: "MagicAsset",
            targets: ["MagicAsset"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-async-algorithms", from: "0.1.0"),
        .package(url: "https://github.com/chicio/ID3TagEditor", from: "5.2.0"),
        .package(url: "https://github.com/weichsel/ZIPFoundation.git", from: "0.9.19")
    ],
    targets: [
        .target(
            name: "MagicKit",
            dependencies: [
                .product(name: "AsyncAlgorithms", package: "swift-async-algorithms"),
                "ID3TagEditor",
                "ZIPFoundation"
            ]
        ),
        .target(
            name: "MagicPlayMan",
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
