extension SQLiteQuery {
    public final class CreateTableBuilder {
        public var create: CreateTable
        public let connection: SQLiteConnection
        
        init(table: TableName, on connection: SQLiteConnection) {
            self.create = .init(table: table, source: .schema(.init(columns: [])))
            self.connection = connection
        }
        
        @discardableResult
        public func column<Table, Value>(
            for keyPath: KeyPath<Table, Value>,
            _ typeName: TypeName? = nil,
            _ constraints: SQLiteQuery.ColumnConstraint...
        ) -> Self
            where Table: SQLiteTable
        {
            var schema: CreateTable.Schema
            switch create.source {
            case .schema(let existing): schema = existing
            case .select: schema = .init(columns: [])
            }
            schema.columns.append(.init(
                name: keyPath.qualifiedColumnName.name,
                typeName: typeName,
                constraints: constraints
            ))
            create.source = .schema(schema)
            return self
        }
        
        public func run() -> Future<Void> {
            return connection.query(.createTable(create)).transform(to: ())
        }
    }
}

extension SQLiteConnection {
    public func create<Table>(table: Table.Type) -> SQLiteQuery.CreateTableBuilder
        where Table: SQLiteTable
    {
        return .init(table: .init(stringLiteral: Table.sqliteTableName), on: self)
    }
}
