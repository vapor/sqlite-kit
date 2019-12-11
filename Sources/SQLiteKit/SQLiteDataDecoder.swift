import Foundation

public struct SQLiteDataDecoder {
    public init() {}

    public func decode<T>(_ type: T.Type, from data: SQLiteData) throws -> T
        where T: Decodable
    {
        return try _decode(T.self, decoder: _Decoder(data: data), data: data, codingPath: [])
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
            guard case .blob(let buffer) = self.data else {
                throw DecodingError.valueNotFound(Any.self, .init(
                    codingPath: self.codingPath,
                    debugDescription: "Cannot decode JSON from nil data"
                ))
            }
            return try JSONDecoder()
                .decode(DecoderUnwrapper.self, from: Data(buffer.readableBytesView))
                .decoder
        }

        func singleValueContainer() throws -> SingleValueDecodingContainer {
            return _SingleValueDecoder(self)
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
            return try _decode(T.self, decoder: self.decoder, data: self.decoder.data, codingPath: self.codingPath)
        }
    }
}


private func _decode<T>(_ type: T.Type, decoder: Decoder, data: SQLiteData, codingPath: [CodingKey]) throws -> T where T: Decodable {
    if let type = type as? SQLiteDataConvertible.Type {
        guard let decoded = type.init(sqliteData: data) else {
            throw DecodingError.typeMismatch(T.self, DecodingError.Context.init(codingPath: codingPath, debugDescription: "Could not convert \(data) to \(T.self)"))
        }
        return decoded as! T
    } else {
        return try T.init(from: decoder)
    }
}

private struct DecoderUnwrapper: Decodable {
    let decoder: Decoder
    init(from decoder: Decoder) {
        self.decoder = decoder
    }
}
