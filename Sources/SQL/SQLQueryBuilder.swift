import Async

public protocol SQLQueryBuilder: class {
    associatedtype Connection: SQLConnection
    var query: Connection.Query { get }
    var connection: Connection { get }
}

extension SQLQueryBuilder {
    public func run() -> Future<Void> {
        return connection.query(query) { _ in }
    }
}

public protocol SQLQueryFetcher: SQLQueryBuilder { }

extension SQLQueryFetcher {
    // MARK: Decode
    
    public func all<D>(decoding type: D.Type) -> Future<[D]>
        where D: Decodable
    {
        var all: [D] = []
        return run(decoding: D.self) { all.append($0) }.map { all }
    }
    
    public func run<D>(
        decoding type: D.Type,
        into handler: @escaping (D) throws -> ()
    ) -> Future<Void>
        where D: Decodable
    {
        return run { row in
            let d = try Connection.Query.RowDecoder.init().decode(D.self, from: row, table: nil)
            try handler(d)
        }
    }
    
    // MARK: All
    
    public func all() -> Future<[Connection.Output]> {
        var all: [Connection.Output] = []
        return connection.query(query) { all.append($0) }.map { all }
    }
    
    public func run(_ handler: @escaping (Connection.Output) throws -> ()) -> Future<Void> {
        return connection.query(query, handler)
    }
}


//extension Dictionary where Key == SQLiteColumn, Value == SQLiteData {
//    public func decode<Table>(_ type: Table.Type) throws -> Table where Table: SQLiteTable {
//        return try decode(Table.self, from: Table.sqlTableIdentifier.name.string)
//    }
//
//    public func decode<D>(_ type: D.Type, from table: SQLiteQuery.Expression.ColumnIdentifier.TableIdentifier) throws -> D where D: Decodable {
//        return try SQLiteRowDecoder().decode(D.self, from: self, table: table)
//    }
//}
