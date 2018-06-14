extension SQLiteQuery {
    public final class DropTableBuilder {
        public var drop: DropTable
        public let connection: SQLiteConnection
        
        init(table: TableName, on connection: SQLiteConnection) {
            self.drop = .init(table: table)
            self.connection = connection
        }
        
        @discardableResult
        public func ifExists() -> Self {
            drop.ifExists = true
            return self
        }
        
        public func run() -> Future<Void> {
            return connection.query(.dropTable(drop)).transform(to: ())
        }
    }
}

extension SQLiteConnection {
    public func drop<Table>(table: Table.Type) -> SQLiteQuery.DropTableBuilder
        where Table: SQLiteTable
    {
        return .init(table: .init(stringLiteral: Table.sqliteTableName), on: self)
    }
}
