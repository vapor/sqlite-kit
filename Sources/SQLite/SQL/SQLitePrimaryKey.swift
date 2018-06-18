public struct SQLitePrimaryKey: SQLPrimaryKey {
    /// See `SQLPrimaryKey`.
    public static func primaryKey() -> SQLitePrimaryKey {
        return .init(autoIncrement: false)
    }
    
    /// See `SQLPrimaryKey`.
    public static func primaryKey(autoIncrement: Bool) -> SQLitePrimaryKey {
        return .init(autoIncrement: autoIncrement)
    }
    
    /// The AUTOINCREMENT keyword imposes extra CPU, memory, disk space, and disk I/O overhead and should be avoided if not strictly needed.
    /// It is usually not needed.
    ///
    /// In SQLite, a column with type INTEGER PRIMARY KEY is an alias for the ROWID (except in WITHOUT ROWID tables) which is always a 64-bit
    /// signed integer.
    ///
    /// https://www.sqlite.org/autoinc.html
    public var autoIncrement: Bool
    
    /// See `SQLSerializable`.
    public func serialize(_ binds: inout [Encodable]) -> String {
        if autoIncrement {
            return "AUTOINCREMENT"
        } else {
            return ""
        }
    }
}

extension SQLColumnConstraint where ColumnConstraintAlgorithm.PrimaryKey == SQLitePrimaryKey {
    public static func primaryKey(autoIncrement: Bool) -> Self {
        return .constraint(.primaryKey(.primaryKey(autoIncrement: autoIncrement)), nil)
    }
}
