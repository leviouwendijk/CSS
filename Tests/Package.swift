// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CSSTests",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "csstest",
            targets: [
                "CSSTestFlows",
            ]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/swift-dsl/DSL.git",
            branch: "master"
        ),
        .package(
            url: "https://github.com/swift-tooling/TestFlows.git",
            branch: "master"
        ),
        .package(path: ".."),
    ],
    targets: [
        .executableTarget(
            name: "CSSTestFlows",
            dependencies: [
                .product(name: "CSS", package: "CSS"),
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
