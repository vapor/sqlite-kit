extension SQLiteQuery {
    public struct TableName {
        public var schema: String?
        public var name: String
        public var alias: String?
        
        public init(
            schema: String? = nil,
            name: String,
            alias: String? = nil
        ) {
            self.schema = schema
            self.name = name
            self.alias = alias
        }
    }
}

extension SQLiteQuery.TableName: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(name: value)
    }
}

extension SQLiteSerializer {
    func serialize(_ table: SQLiteQuery.TableName) -> String {
        var sql: [String] = []
        if let schema = table.schema {
            sql.append(escapeString(schema) + "." + escapeString(table.name))
        } else {
            sql.append(escapeString(table.name))
        }
        if let alias = table.alias {
            sql.append("AS")
            sql.append(escapeString(alias))
        }
        return sql.joined(separator: " ")
    }
}
