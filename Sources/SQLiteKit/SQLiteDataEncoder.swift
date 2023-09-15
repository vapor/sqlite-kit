import NIOCore
import Foundation
import SQLiteNIO

public struct SQLiteDataEncoder {
    public init() {}

    public func encode(_ value: any Encodable) throws -> SQLiteData {
        if let data = (value as? any SQLiteDataConvertible)?.sqliteData {
            return data
        } else {
            let encoder = _Encoder()
            try value.encode(to: encoder)
            switch encoder.result {
            case .data(let data):
                return data
            case .unkeyed, .keyed:
                let json = try JSONEncoder().encode(AnyEncodable(value))
                var buffer = ByteBufferAllocator().buffer(capacity: json.count)
                buffer.writeBytes(json)
                return SQLiteData.blob(buffer)
            }
        }
    }

    private enum Result {
        case keyed
        case unkeyed
        case data(SQLiteData)
    }

    private final class _Encoder: Encoder {
        var codingPath: [any CodingKey] = []
        var userInfo: [CodingUserInfoKey: Any] = [:]
        var result: Result
        
        init() { self.result = .data(.null) }

        func container<Key: CodingKey>(keyedBy: Key.Type) -> KeyedEncodingContainer<Key> {
            self.result = .keyed
            return .init(_KeyedEncoder())
        }

        func unkeyedContainer() -> any UnkeyedEncodingContainer {
            self.result = .unkeyed
            return _UnkeyedEncoder()
        }

        func singleValueContainer() -> any SingleValueEncodingContainer { _SingleValueEncoder(encoder: self) }
    }

    private struct _KeyedEncoder<Key: CodingKey>: KeyedEncodingContainerProtocol {
        var codingPath: [any CodingKey] = []
        mutating func encodeNil(forKey: Key) throws {}
        mutating func encode(_ value: some Encodable, forKey: Key) throws {}
        mutating func nestedContainer<Nested: CodingKey>(keyedBy: Nested.Type, forKey: Key) -> KeyedEncodingContainer<Nested> {
            .init(_KeyedEncoder<Nested>())
        }
        mutating func nestedUnkeyedContainer(forKey: Key) -> any UnkeyedEncodingContainer { _UnkeyedEncoder() }
        mutating func superEncoder() -> any Encoder { _Encoder() }
        mutating func superEncoder(forKey: Key) -> any Encoder { _Encoder() }
    }

    private struct _UnkeyedEncoder: UnkeyedEncodingContainer {
        var codingPath: [any CodingKey] = []
        var count: Int = 0
        mutating func encodeNil() throws {}
        mutating func encode(_ value: some Encodable) throws {}
        mutating func nestedContainer<Nested: CodingKey>(keyedBy: Nested.Type) -> KeyedEncodingContainer<Nested> {
            .init(_KeyedEncoder<Nested>())
        }
        mutating func nestedUnkeyedContainer() -> any UnkeyedEncodingContainer { _UnkeyedEncoder() }
        mutating func superEncoder() -> any Encoder { _Encoder() }
    }

    private struct _SingleValueEncoder: SingleValueEncodingContainer {
        var codingPath: [any CodingKey] { self.encoder.codingPath }
        let encoder: _Encoder
        mutating func encodeNil() throws { self.encoder.result = .data(.null) }
        mutating func encode(_ value: some Encodable) throws {
            let data = try SQLiteDataEncoder().encode(value)
            self.encoder.result = .data(data)
        }
    }
}

private struct AnyEncodable: Encodable {
    let encodable: Encodable
    init(_ encodable: Encodable) {
        self.encodable = encodable
    }
    func encode(to encoder: Encoder) throws {
        try self.encodable.encode(to: encoder)
    }
}
