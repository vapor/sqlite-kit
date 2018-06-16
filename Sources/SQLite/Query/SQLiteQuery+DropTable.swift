extension SQLiteQuery {
    /// `DROP TABLE` query.
    public struct DropTable {
        /// Name of table to drop.
        public var table: TableName
        
        /// The optional IF EXISTS clause suppresses the error that would normally result if the table does not exist.
        public var ifExists: Bool
        
        /// Creates a new `DropTable` query.
        public init(table: TableName, ifExists: Bool = false) {
            self.table = table
            self.ifExists = ifExists
        }
    }
}

// MARK: Serialize

extension SQLiteSerializer {
    internal func serialize(_ drop: SQLiteQuery.DropTable) -> String {
        var sql: [String] = []
        sql.append("DROP TABLE")
        if drop.ifExists {
            sql.append("IF EXISTS")
        }
        sql.append(serialize(drop.table))
        return sql.joined(separator: " ")
    }
}
