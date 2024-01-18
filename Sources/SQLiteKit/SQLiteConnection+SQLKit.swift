import SQLKit
import SQLiteNIO

extension SQLiteDatabase {
    public func sql() -> any SQLDatabase {
        _SQLiteSQLDatabase(database: self)
    }
}

internal struct _SQLiteDatabaseVersion: SQLDatabaseReportedVersion {
    /// The numeric value of the version. The format of the value is the one described in
    /// https://sqlite.org/c3ref/c_source_id.html for the `SQLITE_VERSION_NUMBER` constant.
    let intValue: Int
    
    /// The string representation of the version. The string is formatted according to the description in
    /// https://sqlite.org/c3ref/c_source_id.html for the `SQLITE_VERSION` constant.
    ///
    /// This value is not used for equality or ordering comparisons; it is really only useful as a display value. We
    /// maintain a stored property for it here rather than always generating it as-needed from the numeric value so
    /// that we don't accidentally drop any additional information a particular library version might contain.
    ///
    /// - Note: The string value should always represent the same version as the numeric value. This requirement is
    ///   asserted in debug builds, but not otherwise enforced.
    let stringValue: String
    
    /// Separates a numeric value into individual components and returns them.
    static func components(of intValue: Int) -> (major: Int, minor: Int, patch: Int) {
        let major = intValue / 1_000_000,
            minor = (intValue - major * 1_000_000) / 1_000,
            patch = intValue - major * 1_000_000 - minor * 1_000
        return (major: major, minor: minor, patch: patch)
    }
    
    /// Get the version value representing the runtime version of the SQLite3 library in use.
    static var runtimeVersion: _SQLiteDatabaseVersion {
        self.init(intValue: Int(SQLiteConnection.libraryVersion()), stringValue: SQLiteConnection.libraryVersionString())
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
        if let stringValue = stringValue {
            assert(stringValue.hasPrefix("\(components.major).\(components.minor).\(components.patch)"), "SQLite version string '\(stringValue)' must match numeric version '\(intValue)'")
            self.stringValue = stringValue
        } else {
            self.stringValue = "\(components.major).\(components.major).\(components.patch)"
        }
    }

    /// The major version number. This is likely to be 3 for a long time to come yet.
    var majorVersion: Int { Self.components(of: self.intValue).major }
    
    /// The minor version number.
    var minorVersion: Int { Self.components(of: self.intValue).minor }
    
    /// The patch version number.
    var patchVersion: Int { Self.components(of: self.intValue).patch }

    /// See ``SQLDatabaseReportedVersion/isEqual(to:)``.
    func isEqual(to otherVersion: any SQLDatabaseReportedVersion) -> Bool {
        (otherVersion as? _SQLiteDatabaseVersion).map { $0.intValue == self.intValue } ?? false
    }
    
    /// See ``SQLDatabaseReportedVersion/isOlder(than:)``.
    func isOlder(than otherVersion: any SQLDatabaseReportedVersion) -> Bool {
        (otherVersion as? _SQLiteDatabaseVersion).map {
            (self.majorVersion < $0.majorVersion ? true :
            (self.majorVersion > $0.majorVersion ? false :
            (self.minorVersion < $0.minorVersion ? true :
            (self.minorVersion > $0.minorVersion ? false :
            (self.patchVersion < $0.patchVersion ? true : false)))))
        } ?? false
    }
}

private struct _SQLiteSQLDatabase: SQLDatabase {
    let database: any SQLiteDatabase
    
    var eventLoop: any EventLoop {
        self.database.eventLoop
    }
    
    var version: (any SQLDatabaseReportedVersion)? {
        _SQLiteDatabaseVersion.runtimeVersion
    }
    
    var logger: Logger {
        self.database.logger
    }
    
    var dialect: any SQLDialect {
        SQLiteDialect()
    }
    
    func execute(
        sql query: any SQLExpression,
        _ onRow: @escaping (any SQLRow) -> ()
    ) -> EventLoopFuture<Void> {
        var serializer = SQLSerializer(database: self)
        query.serialize(to: &serializer)
        let binds: [SQLiteData]
        do {
            binds = try serializer.binds.map { encodable in
                try SQLiteDataEncoder().encode(encodable)
            }
        } catch {
            return self.eventLoop.makeFailedFuture(error)
        }
        
        // This temporary silliness silences a Sendable capture warning whose correct resolution
        // requires updating SQLKit itself to be fully Sendable-compliant.
        @Sendable func onRowWorkaround(_ row: any SQLRow) {
            onRow(row)
        }
        return self.database.query(serializer.sql, binds, logger: self.logger, onRowWorkaround)
    }
}

