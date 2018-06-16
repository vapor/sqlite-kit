extension SQLiteQuery.ColumnConstraint {
    /// `PRIMARY KEY` constraint.
    public struct PrimaryKey {
        /// Primary key direction.
        public var direction: SQLiteQuery.Direction?
        
        /// `ON CONFLICT` resolution.
        public var conflictResolution: SQLiteQuery.ConflictResolution?
        
        //// If `true`, this primary key will autoincrement.
        public var autoIncrement: Bool
        
        /// Creates a new `PrimaryKey` constraint.
        ///
        /// - parameters:
        ///     - direction: Primary key direction.
        ///     - conflictResolution: `ON CONFLICT` resolution.
        ///     - autoIncrement: If `true`, this primary key will autoincrement.
        ///                      Defaults to `true`.
        public init(
            direction: SQLiteQuery.Direction? = nil,
            conflictResolution: SQLiteQuery.ConflictResolution? = nil,
            autoIncrement: Bool = true
        ) {
            self.direction = direction
            self.conflictResolution = conflictResolution
            self.autoIncrement = autoIncrement
        }
    }
}


// MARK: Serialize

extension SQLiteSerializer {
    public func serialize(_ primaryKey: SQLiteQuery.ColumnConstraint.PrimaryKey) -> String {
        var sql: [String] = []
        sql.append("PRIMARY KEY")
        if let direction = primaryKey.direction {
            sql.append(serialize(direction))
        }
        if let conflictResolution = primaryKey.conflictResolution {
            sql.append("ON CONFLICT")
            sql.append(serialize(conflictResolution))
        }
        if primaryKey.autoIncrement {
            sql.append("AUTOINCREMENT")
        }
        return sql.joined(separator: " ")
    }
}
