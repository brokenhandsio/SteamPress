// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "SteamPress",
    products: [
        .library(name: "SteamPress", targets: ["SteamPress"]),
    ],
    dependencies: [
    	.package(url: "https://github.com/vapor/vapor.git", from: "2.2.0"),
        .package(url: "https://github.com/scinfu/SwiftSoup.git", from: "1.4.0"),
        .package(url: "https://github.com/vapor-community/markdown-provider.git", from: "1.0.0"),
        .package(url: "https://github.com/vapor/leaf-provider.git", from: "1.1.0"),
        .package(url: "https://github.com/vapor/fluent-provider.git", from: "1.1.0"),
        .package(url: "https://github.com/vapor/auth-provider.git", from: "1.2.0"),
        .package(url: "https://github.com/vapor/validation.git", from: "1.0.1"),
    ],
    targets: [
        .target(name: "SteamPress", dependencies: ["Vapor", "SwiftSoup", "MarkdownProvider", "LeafProvider",
                                                   "FluentProvider", "AuthProvider", "Validation"]),
        .testTarget(name: "SteamPressTests", dependencies: ["SteamPress"]),
    ]
)
