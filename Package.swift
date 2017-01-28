import PackageDescription

let package = Package(
    name: "SteamPress",
    dependencies: [
    	.Package(url: "https://github.com/vapor/vapor.git", majorVersion: 1),
    	.Package(url: "https://github.com/brokenhandsio/LeafMarkdown.git", majorVersion: 0),
    	.Package(url: "https://github.com/nodes-vapor/paginator", majorVersion: 0)
    ]
)
