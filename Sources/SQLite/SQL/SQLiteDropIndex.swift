public struct SQLiteDropIndex: SQLDropIndex {
    public var identifier: SQLiteIdentifier
    
    /// See `SQLSerializable`.
    public func serialize(_ binds: inout [Encodable]) -> String {
        var sql: [String] = []
        sql.append("DROP INDEX")
        sql.append(identifier.serialize(&binds))
        return sql.joined(separator: " ")
    }
}

public final class SQLiteDropIndexBuilder<Connection>: SQLQueryBuilder
    where Connection: SQLConnection, Connection.Query == SQLiteQuery
{
    /// `AlterTable` query being built.
    public var dropIndex: SQLiteDropIndex
    
    /// See `SQLQueryBuilder`.
    public var connection: Connection
    
    /// See `SQLQueryBuilder`.
    public var query: SQLiteQuery {
        return .dropIndex(dropIndex)
    }
    
    /// Creates a new `SQLCreateIndexBuilder`.
    public init(_ dropIndex: SQLiteDropIndex, on connection: Connection) {
        self.dropIndex = dropIndex
        self.connection = connection
    }
}


extension SQLConnection where Query == SQLiteQuery {
    public func drop(index identifier: SQLiteIdentifier) -> SQLiteDropIndexBuilder<Self> {
        return .init(SQLiteDropIndex(identifier: identifier), on: self)
    }
}
