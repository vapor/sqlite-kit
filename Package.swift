import PackageDescription

let package = Package(
    name: "SQLite",
    targets: [
        Target(name: "SQLite", dependencies: ["CSQLite"])
    ],
    dependencies: [
        .Package(url: "https://github.com/vapor/core.git", majorVersion: 1),
        .Package(url: "https://github.com/vapor/node", majorVersion: 1)
    ]
)
