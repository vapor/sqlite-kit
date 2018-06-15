extension SQLiteQuery {
    /// SQLite column definition constraint.
    public struct ColumnConstraint {
        /// Creates a new `PRIMARY KEY` column constraint.
        ///
        /// - parameters:
        ///     - autoIncrement: If `true`, the primary key will auto increment.
        ///                      `true` by default.
        /// - returns: New column constraint.
        public static func primaryKey(autoIncrement: Bool = true) -> ColumnConstraint {
            return .init(.primaryKey(.init(autoIncrement: autoIncrement)))
        }
        
        /// Creates a new `NOT NULL` column constraint.
        public static var notNull: ColumnConstraint {
            return .init(.nullability(.init(allowNull: false)))
        }
        
        /// Creates a new `DEFAULT <expr>` column constraint.
        ///
        /// - parameters
        ///     - expression: Expression to evaluate when setting the default value.
        /// - returns: New column constraint.
        public static func `default`(_ expression: Expression) -> ColumnConstraint {
            return .init(.default(expression))
        }
        
        /// Creates a new `REFERENCES` column constraint.
        ///
        /// - parameters
        ///     - keyPath: Swift `KeyPath` to referenced column.
        /// - returns: New column constraint.
        public static func references<Table, Value>(_ keyPath: KeyPath<Table, Value>) -> ColumnConstraint
            where Table: SQLiteTable
        {
            return .init(.references(.init(
                foreignTable: Table.sqliteTableName,
                foreignColumns: [keyPath.sqliteColumnName.name],
                onDelete: nil,
                onUpdate: nil,
                match: nil,
                deferrence: nil
            )))
        }
        
        /// Supported column constraint values.
        public enum Value {
            /// `PRIMARY KEY`
            case primaryKey(PrimaryKey)
            
            /// `NULL` or `NOT NULL`
            case nullability(Nullability)
            
            /// `UNIQUE`
            case unique(Unique)
            
            /// `CHECK`
            case check(Expression)
            
            /// `DEFAULT`
            case `default`(Expression)
            
            /// `COLLATE`
            case collate(String)
            
            /// `REFERENCES`
            case references(ForeignKeyReference)
        }
        
        /// Optional constraint name.
        public var name: String?
        
        /// Contraint value.
        public var value: Value
        
        /// Creates a new `ColumnConstraint`.
        ///
        /// - parameters:
        ///     - name: Optional constraint name.
        ///     - value: Constraint value.
        public init(name: String? = nil, _ value: Value) {
            self.name = name
            self.value = value
        }
    }
}

// MARK: Serialize

extension SQLiteSerializer {
    func serialize(_ constraint: SQLiteQuery.ColumnConstraint, _ binds: inout [SQLiteData]) -> String {
        var sql: [String] = []
        if let name = constraint.name {
            sql.append("CONSTRAINT")
            sql.append(escapeString(name))
        }
        sql.append(serialize(constraint.value, &binds))
        return sql.joined(separator: " ")
    }
    
    func serialize(_ value: SQLiteQuery.ColumnConstraint.Value, _ binds: inout [SQLiteData]) -> String {
        switch value {
        case .primaryKey(let primaryKey): return serialize(primaryKey)
        case .nullability(let nullability): return serialize(nullability)
        case .unique(let unique): return serialize(unique)
        case .check(let expr): return "CHECK (" + serialize(expr, &binds) + ")"
        case .default(let expr): return "DEFAULT (" + serialize(expr, &binds) + ")"
        case .collate(let name): return "COLLATE " + name
        case .references(let reference): return serialize(reference)
        }
    }
}
