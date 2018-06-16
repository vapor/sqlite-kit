extension SQLiteQuery {
    public struct Update {
        public var conflictResolution: ConflictResolution? = nil
        public var table: QualifiedTableName
        public var values: SetValues
        public var predicate: Expression?
        
        public init(
            conflictResolution: ConflictResolution? = nil,
            table: QualifiedTableName,
            values: SetValues,
            predicate: Expression? = nil
        ) {
            self.conflictResolution = conflictResolution
            self.table = table
            self.values = values
            self.predicate = predicate
        }
    }
}
extension SQLiteSerializer {
    func serialize(_ update: SQLiteQuery.Update, _ binds: inout [SQLiteData]) -> String {
        var sql: [String] = []
        sql.append("UPDATE")
        if let conflictResolution = update.conflictResolution {
            sql.append("OR")
            sql.append(serialize(conflictResolution))
        }
        sql.append(serialize(update.table))
        sql.append(serialize(update.values, &binds))
        if let predicate = update.predicate {
            sql.append("WHERE")
            sql.append(serialize(predicate, &binds))
        }
        return sql.joined(separator: " ")
    }
}
