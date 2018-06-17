public final class SQLDeleteBuilder<Connection>: SQLQueryBuilder, SQLWhereBuilder
    where Connection: SQLConnection
{
    /// `Delete` query being built.
    public var delete: Connection.Query.Delete
    
    /// See `SQLQueryBuilder`.
    public var connection: Connection
    
    /// See `SQLQueryBuilder`.
    public var query: Connection.Query {
        return .delete(delete)
    }
    
    /// See `SQLWhereBuilder`.
    public var `where`: Connection.Query.Delete.Expression? {
        get { return delete.where }
        set { delete.where = newValue }
    }
    
    /// Creates a new `SQLDeleteBuilder`.
    public init(_ delete: Connection.Query.Delete, on connection: Connection) {
        self.delete = delete
        self.connection = connection
    }
}

// MARK: Connection

extension SQLConnection {
    /// Creates a new `SQLDeleteBuilder`.
    ///
    ///     conn.delete(from: Planet.self)...
    ///
    /// - parameters:
    ///     - table: Table to delete from.
    /// - returns: Newly created `SQLDeleteBuilder`.
    public func delete<Table>(from table: Table.Type) -> SQLDeleteBuilder<Self>
        where Table: SQLTable
    {
        return .init(.delete(.table(Table.self)), on: self)
    }
}
