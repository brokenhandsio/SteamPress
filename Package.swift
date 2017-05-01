import PackageDescription

let package = Package(
    name: "SteamPress",
    dependencies: [
    	.Package(url: "https://github.com/vapor/vapor.git", Version(2,0,0, prereleaseIdentifiers: ["beta"])),
    	.Package(url: "https://github.com/scinfu/SwiftSoup.git", majorVersion: 1),
    	.Package(url: "https://github.com/brokenhandsio/LeafMarkdown.git", Version(0,3,0, prereleaseIdentifiers: ["beta"])),
    	.Package(url: "https://github.com/vapor/leaf-provider.git", Version(1,0,0, prereleaseIdentifiers: ["beta"])),
    	.Package(url: "https://github.com/vapor/fluent-provider.git", Version(1,0,0, prereleaseIdentifiers: ["beta"])),
    	.Package(url: "https://github.com/vapor/auth-provider.git", Version(1,0,0, prereleaseIdentifiers: ["beta"])),
    	.Package(url: "https://github.com/vapor/validation.git", majorVersion: 0),
    ]
)
