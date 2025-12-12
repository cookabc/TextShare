// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "TextToShare",
    platforms: [
        .macOS(.v13),
        .iOS(.v16),
    ],
    products: [
        .executable(
            name: "TextToShare",
            targets: ["TextToShare"]
        ),
    ],
    dependencies: [
        // TCA (The Composable Architecture)
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.10.0"),
    ],
    targets: [
        .executableTarget(
            name: "TextToShare",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "TextToShareTests",
            dependencies: [
                "TextToShare",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ],
            path: "Tests"
        ),
    ]
)