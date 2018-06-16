extension SQLiteQuery.ColumnConstraint {
    /// `UNIQUE` constraint.
    public struct Unique {
        /// `ON CONFLICT` resolution.
        public var conflictResolution: SQLiteQuery.ConflictResolution?
        
        /// Creates a new `Unique` constraint.
        ///
        /// - parameters:
        ///     - conflictResolution: `ON CONFLICT` resolution.
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
