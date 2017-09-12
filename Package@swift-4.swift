// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "SQLite",
    products: [
        .library(name: "SQLite", targets: ["SQLite"]),
        .library(name: "CSQLite", targets: ["CSQLite"])
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/core.git", .upToNextMajor(from: "2.1.2")),
        .package(url: "https://github.com/vapor/node.git", .upToNextMajor(from: "2.1.0")),
    ],
    targets: [
        .target(name: "SQLite", dependencies: ["Core", "CSQLite", "Node"]),
        .testTarget(name: "SQLiteTests", dependencies: ["SQLite"]),
        .target(name: "CSQLite"),
    ]
)
