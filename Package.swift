import PackageDescription

let package = Package(
    name: "SQLite",
    targets: [
        Target(name: "SQLite", dependencies: ["CSQLite"])
    ],
    dependencies: [
        .Package(url: "https://github.com/vapor/core.git", majorVersion: 2),
        .Package(url: "https://github.com/vapor/node.git", majorVersion: 2),
    ]
)
