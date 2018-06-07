struct SQLiteDataDecoder {
    init() { }
    
    func decode<D>(_ type: D.Type, from data: SQLiteData) throws -> D
        where D: Decodable
    {
        fatalError()
    }
}
