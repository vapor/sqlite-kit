import SQLKit
import SQLiteNIO

extension SQLiteDatabase {
    /// Return an object allowing access to this database via the `SQLDatabase` interface.
    ///
    /// - Parameters:
    ///   - encoder: An ``SQLiteDataEncoder`` used to translate bound query parameters into `SQLiteData` values.
    ///   - decoder: An ``SQLiteDataDecoder`` used to translate `SQLiteData` values into output values in `SQLRow`s.
    /// - Returns: An instance of `SQLDatabase` which accesses the same database as `self`.
    public func sql(
        encoder: SQLiteDataEncoder = .init(),
        decoder: SQLiteDataDecoder = .init()
    ) -> any SQLDatabase {
        SQLiteSQLDatabase(database: .init(value: self), encoder: encoder, decoder: decoder)
    }
}

struct SQLiteDatabaseVersion: SQLDatabaseReportedVersion {
    /// The numeric value of the version.
    ///
    /// The value is laid out identicallly to [the `SQLITE_VERSION_NUMBER` constant](c_source_id).
    ///
    /// [c_source_id]: https://sqlite.org/c3ref/c_source_id.html
    let intValue: Int
    
    /// The string representation of the version.
    ///
    /// The string is formatted identically to [the `SQLITE_VERSION` constant](c_source_id).
    ///
    /// [c_source_id]: https://sqlite.org/c3ref/c_source_id.html
    ///
    /// This value is not used for equality or ordering comparisons; it is really only useful for display. We
    /// maintain a stored property for it rather than generating it as-needed from the numeric value in order to
    /// preserve any additional information the original value may contain.
    ///
    /// > Note: The string value should always represent the same version as the numeric value. This requirement is
    /// > asserted in debug builds, but is not otherwise enforced.
    let stringValue: String
    
    /// Separates an appropriately formatted numeric value into its individual components.
    static func components(of intValue: Int) -> (major: Int, minor: Int, patch: Int) {
        (
            major: intValue / 1_000_000,
            minor: intValue % 1_000_000 / 1_000,
            patch: intValue % 1_000
        )
    }
    
    /// Get the runtime version of the SQLite3 library in use.
    static var runtimeVersion: Self {
        self.init(
            intValue: Int(SQLiteConnection.libraryVersion()),
            stringValue: SQLiteConnection.libraryVersionString()
        )
    }
    
    /// Build a version value from individual components and synthesize the approiate string value.
    init(major: Int, minor: Int, patch: Int) {
        self.init(intValue: major * 1_000_000 + minor * 1_000 + patch)
    }
    
    /// Designated initializer. Build a version value from the combined numeric value and a corresponding string value.
    /// If the string value is omitted, it is synthesized
    init(intValue: Int, stringValue: String? = nil) {
        let components = Self.components(of: intValue)

        self.intValue = intValue
        if let stringValue {
            assert(
                stringValue.hasPrefix("\(components.major).\(components.minor).\(components.patch)"),
                "SQLite version string '\(stringValue)' must prefix-match numeric version '\(intValue)'"
            )
            self.stringValue = stringValue
        } else {
            self.stringValue = "\(components.major).\(components.major).\(components.patch)"
        }
    }

    /// The major version number.
    ///
    /// This is likely to be 3 for a long time to come yet.
    var majorVersion: Int {
        Self.components(of: self.intValue).major
    }
    
    /// The minor version number.
    var minorVersion: Int {
        Self.components(of: self.intValue).minor
    }
    
    /// The patch version number.
    var patchVersion: Int {
        Self.components(of: self.intValue).patch
    }

    // See `SQLDatabaseReportedVersion.isEqual(to:)`.
    func isEqual(to otherVersion: any SQLDatabaseReportedVersion) -> Bool {
        (otherVersion as? Self).map { $0.intValue == self.intValue } ?? false
    }
    
    // See `SQLDatabaseReportedVersion.isOlder(than:)`.
    func isOlder(than otherVersion: any SQLDatabaseReportedVersion) -> Bool {
        (otherVersion as? Self).map {
            (self.majorVersion != $0.majorVersion ? self.majorVersion < $0.majorVersion :
            (self.minorVersion != $0.minorVersion ? self.minorVersion < $0.minorVersion :
            (self.patchVersion < $0.patchVersion)))
        } ?? false
    }
}

/// Wraps a `SQLiteDatabase` with the `SQLDatabase` protocol.
private struct SQLiteSQLDatabase<D: SQLiteDatabase>: SQLDatabase {
    /// A trivial wrapper type to work around Sendable warnings due to SQLiteNIO not being Sendable-correct.
    struct FakeSendable<T>: @unchecked Sendable {
        let value: T
    }
    
    /// The underlying database.
    let database: FakeSendable<D>
    
    /// An ``SQLiteDataEncoder`` used to translate bindings into `SQLiteData` values.
    let encoder: SQLiteDataEncoder
    
    /// An ``SQLiteDataDecoder`` used to translate `SQLiteData` values into output values in `SQLRow`s.
    let decoder: SQLiteDataDecoder
    
    // See `SQLDatabase.eventLoop`.
    var eventLoop: any EventLoop {
        self.database.value.eventLoop
    }
    
    // See `SQLDatabase.version`.
    var version: (any SQLDatabaseReportedVersion)? {
        SQLiteDatabaseVersion.runtimeVersion
    }
    
    // See `SQLDatabase.logger`.
    var logger: Logger {
        self.database.value.logger
    }
    
    // See `SQLDatabase.dialect`.
    var dialect: any SQLDialect {
        SQLiteDialect()
    }
    
    // See `SQLDatabase.queryLogLevel`.
    var queryLogLevel: Logger.Level?
    
    // See `SQLDatabase.execute(sql:_:)`.
    func execute(
        sql query: any SQLExpression,
        _ onRow: @escaping @Sendable (any SQLRow) -> ()
    ) -> EventLoopFuture<Void> {
        var serializer = SQLSerializer(database: self)
        query.serialize(to: &serializer)
        let binds: [SQLiteData]
        do {
            binds = try serializer.binds.map { encodable in
                try self.encoder.encode(encodable)
            }
        } catch {
            return self.eventLoop.makeFailedFuture(error)
        }
        
        return self.database.value.query(
            serializer.sql,
            binds,
            logger: self.logger,
            { onRow($0.sql(decoder: self.decoder)) }
        )
    }

    // See `SQLDatabase.execute(sql:_:)`.
    func execute(
        sql query: any SQLExpression,
        _ onRow: @escaping @Sendable (any SQLRow) -> ()
    ) async throws {
        var serializer = SQLSerializer(database: self)
        query.serialize(to: &serializer)
        
        let binds = try serializer.binds.map { try self.encoder.encode($0) }
        
        return try await self.database.value.query(
            serializer.sql,
            binds,
            logger: self.logger,
            { onRow($0.sql(decoder: self.decoder)) }
        ).get()
    }
    
    // See `SQLDatabase.withSession(_:)`.
    func withSession<R>(_ closure: @escaping @Sendable (any SQLDatabase) async throws -> R) async throws -> R {
        try await self.database.value.withConnection { c in
            c.eventLoop.makeFutureWithTask {
                try await closure(c.sql(encoder: self.encoder, decoder: self.decoder))
            }
        }.get()
    }
}
