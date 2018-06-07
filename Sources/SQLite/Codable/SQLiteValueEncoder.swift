struct SQLiteValueEncoder {
    init() { }
    
    func encode<E>(_ value: E) throws -> SQLiteQuery.Expression
        where E: Encodable
    {
        if let value = value as? SQLiteDataConvertible {
            return try .data(value.convertToSQLiteData())
        } else {
            return .literal(.string("FOO"))
        }
    }
}
