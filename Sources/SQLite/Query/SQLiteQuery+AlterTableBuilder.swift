extension SQLiteQuery {
    /// Builds `AlterTable` queries.
    public final class AlterTableBuilder<Table> where Table: SQLiteTable {
        /// Query being built.
        public var alter: AlterTable
        
        /// Database connection to execute the query on.
        public let connection: SQLiteConnection
        
        /// Creates a new `AlterTableBuilder`.
        ///
        /// - parameters:
        ///     - table: Name of existing table to alter.
        ///     - connection: `SQLiteConnection` to perform the query on.
        init(table: Table.Type, on connection: SQLiteConnection) {
            self.alter = .init(table: Table.sqliteTableName, value: .rename(Table.sqliteTableName.name))
            self.connection = connection
        }
        
        /// Renames the table.
        ///
        ///     conn.alter(table: Bar.self).rename(to: "foo").run()
        ///
        /// - parameters:
        ///     - to: New table name.
        /// - returns: Self for chaining.
        public func rename(to tableName: Name) -> Self {
            alter.value = .rename(tableName)
            return self
        }
        
        /// Adds a new column to the table. Only one column can be added per `ALTER` statement.
        ///
        ///     conn.alter(table: Planet.self).addColumn(for: \.name, type: .text, .notNull).run()
        ///
        /// - parameters:
        ///     - keyPath: Swift `KeyPath` to property that should be added.
        ///     - type: Name of type to use for this column.
        ///     - constraints: Zero or more column constraints to add.
        /// - returns: Self for chaining.
        public func addColumn<Value>(
            for keyPath: KeyPath<Table, Value>,
            type typeName: TypeName,
            _ constraints: SQLiteQuery.ColumnConstraint...
        ) -> Self {
            return addColumn(.init(name: keyPath.sqliteColumnName.name, typeName: typeName, constraints: constraints))
        }
        
        /// Adds a new column to the table. Only one column can be added per `ALTER` statement.
        ///
        ///     conn.alter(table: Planet.self).addColumn(...).run()
        ///
        /// - parameters:
        ///     - columnDefinition: Column definition to add.
        /// - returns: Self for chaining.
        public func addColumn(_ columnDefinition: ColumnDefinition) -> Self {
            alter.value = .addColumn(columnDefinition)
            return self
        }
        
        /// Runs the `ALTER` query.
        ///
        /// - returns: A `Future` that signals completion.
        public func run() -> Future<Void> {
            return connection.query(.alterTable(alter)).transform(to: ())
        }
    }
}

extension SQLiteConnection {
    /// Creates a new `AlterTableBuilder`.
    ///
    ///     conn.alter(table: Planet.self)...
    ///
    /// - parameters:
    ///     - table: Table to alter.
    /// - returns: `AlterTableBuilder`.
    public func alter<Table>(table: Table.Type) -> SQLiteQuery.AlterTableBuilder<Table>
        where Table: SQLiteTable
    {
        return .init(table: Table.self, on: self)
    }
}
