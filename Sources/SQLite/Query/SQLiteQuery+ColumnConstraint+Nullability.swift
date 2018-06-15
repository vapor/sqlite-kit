extension SQLiteQuery.ColumnConstraint {
    public struct Nullability {
        public var allowNull: Bool
        public var conflictResolution: SQLiteQuery.ConflictResolution?
        
        public init(allowNull: Bool = false, conflictResolution: SQLiteQuery.ConflictResolution? = nil) {
            self.allowNull = allowNull
            self.conflictResolution = conflictResolution
        }
    }
}


// MARK: Serialize

extension SQLiteSerializer {
    public func serialize(_ nullability: SQLiteQuery.ColumnConstraint.Nullability) -> String {
        var sql: [String] = []
        if !nullability.allowNull {
            sql.append("NOT")
        }
        sql.append("NULL")
        if let conflictResolution = nullability.conflictResolution {
            sql.append("ON CONFLICT")
            sql.append(serialize(conflictResolution))
        }
        return sql.joined(separator: " ")
    }
}
