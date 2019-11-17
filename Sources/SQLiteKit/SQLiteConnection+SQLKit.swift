extension SQLiteDatabase {
    public func sql() -> SQLDatabase {
        _SQLiteSQLDatabase(database: self)
    }
}

private struct _SQLiteSQLDatabase: SQLDatabase {
    let database: SQLiteDatabase
    
    var eventLoop: EventLoop {
        return self.database.eventLoop
    }
    
    var logger: Logger {
        return self.database.logger
    }
    
    var dialect: SQLDialect {
        SQLiteDialect()
    }
    
    func execute(
        sql query: SQLExpression,
        _ onRow: @escaping (SQLRow) -> ()
    ) -> EventLoopFuture<Void> {
        var serializer = SQLSerializer(database: self)
        query.serialize(to: &serializer)
        let binds: [SQLiteData]
        do {
            binds = try serializer.binds.map { encodable in
                return try SQLiteDataEncoder().encode(encodable)
            }
        } catch {
            return self.eventLoop.makeFailedFuture(error)
        }
        return self.database.query(
            serializer.sql,
            binds,
            logger: self.logger
        ) { row in
            onRow(row)
        }
    }
}
