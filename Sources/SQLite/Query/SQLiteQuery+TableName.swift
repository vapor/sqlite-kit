extension SQLiteQuery {
    public struct TableName {
        public var schema: String?
        public var name: String
        
        public init(schema: String? = nil, name: String) {
            self.schema = schema
            self.name = name
        }
    }
    
    public struct AliasableTableName {
        public var table: TableName
        public var alias: String?
        
        public init(table: TableName, alias: String? = nil) {
            self.table = table
            self.alias = alias
        }
    }
    
    
    public struct QualifiedTableName {
        public enum Indexing {
            case index(name: String)
            case noIndex
        }
        
        public var table: AliasableTableName
        public var indexing: Indexing?
        
        public init(table: AliasableTableName, indexing: Indexing? = nil)  {
            self.table = table
            self.indexing = indexing
        }
    }
}

extension SQLiteQuery.TableName: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(name: value)
    }
}

extension SQLiteQuery.AliasableTableName: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(table: .init(stringLiteral: value))
    }
}

extension SQLiteQuery.QualifiedTableName: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(table: .init(stringLiteral: value))
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
        return sql.joined(separator: " ")
    }
    
    func serialize(_ table: SQLiteQuery.AliasableTableName) -> String {
        var sql: [String] = []
        sql.append(serialize(table.table))
        if let alias = table.alias {
            sql.append("AS")
            sql.append(escapeString(alias))
        }
        return sql.joined(separator: " ")
    }
    func serialize(_ qualifiedTable: SQLiteQuery.QualifiedTableName) -> String {
        var sql: [String] = []
        sql.append(serialize(qualifiedTable.table))
        if let indexing = qualifiedTable.indexing {
            sql.append(serialize(indexing))
        }
        return sql.joined(separator: " ")
    }
    
    func serialize(_ qualifiedTable: SQLiteQuery.QualifiedTableName.Indexing) -> String {
        switch qualifiedTable {
        case .index(let name): return "INDEXED BY " + escapeString(name)
        case .noIndex: return "NOT INDEXED"
        }
    }
}
