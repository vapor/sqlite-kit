import CSQLite

/// A SQLite column. One instance of each column is created per
/// result set and all rows will point to the same column instance.
public final class SQLiteColumn {
    /// The table name.
    public var table: String?

    /// The columns string name.
    public var name: String

    /// Create a new SQLite column from the name.
    public init(name: String) {
        self.name = name
    }

    /// Create a column from a statement pointer and offest.
    init(query: SQLiteQuery.Raw, offset: Int32) throws {
        guard let nameRaw = sqlite3_column_name(query, offset) else {
            throw SQLiteError(problem: .error, reason: "Unexpected nil column name", source: .capture())
        }
        if let tableNameRaw = sqlite3_column_table_name(query, offset) {
            self.table = String(cString: tableNameRaw)
        }
        self.name = String(cString: nameRaw)
    }
}

extension SQLiteColumn: Hashable {
    /// Hashable
    public var hashValue: Int {
        return name.hashValue
    }

    /// Equatable
    public static func ==(lhs: SQLiteColumn, rhs: SQLiteColumn) -> Bool {
        return lhs.name == rhs.name
    }
}

extension SQLiteColumn: CustomStringConvertible {
    /// Column name
    public var description: String {
        return name
    }
}
