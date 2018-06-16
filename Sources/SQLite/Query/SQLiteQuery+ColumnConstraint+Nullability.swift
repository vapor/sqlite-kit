extension SQLiteQuery.ColumnConstraint {
    /// `NOT NULL` or `NULL` constraint.
    public struct Nullability {
        /// If `true`, this constraint will allow null.
        public var allowNull: Bool
        
        /// `ON CONFLICT` resolution.
        public var conflictResolution: SQLiteQuery.ConflictResolution?
        
        /// Creates a new `Nullability` constraint.
        ///
        /// - parameters:
        ///     - allowNull: If `true`, this constraint will allow null.
        ///                  Defaults to `false`.
        ///     - conflictResolution: `ON CONFLICT` resolution.
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
