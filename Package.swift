// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "SteamPress",
    products: [
        .library(name: "SteamPress", targets: ["SteamPress"]),
    ],
    dependencies: [
    	.package(url: "https://github.com/vapor/vapor.git", from: "3.0.0"),
        .package(url: "https://github.com/scinfu/SwiftSoup.git", from: "2.0.0"),
        .package(url: "https://github.com/vapor-community/markdown.git", from: "0.4.0"),
        .package(url: "https://github.com/vapor/auth.git", from: "2.0.0"),
    ],
    targets: [
        .target(name: "SteamPress", dependencies: ["Vapor", "SwiftSoup", "SwiftMarkdown", "Authentication"]),
        .testTarget(name: "SteamPressTests", dependencies: ["SteamPress"]),
    ]
)
