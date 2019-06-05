extension SQLiteConnection: SQLDatabase {
    public func execute(sql query: SQLExpression, _ onRow: @escaping (SQLRow) throws -> ()) -> EventLoopFuture<Void> {
        var serializer = SQLSerializer(dialect: SQLiteDialect())
        query.serialize(to: &serializer)
        print(serializer.sql)
        return self.query(serializer.sql, serializer.binds.map { encodable in
            return try! SQLiteDataEncoder().encode(encodable)
        }) { row in
            try! onRow(row)
        }
    }
}

extension ConnectionPool: SQLDatabase where Source.Connection: SQLDatabase {
    public func execute(sql query: SQLExpression, _ onRow: @escaping (SQLRow) throws -> ()) -> EventLoopFuture<Void> {
        return self.withConnection { $0.execute(sql: query, onRow) }
    }
}
