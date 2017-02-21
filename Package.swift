import PackageDescription

let package = Package(
    name: "SQLite",
    targets: [
        Target(name: "SQLite", dependencies: ["CSQLite"])
    ],
    dependencies: [
        .Package(url: "https://github.com/vapor/core.git", Version(2,0,0, prereleaseIdentifiers: ["alpha"])),
        .Package(url: "https://github.com/vapor/node", Version(2,0,0, prereleaseIdentifiers: ["alpha"]))
    ]
)
