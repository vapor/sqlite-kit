import Async

public protocol SQLConnection {
    associatedtype Output
    associatedtype Query: SQLQuery
        where Query.RowDecoder.Row == Output 
    func query(_ query: Query, _ handler: @escaping (Output) throws -> ()) -> Future<Void>
}

extension SQLConnection {
    public func query(_ sql: String, _ binds: [Encodable] = [], _ handler: @escaping (Output) throws -> ()) -> Future<Void> {
        return query(.raw(sql, binds: binds), handler)
    }

    public func query(_ sql: String, _ binds: [Encodable] = []) -> Future<[Output]> {
        return query(.raw(sql, binds: binds))
    }

    /// Executes the supplied `SQLiteQuery` on the connection, aggregating the results into an array.
    ///
    ///     let rows = try conn.query("SELECT * FROM users").wait()
    ///
    /// - parameters:
    ///     - query: `SQLiteQuery` to execute.
    /// - returns: A `Future` containing array of rows.
    public func query(_ query: Query) -> Future<[Output]> {
        var rows: [Output] = []
        return self.query(query) { rows.append($0) }.map { rows }
    }
}
