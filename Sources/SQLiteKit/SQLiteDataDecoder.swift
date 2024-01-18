import Foundation
import SQLiteNIO
import NIOFoundationCompat

public struct SQLiteDataDecoder {
    let json = JSONDecoder() // TODO: Add API to make this configurable
    
    public init() {}

    public func decode<T: Decodable>(_ type: T.Type, from data: SQLiteData) throws -> T {
        // If `T` can be converted directly, just do so.
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
                return try T.init(from: GiftBoxUnwrapDecoder(decoder: self, data: data))
            } catch is TryJSONSentinel {
                // Couldn't unwrap it either. Fall back to attempting a JSON decode.
                let buf: Data
                switch data {
                case .text(let str):  buf = .init(str.utf8)
                case .blob(let blob): buf = .init(buffer: blob, byteTransferStrategy: .noCopy)
                // The remaining cases should never happen, but we implement them anyway just in case.
                case .integer(let n): buf = .init(String(n).utf8)
                case .float(let n):   buf = .init(String(n).utf8)
                case .null:           buf = .init()
                }
                return try self.json.decode(T.self, from: buf)
            }
        }
    }
    
    private struct TryJSONSentinel: Swift.Error {}

    private struct GiftBoxUnwrapDecoder: Decoder, SingleValueDecodingContainer {
        let decoder: SQLiteDataDecoder
        let data: SQLiteData
        
        var codingPath: [any CodingKey] { [] }
        var userInfo: [CodingUserInfoKey: Any] { [:] }

        func container<K: CodingKey>(keyedBy: K.Type) throws -> KeyedDecodingContainer<K> { throw TryJSONSentinel() }
        func unkeyedContainer() throws -> any UnkeyedDecodingContainer { throw TryJSONSentinel() }
        func singleValueContainer() throws -> any SingleValueDecodingContainer { self }
        func decodeNil() -> Bool { self.data.isNull }
        func decode<T: Decodable>(_: T.Type) throws -> T { try self.decoder.decode(T.self, from: self.data) }
    }
}
