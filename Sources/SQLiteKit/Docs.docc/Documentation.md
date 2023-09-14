# ``SQLiteKit``

@Metadata {
    @TitleHeading(Package)
}

SQLiteKit is a library providing an SQLKit driver for SQLiteNIO.

## Overview

This package provides the "foundational" level of support for using [Fluent] with SQLite by implementing the requirements of an [SQLKit] driver. It is responsible for:

- Managing the underlying SQLite library ([SQLiteNIO]),
- Providing a two-way bridge between SQLiteNIO and SQLKit's generic data and metadata formats,
- Presenting an interface for establishing, managing, and interacting with database connections.

> Note: The FluentKit driver for SQLite is provided by the [FluentSQLiteDriver] package.

[SQLKit]: https://swiftpackageindex.com/vapor/sql-kit
[SQLiteNIO]: https://swiftpackageindex.com/vapor/sqlite-nio
[Fluent]: https://swiftpackageindex.com/vapor/fluent-kit
[FluentSQLiteDriver]: https://swiftpackageindex.com/vapor/fluent-sqlite-driver
