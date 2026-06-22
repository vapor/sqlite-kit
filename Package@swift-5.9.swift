// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "sqlite-kit",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .watchOS(.v6),
        .tvOS(.v13),
    ],
    products: [
        .library(name: "SQLiteKit", targets: ["SQLiteKit"]),
    ],
    dependencies: [
        // TODO: SM: Update swift-nio version once NIOAsyncRuntime is available from swift-nio
        // .package(url: "https://github.com/apple/swift-nio.git", from: "2.89.0"),
        .package(url: "https://github.com/PassiveLogic/swift-nio.git", branch: "feat/addNIOAsyncRuntimeForWasm"),

        // TODO: SM: Update below once everything is merged and release to the proper repositories
//        .package(url: "https://github.com/vapor/sqlite-nio.git", from: "1.9.0"),
        .package(url: "https://github.com/PassiveLogic/sqlite-nio.git", branch: "feat/swift-wasm-support-v2"),
        .package(url: "https://github.com/vapor/sql-kit.git", from: "3.33.1"),
//        .package(url: "https://github.com/vapor/async-kit.git", from: "1.19.0"),
        .package(url: "https://github.com/PassiveLogic/async-kit.git", branch: "feat/swift-wasm-support-v2"),
    ],
    targets: [
        .target(
            name: "SQLiteKit",
            dependencies: [
                .product(name: "NIOFoundationCompat", package: "swift-nio"),
                .product(name: "NIOAsyncRuntime", package: "swift-nio", condition: .when(platforms: [.wasi])),
                .product(name: "NIOPosix", package: "swift-nio"),
                .product(name: "AsyncKit", package: "async-kit"),
                .product(name: "SQLiteNIO", package: "sqlite-nio"),
                .product(name: "SQLKit", package: "sql-kit"),
            ],
            swiftSettings: swiftSettings
        ),
        .testTarget(
            name: "SQLiteKitTests",
            dependencies: [
                .product(name: "SQLKitBenchmark", package: "sql-kit"),
                .target(name: "SQLiteKit"),
            ],
            swiftSettings: swiftSettings
        ),
    ]
)

var swiftSettings: [SwiftSetting] { [
    .enableUpcomingFeature("ExistentialAny"),
    .enableUpcomingFeature("ConciseMagicFile"),
    .enableUpcomingFeature("ForwardTrailingClosures"),
    .enableUpcomingFeature("DisableOutwardActorInference"),
    .enableExperimentalFeature("StrictConcurrency=complete"),
] }
