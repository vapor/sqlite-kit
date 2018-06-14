extension SQLiteQuery {
    public struct Delete {
        public var with: WithClause? = nil
        public var table: QualifiedTableName
        public var predicate: Expression?
        public init(
            with: WithClause? = nil,
            table: QualifiedTableName,
            predicate: Expression? = nil
        ) {
            self.with = with
            self.table = table
            self.predicate = predicate
        }
    }
}

extension SQLiteSerializer {
    func serialize(_ delete: SQLiteQuery.Delete, _ binds: inout [SQLiteData]) -> String {
        var sql: [String] = []
        if let with = delete.with {
            sql.append(serialize(with, &binds))
        }
        sql.append("DELETE FROM")
        sql.append(serialize(delete.table))
        if let predicate = delete.predicate {
            sql.append("WHERE")
            sql.append(serialize(predicate, &binds))
        }
        return sql.joined(separator: " ")
    }
}
