// swift-tools-version:4.2

import PackageDescription

let package = Package(
    name: "SteamPress",
    products: [
        .library(name: "SteamPress", targets: ["SteamPress"]),
    ],
    dependencies: [
    	.package(url: "https://github.com/vapor/vapor.git", from: "3.0.0"),
        .package(url: "https://github.com/scinfu/SwiftSoup.git", from: "1.5.1"),
        .package(url: "https://github.com/vapor-community/markdown.git", from: "0.4.0"),
        .package(url: "https://github.com/vapor/leaf.git", from: "3.0.0"),
        .package(url: "https://github.com/vapor/auth.git", from: "2.0.0"),
    ],
    targets: [
        .target(name: "SteamPress", dependencies: ["Vapor", "SwiftSoup", "SwiftMarkdown", "Leaf", "Authentication"]),
        .testTarget(name: "SteamPressTests", dependencies: ["SteamPress"]),
    ]
)
