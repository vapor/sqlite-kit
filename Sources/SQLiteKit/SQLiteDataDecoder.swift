import Foundation
import SQLiteNIO

public struct SQLiteDataDecoder {
    public init() {}

    public func decode<T: Decodable>(_ type: T.Type, from data: SQLiteData) throws -> T {
        if let type = type as? any SQLiteDataConvertible.Type {
            guard let value = type.init(sqliteData: data) else {
                throw DecodingError.typeMismatch(T.self, .init(
                    codingPath: [],
                    debugDescription: "Could not initialize \(T.self) from \(data)."
                ))
            }
            return value as! T
        } else {
            do {
                return try T.init(from: _Decoder(data: data))
            } catch is SentinelError {
                let fdata: Data
                switch data {
                case .blob(let buf): fdata = .init(buf.readableBytesView)
                case .text(let str): fdata = .init(str.utf8)
                default: fdata = .init()
                }
                return try JSONDecoder().decode(T.self, from: fdata)
            }
        }
    }
    
    private struct SentinelError: Swift.Error {}

    private final class _Decoder: Decoder {
        var codingPath: [any CodingKey] = []
        var userInfo: [CodingUserInfoKey: Any] = [:]

        let data: SQLiteData
        init(data: SQLiteData) { self.data = data }

        func unkeyedContainer() throws -> any UnkeyedDecodingContainer {
            throw SentinelError()
        }

        func container<Key: CodingKey>(keyedBy: Key.Type) throws -> KeyedDecodingContainer<Key> {
            throw SentinelError()
        }

        func singleValueContainer() throws -> any SingleValueDecodingContainer { _SingleValueDecoder(self) }
    }

    private struct _SingleValueDecoder: SingleValueDecodingContainer {
        var codingPath: [any CodingKey] { self.decoder.codingPath }
        let decoder: _Decoder
        init(_ decoder: _Decoder) { self.decoder = decoder }

        func decodeNil() -> Bool { self.decoder.data == .null }

        func decode<T: Decodable>(_: T.Type) throws -> T {
            try SQLiteDataDecoder().decode(T.self, from: self.decoder.data)
        }
    }
}
