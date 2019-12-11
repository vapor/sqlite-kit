import NIO
import Foundation

public struct SQLiteDataEncoder {
    public init() { }

    public func encode(_ type: Encodable) throws -> SQLiteData {
        if let custom = try _encode(type, codingPath: []) {
            return custom
        } else {
            do {
                let encoder = _Encoder()
                try type.encode(to: encoder)
                return encoder.data
            } catch is DoJSON {
                let json = JSONEncoder()
                let data = try json.encode(Wrapper(type))
                var buffer = ByteBufferAllocator().buffer(capacity: data.count)
                buffer.writeBytes(data)
                return SQLiteData.blob(buffer)
            }
        }
    }

    private final class _Encoder: Encoder {
        var codingPath: [CodingKey] {
            return []
        }

        var userInfo: [CodingUserInfoKey : Any] {
            return [:]
        }
        var data: SQLiteData
        init() {
            self.data = .null
        }

        func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
            return .init(_KeyedValueEncoder(self))
        }

        func unkeyedContainer() -> UnkeyedEncodingContainer {
            _UnkeyedEncodingContainer(self)
        }

        func singleValueContainer() -> SingleValueEncodingContainer {
            _SingleValueEncoder(self)
        }
    }

    struct DoJSON: Error {}

    struct Wrapper: Encodable {
        let encodable: Encodable
        init(_ encodable: Encodable) {
            self.encodable = encodable
        }
        func encode(to encoder: Encoder) throws {
            try self.encodable.encode(to: encoder)
        }
    }

    private struct _UnkeyedEncodingContainer: UnkeyedEncodingContainer {
        var codingPath: [CodingKey] {
            self.encoder.codingPath
        }
        var count: Int {
            0
        }

        let encoder: _Encoder
        init(_ encoder: _Encoder) {
            self.encoder = encoder
        }

        mutating func encodeNil() throws {
            throw DoJSON()
        }

        mutating func encode<T>(_ value: T) throws
            where T: Encodable
        {
            throw DoJSON()
        }


        mutating func nestedContainer<NestedKey>(
            keyedBy keyType: NestedKey.Type
        ) -> KeyedEncodingContainer<NestedKey>
            where NestedKey : CodingKey
        {
            self.encoder.container(keyedBy: NestedKey.self)
        }

        mutating func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
            self.encoder.unkeyedContainer()
        }

        mutating func superEncoder() -> Encoder {
            self.encoder
        }
    }

    private struct _KeyedValueEncoder<Key>: KeyedEncodingContainerProtocol where Key: CodingKey {
        var codingPath: [CodingKey] {
            return self.encoder.codingPath
        }

        let encoder: _Encoder
        init(_ encoder: _Encoder) {
            self.encoder = encoder
        }

        mutating func encodeNil(forKey key: Key) throws {
            throw DoJSON()
        }

        mutating func encode<T>(_ value: T, forKey key: Key) throws where T : Encodable {
            throw DoJSON()
        }

        mutating func nestedContainer<NestedKey>(
            keyedBy keyType: NestedKey.Type,
            forKey key: Key
        ) -> KeyedEncodingContainer<NestedKey>
            where NestedKey : CodingKey
        {
            self.encoder.container(keyedBy: NestedKey.self)
        }

        mutating func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
            self.encoder.unkeyedContainer()
        }

        mutating func superEncoder() -> Encoder {
            self.encoder
        }

        mutating func superEncoder(forKey key: Key) -> Encoder {
            self.encoder
        }
    }


    private struct _SingleValueEncoder: SingleValueEncodingContainer {
        var codingPath: [CodingKey] {
            return self.encoder.codingPath
        }

        let encoder: _Encoder
        init(_ encoder: _Encoder) {
            self.encoder = encoder
        }

        mutating func encodeNil() throws {
            self.encoder.data = .null
        }

        mutating func encode<T>(_ value: T) throws where T : Encodable {
            if let data = try _encode(value, codingPath: self.codingPath) {
                self.encoder.data = data
            } else {
                try value.encode(to: self.encoder)
            }
        }
    }
}

private func _encode(_ value: Encodable, codingPath: [CodingKey]) throws -> SQLiteData? {
    if let value = value as? SQLiteDataConvertible {
        guard let data = value.sqliteData else {
            throw EncodingError.invalidValue(value, .init(
                codingPath: codingPath,
                debugDescription: "Could not encode \(value) to SQLite data"
                ))
        }
        return data
    } else {
        return nil
    }
}
