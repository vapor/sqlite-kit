extension SQLiteConnection {
    public func sql(logger: Logger? = nil) -> SQLDatabase {
        SQLiteSQLDatabase(
            connection: self,
            logger: logger ?? self.logger
        )
    }
}

private struct SQLiteSQLDatabase: SQLDatabase {
    let connection: SQLiteConnection
    let logger: Logger
    var eventLoop: EventLoop {
        return self.connection.eventLoop
    }
    
    func execute(sql query: SQLExpression, _ onRow: @escaping (SQLRow) -> ()) -> EventLoopFuture<Void> {
        var serializer = SQLSerializer(dialect: SQLiteDialect())
        query.serialize(to: &serializer)
        let binds: [SQLiteData]
        do {
            binds = try serializer.binds.map { encodable in
                return try SQLiteDataEncoder().encode(encodable)
            }
        } catch {
            return self.eventLoop.makeFailedFuture(error)
        }
        return self.connection.query(
            serializer.sql,
            binds,
            logger: self.logger
        ) { row in
            onRow(row)
        }
    }
}
