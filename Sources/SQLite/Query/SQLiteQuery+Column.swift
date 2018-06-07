extension SQLiteQuery {
    public struct Column {
        public var schema: String?
        public var table: String?
        public var name: String
        
        public init(schema: String? = nil, table: String? = nil, name: String) {
            self.schema = schema
            self.table = table
            self.name = name
        }
    }
}

extension SQLiteQuery.Column: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(name: value)
    }
}

extension SQLiteSerializer {
    func serialize(_ column: SQLiteQuery.Column) -> String {
        switch (column.schema, column.table) {
        case (.some(let schema), .some(let table)):
            return escapeString(schema) + "." + escapeString(table) + "." + escapeString(column.name)
        case (.none, .some(let table)):
            return escapeString(table) + "." + escapeString(column.name)
        default:
            return escapeString(column.name)
        }
    }
}
