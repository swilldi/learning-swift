// swift-tools-version: 6.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FocuslyCore",
    platforms: [.macOS(.v15)],
    products: [
        .library(
            name: "FocuslyCore",
            targets: ["FocuslyCore"]
        )
    ],
    targets: [
        .target(name: "FocuslyCore"),
        .testTarget(name: "FocuslyCoreTests", dependencies: ["FocuslyCore"]),
    ]
)
