// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "sqlite-kit",
    products: [
        .library(name: "SQLiteKit", targets: ["SQLiteKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/sqlite-nio.git", .branch("tn-sqlite-logger")),
        .package(url: "https://github.com/vapor/sql-kit.git", .branch("tn-logging")),
        .package(url: "https://github.com/vapor/async-kit.git", .branch("master")),
    ],
    targets: [
        .target(name: "SQLiteKit", dependencies: [
            "AsyncKit",
            "SQLiteNIO",
            "SQLKit"
        ]),
        .testTarget(name: "SQLiteKitTests", dependencies: ["SQLKitBenchmark", "SQLiteKit"]),
    ]
)
