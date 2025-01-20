// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "BookReader",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "BookReader",
            targets: ["BookReader"]
        ),
        .library(
            name: "Models",
            targets: ["Models"]
        ),
        .library(
            name: "Services",
            targets: ["Services"]
        ),
        .library(
            name: "Components",
            targets: ["Components"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/readium/swift-toolkit.git", from: "2.5.0")
    ],
    targets: [
        .target(
            name: "BookReader",
            dependencies: [
                .product(name: "R2Shared", package: "swift-toolkit"),
                .product(name: "R2Streamer", package: "swift-toolkit"),
                "Models", "Services", "Components"
            ]
        ),
        .target(
            name: "Models",
            dependencies: []
        ),
        .target(
            name: "Services",
            dependencies: ["Models"]
        ),
        .target(
            name: "Components",
            dependencies: ["Models"]
        ),
        .testTarget(
            name: "BookReaderTests",
            dependencies: ["BookReader"]
        )
    ]
) 