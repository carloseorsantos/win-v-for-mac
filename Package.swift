// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "WinPlusV",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(
            name: "WinPlusV",
            targets: ["WinPlusV"]
        )
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "WinPlusV",
            dependencies: [],
            path: "Sources/WinPlusV",
            resources: []
        ),
        .testTarget(
            name: "WinPlusVTests",
            dependencies: ["WinPlusV"],
            path: "Tests/WinPlusVTests"
        )
    ]
)
