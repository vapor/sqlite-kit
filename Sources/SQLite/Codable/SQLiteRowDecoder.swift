struct SQLiteRowDecoder {
    init() { }
    
    func decode<D>(_ type: D.Type, from data: [SQLiteColumn: SQLiteData], table: String? = nil) throws -> D
        where D: Decodable
    {
        fatalError()
    }
}

