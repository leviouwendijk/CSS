// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CSS",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "CSS",
            targets: ["CSS"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/leviouwendijk/DSL.git", branch: "master"),
        .package(url: "https://github.com/leviouwendijk/Indentation.git", branch: "master"),
    ],
    targets: [
        .target(
            name: "CSS",
            dependencies: [
                .product(name: "DSL", package: "DSL"),
                .product(name: "Indentation", package: "Indentation"),
            ],

        ),
        .testTarget(
            name: "CSSTests",
            dependencies: ["CSS"]
        ),
    ]
)
