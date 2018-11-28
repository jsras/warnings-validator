// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "WarningsValidator",
    products: [
        .executable(name: "WarningsValidator", targets: ["WarningsValidator"]),
        .library(name: "WarningsValidatorCore", targets: ["WarningsValidatorCore"])
    ],
    targets: [
        .target(
            name: "WarningsValidator",
            dependencies: ["WarningsValidatorCore"]
        ),
        .target(name: "WarningsValidatorCore"),
        .testTarget(
            name: "WarningsValidatorTests",
            dependencies: ["WarningsValidatorCore"]
        )
    ]
)
