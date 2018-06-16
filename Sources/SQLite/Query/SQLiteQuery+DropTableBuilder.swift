extension SQLiteQuery {
    /// Builds a `DropTable` query.
    public final class DropTableBuilder<Table> where Table: SQLiteTable {
        /// Query being built.
        public var drop: DropTable
        
        /// Database connection to execute the query on.
        public let connection: SQLiteConnection
        
        /// Creates a new `DropTableBuilder`.
        init(table: Table.Type, on connection: SQLiteConnection) {
            self.drop = .init(table: Table.sqliteTableName)
            self.connection = connection
        }
        
        /// The optional IF EXISTS clause suppresses the error that would normally result if the table does not exist.
        public func ifExists() -> Self {
            drop.ifExists = true
            return self
        }
        
        /// Runs the `DROP TABLE` query.
        ///
        /// - returns: A `Future` that signals completion.
        public func run() -> Future<Void> {
            return connection.query(.dropTable(drop)).transform(to: ())
        }
    }
}

extension SQLiteConnection {
    /// Creates a new `DropTableBuilder`.
    ///
    ///     conn.drop(table: Planet.self)...
    ///
    /// - parameters:
    ///     - table: Table to drop.
    /// - returns: `DropTableBuilder`.
    public func drop<Table>(table: Table.Type) -> SQLiteQuery.DropTableBuilder<Table>
        where Table: SQLiteTable
    {
        return .init(table: Table.self, on: self)
    }
}
