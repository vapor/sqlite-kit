import NIOCore
import Foundation
import SQLiteNIO

public struct SQLiteDataEncoder {
    public init() {}

    public func encode(_ value: any Encodable) throws -> SQLiteData {
        if let data = (value as? any SQLiteDataConvertible)?.sqliteData {
            return data
        } else {
            let encoder = EncoderImpl()
            
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
                return .text(.init(decoding: try JSONEncoder().encode(value), as: UTF8.self))
            }
        }
    }

    private enum Result {
        case keyed
        case unkeyed
        case data(SQLiteData)
    }

    private final class EncoderImpl: Encoder, SingleValueEncodingContainer {
        private struct KeyedEncoderImpl<K: CodingKey>: KeyedEncodingContainerProtocol {
            var codingPath: [any CodingKey] { [] }
            mutating func encodeNil(forKey: K) throws {}
            mutating func encode(_: some Encodable, forKey: K) throws {}
            mutating func nestedContainer<N: CodingKey>(keyedBy: N.Type, forKey: K) -> KeyedEncodingContainer<N> { .init(KeyedEncoderImpl<N>()) }
            mutating func nestedUnkeyedContainer(forKey: K) -> any UnkeyedEncodingContainer { UnkeyedEncoderImpl() }
            mutating func superEncoder() -> any Encoder { EncoderImpl() }
            mutating func superEncoder(forKey: K) -> any Encoder { EncoderImpl() }
        }

        private struct UnkeyedEncoderImpl: UnkeyedEncodingContainer {
            var codingPath: [any CodingKey] { [] }
            var count: Int = 0
            mutating func encodeNil() throws {}
            mutating func encode(_: some Encodable) throws {}
            mutating func nestedContainer<N: CodingKey>(keyedBy: N.Type) -> KeyedEncodingContainer<N> { .init(KeyedEncoderImpl<N>()) }
            mutating func nestedUnkeyedContainer() -> any UnkeyedEncodingContainer { UnkeyedEncoderImpl() }
            mutating func superEncoder() -> any Encoder { EncoderImpl() }
        }
    
        var codingPath: [any CodingKey] { [] }
        var userInfo: [CodingUserInfoKey: Any] { [:] }
        var result: Result
        
        init() { self.result = .data(.null) }

        func container<K: CodingKey>(keyedBy: K.Type) -> KeyedEncodingContainer<K> {
            self.result = .keyed
            return .init(KeyedEncoderImpl())
        }

        func unkeyedContainer() -> any UnkeyedEncodingContainer {
            self.result = .unkeyed
            return UnkeyedEncoderImpl()
        }

        func singleValueContainer() -> any SingleValueEncodingContainer { self }

        func encodeNil() throws { self.result = .data(.null) }
        
        func encode(_ value: some Encodable) throws {
            self.result = .data(try SQLiteDataEncoder().encode(value))
        }
    }
}
