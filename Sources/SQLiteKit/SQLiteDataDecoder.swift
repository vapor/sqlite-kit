import Foundation

public struct SQLiteDataDecoder {
    public init() {}

    public func decode<T>(_ type: T.Type, from data: SQLiteData) throws -> T
        where T: Decodable
    {
        if let type = type as? SQLiteDataConvertible.Type {
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
        var codingPath: [CodingKey] {
            return []
        }

        var userInfo: [CodingUserInfoKey : Any] {
            return [:]
        }

        let data: SQLiteData
        init(data: SQLiteData) {
            self.data = data
        }

        func unkeyedContainer() throws -> UnkeyedDecodingContainer {
            try self.jsonDecoder().unkeyedContainer()
        }

        func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
            try self.jsonDecoder().container(keyedBy: Key.self)
        }

        func jsonDecoder() throws -> Decoder {
            let data: Data
            switch self.data {
            case .blob(let buffer):
                data = Data(buffer.readableBytesView)
            case .text(let string):
                data = Data(string.utf8)
            default:
                data = .init()
            }
            return try JSONDecoder()
                .decode(DecoderUnwrapper.self, from: data)
                .decoder
        }

        func singleValueContainer() throws -> SingleValueDecodingContainer {
            _SingleValueDecoder(self)
        }
    }

    private struct _SingleValueDecoder: SingleValueDecodingContainer {
        var codingPath: [CodingKey] {
            return self.decoder.codingPath
        }
        let decoder: _Decoder
        init(_ decoder: _Decoder) {
            self.decoder = decoder
        }

        func decodeNil() -> Bool {
            return self.decoder.data == .null
        }

        func decode<T>(_ type: T.Type) throws -> T where T: Decodable {
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
