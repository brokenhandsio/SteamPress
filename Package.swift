import PackageDescription

let package = Package(
    name: "SteamPress",
    dependencies: [
    	.Package(url: "https://github.com/vapor/vapor.git", majorVersion: 2),
    	.Package(url: "https://github.com/scinfu/SwiftSoup.git", majorVersion: 1),
    	.Package(url: "https://github.com/vapor-community/markdown-provider.git", majorVersion: 1),
    	.Package(url: "https://github.com/vapor/leaf-provider.git", majorVersion: 1),
    	.Package(url: "https://github.com/vapor/fluent-provider.git", majorVersion: 1),
    	.Package(url: "https://github.com/vapor/auth-provider.git", majorVersion: 1),
    	.Package(url: "https://github.com/vapor/validation.git", majorVersion: 1),
    ]
)
