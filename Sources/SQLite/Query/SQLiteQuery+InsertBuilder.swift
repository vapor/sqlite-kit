extension SQLiteQuery {
    public final class InsertBuilder {
        public var insert: Insert
        public let connection: SQLiteConnection
        
        init(table: TableName, on connection: SQLiteConnection) {
            self.insert = .init(table: table)
            self.connection = connection
        }
        
        @discardableResult
        public func or(_ conflictResolution: SQLiteQuery.ConflictResolution) -> Self {
            insert.conflictResolution = conflictResolution
            return self
        }
        
        @discardableResult
        public func defaults() throws -> Self {
            insert.values = .defaults
            return self
        }
        
        @discardableResult
        public func from(_ select: (SelectBuilder) -> ()) throws -> Self {
            let builder = connection.select()
            select(builder)
            insert.values = .select(builder.select)
            return self
        }
        
        @discardableResult
        public func value<E>(_ value: E) throws -> Self
            where E: Encodable
        {
            try values([value])
            return self
        }
        
        @discardableResult
        public func values<E>(_ values: [E]) throws -> Self
            where E: Encodable
        {
            let values = try values.map { try SQLiteQueryEncoder().encode($0) }
            insert.columns = .init(values[0].keys)
            insert.values = .values(values.map { .init($0.values) })
            return self
        }
        
        public func run() -> Future<Void> {
            return connection.query(.insert(insert)).transform(to: ())
        }
    }
}

extension SQLiteConnection {
    public func insert<Table>(into table: Table.Type) -> SQLiteQuery.InsertBuilder
        where Table: SQLiteTable
    {
        return .init(table: .init(name: Table.sqliteTableName), on: self)
    }
}
