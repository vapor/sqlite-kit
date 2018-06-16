extension SQLiteQuery {
    /// A `DELETE ...` query.
    public struct Delete {
        ///
        public var table: QualifiedTableName
        public var predicate: Expression?
        public init(
            table: QualifiedTableName,
            predicate: Expression? = nil
        ) {
            self.table = table
            self.predicate = predicate
        }
    }
}

// MARK: Serialize

extension SQLiteSerializer {
    func serialize(_ delete: SQLiteQuery.Delete, _ binds: inout [SQLiteData]) -> String {
        var sql: [String] = []
        sql.append("DELETE FROM")
        sql.append(serialize(delete.table))
        if let predicate = delete.predicate {
            sql.append("WHERE")
            sql.append(serialize(predicate, &binds))
        }
        return sql.joined(separator: " ")
    }
}
