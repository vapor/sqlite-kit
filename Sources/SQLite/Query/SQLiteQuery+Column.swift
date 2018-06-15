extension SQLiteQuery {
    /// Represents a SQLite column name with optional table name.
    public struct ColumnName {
        /// Optional table name.
        public var table: TableName?
        
        /// Column name.
        public var name: Name
        
        /// Creates a new `ColumnName`.
        public init(table: TableName? = nil, name: Name) {
            self.table = table
            self.name = name
        }
    }
}

// MARK: String Literal

extension SQLiteQuery.ColumnName: ExpressibleByStringLiteral {
    /// See `ExpressibleByStringLiteral`.
    public init(stringLiteral value: String) {
        self.init(name: .init(stringLiteral: value))
    }
}

// MARK: Serialize

extension SQLiteSerializer {
    func serialize(_ column: SQLiteQuery.ColumnName) -> String {
        if let table = column.table {   
            return serialize(table) + "." + serialize(column.name)
        } else {
            return serialize(column.name)
        }
    }
}
