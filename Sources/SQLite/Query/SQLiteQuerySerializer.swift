extension SQLiteQuery {
    public func serialize(_ binds: inout [SQLiteData]) -> String {
        return SQLiteSerializer().serialize(self, &binds)
    }
}

struct SQLiteSerializer {
    init() { }
    
    func serialize(columns: [String]) -> String {
        return "(" + columns.map(escapeString).joined(separator: ", ") + ")"
    }
    
    func escapeString(_ string: String) -> String {
        return "`" + string + "`"
    }
}

public protocol SQLiteQueryBuilder {
    var connection: SQLiteConnection { get }
    var query: SQLiteQuery { get }
}

extension SQLiteQueryBuilder {
    public func all<D>(_ type: D.Type) -> Future<[D]>
        where D: Decodable
    {
        return all().map { try $0.map { try SQLiteRowDecoder().decode(D.self, from: $0) } }
    }
    
    public func all() -> Future<[[SQLiteColumn: SQLiteData]]> {
        return connection.query(query)
    }
}
