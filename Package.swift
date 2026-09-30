// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-domak-cli",
    platforms: [
        .macOS(.v15),
    ],
    products: [
        .executable(
            name: "domak",
            targets: ["DomakCLI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.3.0"),
    ],
    targets: [
        .executableTarget(
            name: "DomakCLI",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ]),
        .testTarget(
            name: "DomakCLITests",
            dependencies: ["DomakCLI"]),
    ]
)
