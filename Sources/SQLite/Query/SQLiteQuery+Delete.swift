extension SQLiteQuery {
    /// A `DELETE ...` query.
    public struct Delete {
        /// Name of table to delete from.
        public var table: QualifiedTableName
        
        /// If the WHERE clause is not present, all records in the table are deleted. If a WHERE clause is supplied,
        /// then only those rows for which the WHERE clause boolean expression is true are deleted. Rows for which
        /// the expression is false or NULL are retained.
        public var predicate: Expression?
        
        /// Creates a new `Delete`.
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
    internal func serialize(_ delete: SQLiteQuery.Delete, _ binds: inout [SQLiteData]) -> String {
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
