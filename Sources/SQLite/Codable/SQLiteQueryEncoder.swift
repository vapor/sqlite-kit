struct SQLiteQueryEncoder {
    init() { }
    
    func encode<E>(_ value: E) throws -> [String: SQLiteData]
        where E: Encodable
    {
        // VALUE
        fatalError()
    }
}
