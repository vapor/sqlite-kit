// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "SQLite",
    products: [
        .library(name: "SQLite", targets: ["SQLite"]),
    ],
    dependencies: [
        // 🌎 Utility package containing tools for byte manipulation, Codable, OS APIs, and debugging.
        .package(url: "https://github.com/vapor/core.git", from: "3.0.0"),

        // 🗄 Core services for creating database integrations.
        .package(url: "https://github.com/vapor/database-kit.git", .branch("gm")),

        // *️⃣ Build SQL queries in Swift. Extensible, protocol-based design that supports DQL, DML, and DDL.
        .package(url: "https://github.com/vapor/sql.git", from: "1.0.0"),
    ],
    targets: [
        .target(name: "CSQLite"),
        .target(name: "SQLite", dependencies: ["Async", "Bits", "Core", "CSQLite", "Debugging"]),
        .testTarget(name: "SQLiteTests", dependencies: ["SQLite"]),
    ]
)
