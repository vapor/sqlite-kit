extension SQLiteQuery.ColumnConstraint {
    public struct Unique {
        public var conflictResolution: SQLiteQuery.ConflictResolution?
        
        public init(conflictResolution: SQLiteQuery.ConflictResolution? = nil) {
            self.conflictResolution = conflictResolution
        }
    }
}

// MARK: Serializer

extension SQLiteSerializer {
    public func serialize(_ unique: SQLiteQuery.ColumnConstraint.Unique) -> String {
        var sql: [String] = []
        sql.append("UNIQUE")
        if let conflictResolution = unique.conflictResolution {
            sql.append("ON CONFLICT")
            sql.append(serialize(conflictResolution))
        }
        return sql.joined(separator: " ")
    }
}
