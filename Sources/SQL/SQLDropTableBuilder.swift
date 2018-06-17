public final class SQLDropTableBuilder<Connection>: SQLQueryBuilder
    where Connection: SQLConnection
{
    /// `DropTable` query being built.
    public var dropTable: Connection.Query.DropTable
    
    /// See `SQLQueryBuilder`.
    public var connection: Connection
    
    /// See `SQLQueryBuilder`.
    public var query: Connection.Query {
        return .dropTable(dropTable)
    }
    
    /// Creates a new `SQLDropTableBuilder`.
    public init(_ dropTable: Connection.Query.DropTable, on connection: Connection) {
        self.dropTable = dropTable
        self.connection = connection
    }
    
    public func ifExists() -> Self {
        dropTable.ifExists = true
        return self
    }
}

// MARK: Connection

extension SQLConnection {
    public func drop<Table>(table: Table.Type) -> SQLDropTableBuilder<Self>
        where Table: SQLTable
    {
        return .init(.dropTable(.table(Table.self), ifExists: false), on: self)
    }
}
