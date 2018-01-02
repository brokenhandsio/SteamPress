// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "SteamPress",
    products: [
        .library(name: "SteamPress", targets: ["SteamPress"]),
    ],
    dependencies: [
    	.package(url: "https://github.com/vapor/vapor.git", .branch("beta")),
        .package(url: "https://github.com/scinfu/SwiftSoup.git", from: "1.5.1"),
        .package(url: "https://github.com/vapor-community/markdown-provider.git", .branch("vapor3")),
        .package(url: "https://github.com/vapor/leaf.git", .branch("beta")),
        .package(url: "https://github.com/vapor/fluent.git", .branch("beta")),
        .package(url: "https://github.com/vapor/auth.git", .branch("beta")),
        // .package(url: "https://github.com/vapor/validation.git", from: "1.0.1"),
    ],
    targets: [
        .target(name: "SteamPress", dependencies: ["Vapor", "SwiftSoup", "MarkdownProvider", "Leaf",
                                                   "Fluent", "Authentication"/*, "Validation"*/]),
        .testTarget(name: "SteamPressTests", dependencies: ["SteamPress"]),
    ]
)
