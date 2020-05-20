// swift-tools-version:5.2
import PackageDescription

let package = Package(
    name: "sqlite-kit",
    products: [
        .library(name: "SQLiteKit", targets: ["SQLiteKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/sqlite-nio.git", from: "1.0.0-rc."),
        .package(url: "https://github.com/vapor/sql-kit.git", from: "3.0.0-rc.1"),
        .package(url: "https://github.com/vapor/async-kit.git", from: "1.0.0-rc.1"),
    ],
    targets: [
        .target(name: "SQLiteKit", dependencies: [
            .product(name: "AsyncKit", package: "async-kit"),
            .product(name: "SQLiteNIO", package: "sqlite-nio"),
            .product(name: "SQLKit", package: "sql-kit"),
        ]),
        .testTarget(name: "SQLiteKitTests", dependencies: [
            .product(name: "SQLKitBenchmark", package: "sql-kit"),
            .target(name: "SQLiteKit"),
        ]),
    ]
)
