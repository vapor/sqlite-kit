extension SQLiteQuery {
    /// Column definition.
    public struct ColumnDefinition {
        /// Column name.
        public var name: Name
        
        /// Column type name.
        public var typeName: TypeName
        
        /// Zero or more column constraints.
        public var constraints: [ColumnConstraint]
        
        /// Creates a new `ColumnDefinition`.
        ///
        /// - parameters:
        ///     - name: Column name.
        ///     - typeName: Column type name.
        ///     - constraints: Zero or more column constraints.
        public init(name: Name, typeName: TypeName, constraints: [ColumnConstraint] = []) {
            self.name = name
            self.typeName = typeName
            self.constraints = constraints
        }
    }
}

// MARK: Serialize

extension SQLiteSerializer {
    func serialize(_ columnDefinition: SQLiteQuery.ColumnDefinition, _ binds: inout [SQLiteData]) -> String {
        var sql: [String] = []
        sql.append(serialize(columnDefinition.name))
        sql.append(serialize(columnDefinition.typeName))
        sql += columnDefinition.constraints.map { serialize($0, &binds) }
        return sql.joined(separator: " ")
    }
}
