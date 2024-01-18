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
                // Starting with SQLite 3.45.0 (2024-01-15), sending textual JSON as a blob will cause inexplicable
                // errors due to the data being interpreted as JSONB (arguably not the best behavior for SQLite's API,
                // but not technically a compatibility break). As there is no good way to get at the underlying SQLite
                // version from the data encoder, and extending `SQLiteData` would make a rather epic mess, we now just
                // always send JSON as text instead. This is technically what we should have been doing all along
                // anyway, meaning this change is a bugfix. Good thing, too - otherwise we'd be stuck trying to retain
                // bug-for-bug compatibility, starting with reverse-engineering SQLite's JSONB format (which is not the
                // same as PostgreSQL's, of course).
                return SQLiteData.text(.init(decoding: try JSONEncoder().encode(value), as: UTF8.self))
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
