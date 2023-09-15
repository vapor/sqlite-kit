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
            return try T.init(from: _Decoder(data: data))
        }
    }

    private final class _Decoder: Decoder {
        var codingPath: [any CodingKey] = []
        var userInfo: [CodingUserInfoKey: Any] = [:]

        let data: SQLiteData
        init(data: SQLiteData) { self.data = data }

        func unkeyedContainer() throws -> any UnkeyedDecodingContainer {
            try self.jsonDecoder().unkeyedContainer()
        }

        func container<Key: CodingKey>(keyedBy: Key.Type) throws -> KeyedDecodingContainer<Key> {
            try self.jsonDecoder().container(keyedBy: Key.self)
        }

        func jsonDecoder() throws -> any Decoder {
            let data: Data
            switch self.data {
            case .blob(let buffer): data = Data(buffer.readableBytesView)
            case .text(let string): data = Data(string.utf8)
            default: data = .init()
            }
            return try JSONDecoder().decode(DecoderUnwrapper.self, from: data).decoder
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

private struct DecoderUnwrapper: Decodable {
    let decoder: Decoder
    init(from decoder: Decoder) {
        self.decoder = decoder
    }
}
