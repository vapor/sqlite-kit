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
        .package(url: "https://github.com/vapor/database-kit.git", .branch("fluent-gm")),
    ],
    targets: [
        .testTarget(name: "SQLiteTests", dependencies: ["SQLite"]),
    ]
)

#if os(Linux)
package.targets.append(.target(name: "CSQLite"))
package.targets.append(.target(name: "SQLite", dependencies: ["Async", "Bits", "Core", "CSQLite", "DatabaseKit", "Debugging"]))
#else
package.targets.append(.target(name: "SQLite", dependencies: ["Async", "Bits", "Core", "DatabaseKit", "Debugging"]))
#endif
