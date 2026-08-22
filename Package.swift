// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CSS",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "CSS",
            targets: [
                "CSS",
            ]
        ),
        .executable(
            name: "csstest",
            targets: [
                "CSSTestFlows",
            ]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/leviouwendijk/DSL.git",
            branch: "master"
        ),
        .package(
            url: "https://github.com/leviouwendijk/Indentation.git",
            branch: "master"
        ),
        .package(
            url: "https://github.com/leviouwendijk/TestFlows.git",
            branch: "master"
        ),
    ],
    targets: [
        .target(
            name: "CSS",
            dependencies: [
                .product(
                    name: "DSL",
                    package: "DSL"
                ),
                .product(
                    name: "Indentation",
                    package: "Indentation"
                ),
            ]
        ),
        .executableTarget(
            name: "CSSTestFlows",
            dependencies: [
                "CSS",
                .product(
                    name: "DSL",
                    package: "DSL"
                ),
                .product(
                    name: "TestFlows",
                    package: "TestFlows"
                ),
            ]
        ),
    ]
)
