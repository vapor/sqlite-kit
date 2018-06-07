public protocol SQLiteQueryExpressionRepresentable {
    var sqliteQueryExpression: SQLiteQuery.Expression { get }
}

struct SQLiteQueryExpressionEncoder {
    init() { }
    
    func encode<E>(_ value: E) throws -> SQLiteQuery.Expression
        where E: Encodable
    {
        if let sqlite = value as? SQLiteQueryExpressionRepresentable {
            return sqlite.sqliteQueryExpression
        } else if let value = value as? SQLiteDataConvertible {
            return try .data(value.convertToSQLiteData())
        } else {
            let encoder = _Encoder()
            do {
                try value.encode(to: encoder)
                return encoder.data!
            } catch is _DoJSONError {
                let json = try JSONEncoder().encode(value)
                return .data(.blob(json))
            }
        }
    }
    
    // MARK: Private
        
    private final class _Encoder: Encoder {
        let codingPath: [CodingKey] = []
        let userInfo: [CodingUserInfoKey: Any] = [:]
        var data: SQLiteQuery.Expression?
        
        init() {
            self.data = nil
        }
        
        func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
            return .init(_KeyedEncodingContainer(encoder: self))
        }
        
        func unkeyedContainer() -> UnkeyedEncodingContainer {
            return _UnkeyedEncodingContainer(encoder: self)
        }
        
        func singleValueContainer() -> SingleValueEncodingContainer {
            return _SingleValueEncodingContainer(encoder: self)
        }
    }
    
    static let _true = Data([0x01])
    static let _false = Data([0x00])
    
    private struct _SingleValueEncodingContainer: SingleValueEncodingContainer {
        let codingPath: [CodingKey] = []
        let encoder: _Encoder
        
        init(encoder: _Encoder) {
            self.encoder = encoder
        }
        
        mutating func encodeNil() throws {
            encoder.data = .literal(.null)
        }
        
        mutating func encode<T>(_ value: T) throws where T : Encodable {
            if let sqlite = value as? SQLiteQueryExpressionRepresentable {
                encoder.data = sqlite.sqliteQueryExpression
                return
            } else if let convertible = value as? SQLiteDataConvertible {
                encoder.data = try .data(convertible.convertToSQLiteData())
                return
            }
            try value.encode(to: encoder)
        }
    }
    
    private struct _DoJSONError: Error { }
    
    private struct _UnkeyedEncodingContainer: UnkeyedEncodingContainer {
        let codingPath: [CodingKey] = []
        let encoder: _Encoder
        var count: Int
        init(encoder: _Encoder) {
            self.encoder = encoder
            self.count = 0
        }
        
        mutating func encodeNil() throws {
            throw _DoJSONError()
        }
        
        mutating func encode<T>(_ value: T) throws where T : Encodable {
            throw _DoJSONError()
        }
        
        mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
            return .init(_KeyedEncodingContainer<NestedKey>(encoder: encoder))
        }
        
        mutating func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
            return _UnkeyedEncodingContainer(encoder: encoder)
        }
        
        mutating func superEncoder() -> Encoder {
            return encoder
        }
    }
    
    private struct _KeyedEncodingContainer<Key>: KeyedEncodingContainerProtocol where Key: CodingKey {
        let codingPath: [CodingKey] = []
        let encoder: _Encoder
        init(encoder: _Encoder) {
            self.encoder = encoder
        }
        
        mutating func encodeNil(forKey key: Key) throws {
            throw _DoJSONError()
        }
        
        mutating func encode<T>(_ value: T, forKey key: Key) throws where T : Encodable {
            throw _DoJSONError()
        }
        
        mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> where NestedKey: CodingKey {
            return .init(_KeyedEncodingContainer<NestedKey>(encoder: encoder))
        }
        
        mutating func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
            return _UnkeyedEncodingContainer(encoder: encoder)
        }
        
        mutating func superEncoder() -> Encoder {
            return encoder
        }
        
        mutating func superEncoder(forKey key: Key) -> Encoder {
            return encoder
        }
    }
}
