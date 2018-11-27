// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "WarningsValidator",
    products: [
        .executable(name: "WarningsValidator", targets: ["WarningsValidator"]),
        .library(name: "WarningsValidatorCore", targets: ["WarningsValidatorCore"])
    ],
    dependencies: [
        .package(
            url: "https://github.com/johnsundell/files.git",
            from: "1.0.0"
        )
    ],
    targets: [
        .target(
            name: "WarningsValidator",
            dependencies: ["WarningsValidatorCore"]
        ),
        .target(
            name: "WarningsValidatorCore",
            dependencies: ["Files"]
        ),
        .testTarget(
            name: "WarningsValidatorTests",
            dependencies: ["WarningsValidatorCore", "Files"]
        )
    ]
)
