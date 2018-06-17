/// Encodes `Encodable` values to `SQLiteData`.
///
///     let expr = try SQLiteDataEncoder().encode("Hello")
///     print(expr) // .text("Hello")
///
/// Conform your types to `SQLiteDataConvertible` to
/// customize how they are encoded.
public struct SQLiteDataEncoder {
    /// Creates a new `SQLiteDataEncoder`.
    public init() { }
    
    /// Encodes `Encodable` values to `SQLiteData`.
    ///
    ///     let expr = try SQLiteDataEncoder().encode("Hello")
    ///     print(expr) // .text("Hello")
    ///
    /// - parameters:
    ///     - value: `Encodable` value to encode.
    /// - returns: `SQLiteData` representing the encoded data.
    public func encode(_ value: Encodable) throws -> SQLiteData {
        if let value = value as? SQLiteDataConvertible {
            return try value.convertToSQLiteData()
        } else {
            let encoder = _Encoder()
            do {
                try value.encode(to: encoder)
                return encoder.data!
            } catch is _DoJSONError {
                struct AnyEncodable: Encodable {
                    var encodable: Encodable
                    init(_ encodable: Encodable) {
                        self.encodable = encodable
                    }
                    func encode(to encoder: Encoder) throws {
                        try encodable.encode(to: encoder)
                    }
                }
                let json = try JSONEncoder().encode(AnyEncodable(value))
                return .blob(json)
            }
        }
    }
    
    // MARK: Private
        
    private final class _Encoder: Encoder {
        let codingPath: [CodingKey] = []
        let userInfo: [CodingUserInfoKey: Any] = [:]
        var data: SQLiteData?
        
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
            encoder.data = .null
        }
        
        mutating func encode<T>(_ value: T) throws where T : Encodable {
            if let convertible = value as? SQLiteDataConvertible {
                encoder.data = try convertible.convertToSQLiteData()
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
