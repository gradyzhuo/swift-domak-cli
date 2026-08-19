// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-pangu-cli",
    platforms: [
        .macOS(.v15),
    ],
    products: [
        .executable(
            name: "pangu",
            targets: ["PanguCLI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.3.0"),
    ],
    targets: [
        .executableTarget(
            name: "PanguCLI",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ]),
    ]
)
