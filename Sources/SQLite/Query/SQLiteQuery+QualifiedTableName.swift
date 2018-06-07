extension SQLiteQuery {
    public struct QualifiedTableName {
        public enum Indexing {
            case index(name: String)
            case noIndex
        }
        
        public var table: TableName
        public var indexing: Indexing?
        
        public init(table: TableName, indexing: Indexing? = nil)  {
            self.table = table
            self.indexing = indexing
        }
    }
}


extension SQLiteQuery.QualifiedTableName: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(table: .init(stringLiteral: value))
    }
}

extension SQLiteSerializer {
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
