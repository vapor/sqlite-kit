extension SQLAlterTableBuilder where Connectable.Connection.Query.AlterTable == SQLiteAlterTable {
    /// Renames the table.
    ///
    ///     conn.alter(table: Bar.self).rename(to: "foo").run()
    ///
    /// - parameters:
    ///     - to: New table name.
    /// - returns: Self for chaining.
    public func rename(to tableName: SQLiteTableIdentifier) -> Self {
        alterTable.value = .rename(tableName)
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
    public func addColumn<T, V>(
        for keyPath: KeyPath<T, V>,
        type dataType: SQLiteDataType,
        _ constraints: SQLiteColumnConstraint...
    ) -> Self where T: SQLiteTable {
        return addColumn(.columnDefinition(.keyPath(keyPath), dataType, constraints))
    }

    /// Adds a new column to the table. Only one column can be added per `ALTER` statement.
    ///
    ///     conn.alter(table: Planet.self).addColumn(...).run()
    ///
    /// - parameters:
    ///     - columnDefinition: Column definition to add.
    /// - returns: Self for chaining.
    public func addColumn(_ columnDefinition: SQLiteColumnDefinition) -> Self {
        alterTable.value = .addColumn(columnDefinition)
        return self
    }
}
