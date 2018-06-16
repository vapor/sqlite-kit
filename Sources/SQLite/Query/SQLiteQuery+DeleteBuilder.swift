extension SQLiteQuery {
    /// Builds `Delete` queries.
    public final class DeleteBuilder<Table>: SQLitePredicateBuilder where Table: SQLiteTable {
        /// Query being build.
        public var delete: Delete
        
        /// Database connection to execute the query on.
        public let connection: SQLiteConnection
        
        /// See `SQLitePredicateBuilder`.
        public var predicate: SQLiteQuery.Expression? {
            get { return delete.predicate }
            set { delete.predicate = newValue }
        }
        
        /// Creates a new `DeleteBuilder`.
        internal init(table: Table.Type, on connection: SQLiteConnection) {
            self.delete = .init(table: .init(table: .init(table: Table.sqliteTableName)))
            self.connection = connection
        }
        
        /// Runs the `DELETE` query.
        ///
        /// - returns: A `Future` that signals completion.
        public func run() -> Future<Void> {
            return connection.query(.delete(delete)).transform(to: ())
        }
    }
}

extension SQLiteConnection {
    /// Creates a new `CreateTableBuilder`.
    ///
    ///     conn.delete(from: Planet.self)...
    ///
    /// - parameters:
    ///     - table: Table to delete from.
    /// - returns: `DeleteBuilder`.
    public func delete<Table>(from table: Table.Type) -> SQLiteQuery.DeleteBuilder<Table>
        where Table: SQLiteTable
    {
        return .init(table: Table.self, on: self)
    }
}
