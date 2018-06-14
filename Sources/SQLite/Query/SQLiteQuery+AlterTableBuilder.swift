extension SQLiteQuery {
    public final class AlterTableBuilder {
        public var alter: AlterTable
        public let connection: SQLiteConnection
        
        init(table: TableName, on connection: SQLiteConnection) {
            self.alter = .init(table: table, value: .rename(table.name))
            self.connection = connection
        }
        
        @discardableResult
        public func rename(to name: String) -> Self {
            alter.value = .rename(name)
            return self
        }
        
        @discardableResult
        public func addColumn<Table, Value>(
            for keyPath: KeyPath<Table, Value>,
            _ typeName: TypeName? = nil,
            _ constraints: SQLiteQuery.ColumnConstraint...
        ) -> Self
            where Table: SQLiteTable
        {
            alter.value = .addColumn(.init(
                name: keyPath.qualifiedColumnName.name,
                typeName: typeName,
                constraints: constraints
            ))
            return self
        }
        
        public func run() -> Future<Void> {
            return connection.query(.alterTable(alter)).transform(to: ())
        }
    }
}

extension SQLiteConnection {
    public func alter<Table>(table: Table.Type) -> SQLiteQuery.AlterTableBuilder
        where Table: SQLiteTable
    {
        return .init(table: .init(stringLiteral: Table.sqliteTableName), on: self)
    }
}
