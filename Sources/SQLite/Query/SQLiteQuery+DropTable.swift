extension SQLiteQuery {
    public struct DropTable {
        public var table: TableName
        public var ifExists: Bool
        
        public init(table: TableName, ifExists: Bool = false) {
            self.table = table
            self.ifExists = ifExists
        }
    }
}

extension SQLiteSerializer {
    func serialize(_ drop: SQLiteQuery.DropTable) -> String {
        var sql: [String] = []
        sql.append("DROP TABLE")
        if drop.ifExists {
            sql.append("IF EXISTS")
        }
        sql.append(serialize(drop.table))
        return sql.joined(separator: " ")
    }
}
