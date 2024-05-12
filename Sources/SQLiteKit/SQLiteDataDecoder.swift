import Foundation
import SQLiteNIO
@_spi(CodableUtilities) import SQLKit
import NIOFoundationCompat

/// Translates `SQLiteData` values received from the database into `Decodable` values.
///
/// Types which conform to `SQLiteDataConvertible` are converted directly to the requested type. For other types,
/// an attempt is made to interpret the database value as JSON and decode the type from it.
public struct SQLiteDataDecoder: Sendable {
    /// A wrapper to silence `Sendable` warnings for `JSONDecoder` when not on macOS.
    struct FakeSendable<T>: @unchecked Sendable { let value: T }
    
    /// The `JSONDecoder` used for decoding values that can't be directly converted.
    let json: FakeSendable<JSONDecoder>

    /// Initialize a ``SQLiteDataDecoder`` with an unconfigured JSON decoder.
    public init() {
        self.init(json: .init())
    }
    
    /// Initialize a ``SQLiteDataDecoder`` with a JSON decoder.
    ///
    /// - Parameter json: A `JSONDecoder` to use for decoding types that can't be directly converted.
    public init(json: JSONDecoder) {
        self.json = .init(value: json)
    }
    
    /// Convert the given `SQLiteData` into a value of type `T`, if possible.
    ///
    /// - Parameters:
    ///   - type: The desired result type.
    ///   - data: The data to decode.
    /// - Returns: The decoded value, if successful.
    public func decode<T: Decodable>(_ type: T.Type, from data: SQLiteData) throws -> T {
        // If `T` can be converted directly, just do so.
        if let type = type as? any SQLiteDataConvertible.Type {
            guard let value = type.init(sqliteData: data) else {
                throw DecodingError.typeMismatch(T.self, .init(
                    codingPath: [],
                    debugDescription: "Could not convert SQLite data to \(T.self): \(data)."
                ))
            }
            return value as! T
        } else {
            do {
                return try T.init(from: NestedSingleValueUnwrappingDecoder(decoder: self, data: data))
            } catch is SQLCodingError {
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
                return try self.json.value.decode(T.self, from: buf)
            }
        }
    }
    
    /// A trivial decoder for unwrapping types which decode as trivial single-value containers. This allows for
    /// correct handling of types such as `Optional` when they do not conform to `SQLiteDataCovnertible`.
    private final class NestedSingleValueUnwrappingDecoder: Decoder, SingleValueDecodingContainer {
        // See `Decoder.codingPath` and `SingleValueDecodingContainer.codingPath`.
        var codingPath: [any CodingKey] { [] }

        // See `Decoder.userInfo`.
        var userInfo: [CodingUserInfoKey: Any] { [:] }

        /// The parent ``SQLiteDataDecoder``.
        let dataDecoder: SQLiteDataDecoder

        /// The data to decode.
        let data: SQLiteData
        
        /// Create a new decoder with an ``SQLiteDataDecoder`` and the data to decode.
        init(decoder: SQLiteDataDecoder, data: SQLiteData) {
            self.dataDecoder = decoder
            self.data = data
        }
        
        // See `Decoder.container(keyedBy:)`.
        func container<Key: CodingKey>(keyedBy: Key.Type) throws -> KeyedDecodingContainer<Key> {
            throw .invalid(at: self.codingPath)
        }
        
        // See `Decoder.unkeyedContainer()`.
        func unkeyedContainer() throws -> any UnkeyedDecodingContainer {
            throw .invalid(at: self.codingPath)
        }
        
        // See `Decoder.singleValueContainer()`.
        func singleValueContainer() throws -> any SingleValueDecodingContainer {
            self
        }

        // See `SingleValueDecodingContainer.decodeNil()`.
        func decodeNil() -> Bool {
            self.data.isNull
        }

        // See `SingleValueDecodingContainer.decode(_:)`.
        func decode<T: Decodable>(_: T.Type) throws -> T {
            try self.dataDecoder.decode(T.self, from: self.data)
        }
    }
}
