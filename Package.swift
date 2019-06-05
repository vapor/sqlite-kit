// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "sqlite-kit",
    products: [
        .library(name: "SQLiteKit", targets: ["SQLiteKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/nio-sqlite.git", .branch("master")),
        .package(url: "https://github.com/vapor/sql-kit.git", from: "3.0.0-alpha"),
        .package(url: "https://github.com/vapor/nio-kit.git", .branch("master")),
    ],
    targets: [
        .target(name: "SQLiteKit", dependencies: [
            "NIOKit",
            "NIOSQLite",
            "SQLKit"
        ]),
        .testTarget(name: "SQLiteKitTests", dependencies: ["SQLKitBenchmark", "SQLiteKit"]),
    ]
)
