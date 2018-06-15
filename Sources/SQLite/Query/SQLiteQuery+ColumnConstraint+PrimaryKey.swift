extension SQLiteQuery.ColumnConstraint {
    public struct PrimaryKey {
        public var direction: SQLiteQuery.Direction?
        public var conflictResolution: SQLiteQuery.ConflictResolution?
        public var autoIncrement: Bool
        
        public init(
            direction: SQLiteQuery.Direction? = nil,
            conflictResolution: SQLiteQuery.ConflictResolution? = nil,
            autoIncrement: Bool = false
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
