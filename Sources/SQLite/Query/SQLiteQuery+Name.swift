extension SQLiteQuery {
    /// Represents a SQLite column, schema, table, or constraint name.
    public struct Name {
        /// String value.
        public var string: String
        
        /// Creates a new `Name`.
        ///
        /// - parameters:
        ///     - string: String value.
        public init(_ string: String) {
            self.string = string
        }
    }
}

// MARK: String Literal

extension SQLiteQuery.Name: ExpressibleByStringLiteral {
    /// See `ExpressibleByStringLiteral`.
    public init(stringLiteral value: String) {
        self.init(value)
    }
}

// MARK: Serialize

extension SQLiteSerializer {
    func serialize(_ columns: [SQLiteQuery.Name]) -> String {
        return "(" + columns.map(serialize).joined(separator: ", ") + ")"
    }
    
    func serialize(_ name: SQLiteQuery.Name) -> String {
        return escapeString(name.string)
    }
}
