extension SQLiteQuery {
    public func serialize(_ binds: inout [SQLiteData]) -> String {
        return SQLiteSerializer().serialize(self, &binds)
    }
}

struct SQLiteSerializer {
    init() { }
    
    func escapeString(_ string: String) -> String {
        return "`" + string + "`"
    }
}
