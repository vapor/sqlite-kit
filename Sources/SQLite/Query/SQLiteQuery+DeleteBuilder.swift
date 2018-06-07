extension SQLiteQuery {
    public final class DeleteBuilder: SQLitePredicateBuilder {
        public var delete: Delete
        public let connection: SQLiteConnection
        public var predicate: SQLiteQuery.Expression? {
            get { return delete.predicate }
            set { delete.predicate = newValue }
        }
        
        init(table: QualifiedTableName, on connection: SQLiteConnection) {
            self.delete = .init(table: table)
            self.connection = connection
        }
        
        public func run() -> Future<Void> {
            return connection.query(.delete(delete)).transform(to: ())
        }
    }
}

extension SQLiteConnection {
    public func delete<Table>(from table: Table.Type) -> SQLiteQuery.DeleteBuilder
        where Table: SQLiteTable
    {
        return .init(table: .init(table: .init(stringLiteral: Table.sqliteTableName)), on: self)
    }
}
