import PackageDescription

let package = Package(
    name: "SQLite",
    dependencies: [ 
        .Package(url: "https://github.com/qutheory/csqlite.git", majorVersion: 0, minor: 1),
        .Package(url: "https://github.com/qutheory/libc.git", majorVersion: 0, minor: 1),
    ]
)
