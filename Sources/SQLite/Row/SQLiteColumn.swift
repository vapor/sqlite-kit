public struct SQLiteColumn {
    /// The table name.
    public var table: String?

    /// The columns string name.
    public var name: String

    /// Create a new SQLite column from the name.
    public init(table: String? = nil, name: String) {
        self.table = table
        self.name = name
    }
}

extension Dictionary where Key == SQLiteColumn {
    /// Returns the first matching value for a `SQLiteColumn` in a dictionary.
    public func firstValue(forColumn name: String, inTable table: String? = nil) -> Value? {
        for (col, val) in self {
            if (col.table == nil || table == nil || col.table == table) && col.name == name {
                return val
            }
        }
        return nil
    }
}

extension SQLiteColumn: ExpressibleByStringLiteral {
    /// See `ExpressibleByStringLiteral`.
    public init(stringLiteral value: String) {
        self.init(name: value)
    }
}

extension SQLiteColumn: Hashable {
    /// See `Hashable`.
    public var hashValue: Int {
        if let table = table {
            return table.hashValue &+ name.hashValue
        } else {
            return name.hashValue
        }
    }
}

extension SQLiteColumn: Equatable {
    /// See `Equatable`.
    public static func ==(lhs: SQLiteColumn, rhs: SQLiteColumn) -> Bool {
        return lhs.table == rhs.table && lhs.name == rhs.name
    }
}

extension SQLiteColumn: CustomStringConvertible {
    /// See `CustomStringConvertible`.
    public var description: String {
        if let table = table {
            return table + "." + name
        } else {
            return name
        }
    }
}
