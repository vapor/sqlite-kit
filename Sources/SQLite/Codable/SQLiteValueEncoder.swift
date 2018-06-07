struct SQLiteValueEncoder {
    init() { }
    
    func encode<E>(_ value: E) throws -> SQLiteData
        where E: Encodable
    {
        // VALUE
        fatalError()
    }
}
