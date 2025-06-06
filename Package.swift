// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Fawkes",
    products: [
        .executable(name: "fawkes", targets: ["FawkesMain"]),
        .library(name: "FawkesLib", targets: ["FawkesLib"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.2.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "FawkesLib",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ]
        ),
        .executableTarget(
            name: "FawkesMain",
            dependencies: ["FawkesLib"]
        ),
        .testTarget(
            name: "FawkesTests",
            dependencies: ["FawkesLib"]
        ),
    ]
)
