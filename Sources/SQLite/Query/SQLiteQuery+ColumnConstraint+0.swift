extension SQLiteQuery {
    /// SQLite column definition constraint.
    public struct ColumnConstraint {
        /// Creates a new `PRIMARY KEY` column constraint.
        ///
        /// - parameters:
        ///     - direction: Primary key direction.
        ///     - onConflict: `ON CONFLICT` resolution.
        ///     - autoIncrement: If `true`, the primary key will auto increment.
        ///                      `true` by default.
        ///     - named: Optional constraint name.
        /// - returns: New column constraint.
        public static func primaryKey(
            direction: Direction? = nil,
            onConflict: ConflictResolution? = nil,
            autoIncrement: Bool = true,
            named name: String? = nil
        ) -> ColumnConstraint {
            return .init(
                name: name,
                value: .primaryKey(.init(
                    direction: direction,
                    conflictResolution: onConflict,
                    autoIncrement: autoIncrement
                ))
            )
        }
        
        /// Creates a new `NOT NULL` column constraint.
        ///
        /// - parameters:
        ///     - onConflict: `ON CONFLICT` resolution.
        ///     - named: Optional constraint name.
        /// - returns: New column constraint.
        public static func notNull(onConflict: ConflictResolution? = nil, named name: String? = nil) -> ColumnConstraint {
            return .init(
                name: name,
                value: .nullability(.init(allowNull: false, conflictResolution: onConflict))
            )
        }
        
        /// Creates a new `UNIQUE` column constraint.
        ///
        /// - parameters:
        ///     - onConflict: `ON CONFLICT` resolution.
        ///     - named: Optional constraint name.
        /// - returns: New column constraint.
        public static func unique(onConflict: ConflictResolution? = nil, named name: String? = nil) -> ColumnConstraint {
            return .init(
                name: name,
                value: .unique(.init(conflictResolution: onConflict))
            )
        }
        
        /// Creates a new `DEFAULT <expr>` column constraint.
        ///
        /// - parameters
        ///     - expression: Expression to evaluate when setting the default value.
        ///     - named: Optional constraint name.
        /// - returns: New column constraint.
        public static func `default`(_ expression: Expression, named name: String? = nil) -> ColumnConstraint {
            return .init(name: name, value: .default(expression))
        }
        
        /// Creates a new `REFERENCES` column constraint.
        ///
        /// - parameters
        ///     - keyPath: Swift `KeyPath` to referenced column.
        ///     - onDelete: `ON DELETE` foreign key action.
        ///     - onUpdate: `ON UPDATE` foreign key action.
        ///     - deferrable: Foreign key check deferrence.
        ///     - named: Optional constraint name.
        /// - returns: New column constraint.
        public static func references<Table, Value>(
            _ keyPath: KeyPath<Table, Value>,
            onDelete: ForeignKey.Action? = nil,
            onUpdate: ForeignKey.Action? = nil,
            deferrable: ForeignKey.Deferrence? = nil,
            named name: String? = nil
        ) -> ColumnConstraint
            where Table: SQLiteTable
        {
            return .init(
                name: name,
                value: .references(.init(
                    foreignTable: Table.sqliteTableName,
                    foreignColumns: [keyPath.sqliteColumnName.name],
                    onDelete: onDelete,
                    onUpdate: onUpdate,
                    deferrence: deferrable
                )
            ))
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
            case references(ForeignKey.Reference)
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
        public init(name: String? = nil, value: Value) {
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
