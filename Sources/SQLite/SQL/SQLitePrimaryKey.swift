/// SQLite specific `SQLPrimaryKeyDefault`.
public enum SQLitePrimaryKeyDefault: SQLPrimaryKeyDefault {
    /// See `SQLPrimaryKey`.
    public static var `default`: SQLitePrimaryKeyDefault {
        return .autoIncrement
    }
    
    /// Default. Uses ROWID as default primary key.
    case rowID
    
    /// The AUTOINCREMENT keyword imposes extra CPU, memory, disk space, and disk I/O overhead and should be avoided if not strictly needed.
    /// It is usually not needed.
    ///
    /// In SQLite, a column with type INTEGER PRIMARY KEY is an alias for the ROWID (except in WITHOUT ROWID tables) which is always a 64-bit
    /// signed integer.
    ///
    /// https://www.sqlite.org/autoinc.html
    case autoIncrement
    
    /// See `SQLSerializable`.
    public func serialize(_ binds: inout [Encodable]) -> String {
        switch self {
        case .rowID: return ""
        case .autoIncrement: return "AUTOINCREMENT"
        }
    }
}
