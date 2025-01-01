// swift-tools-version:5.9

import PackageDescription

let package = Package(
    name: "MagicKit",
    platforms: [.macOS(.v14), .iOS(.v17)],
    products: [
        .library(name: "MagicKit", targets: ["MagicKit"]),
        .library(name: "MagicPlayMan", targets: ["MagicPlayMan"]),
        .library(name: "MagicUI", targets: ["MagicUI"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-async-algorithms", from: "0.1.0"),
    ],
    targets: [
        .target(
            name: "MagicKit",
            dependencies: [
                .product(name: "AsyncAlgorithms", package: "swift-async-algorithms")
            ]
        ),
        .target(
            name: "MagicPlayMan",
            dependencies: ["MagicKit", "MagicUI"]
        ),
        .target(
            name: "MagicUI"
        )
    ]
)
