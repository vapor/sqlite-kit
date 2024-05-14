import NIOCore
import Foundation
@_spi(CodableUtilities) import SQLKit
import SQLiteNIO

/// Translates `Encodable` values into `SQLiteData` values suitable for use with an `SQLiteDatabase`.
///
/// Types which conform to `SQLiteDataConvertible` are converted directly to `SQLiteData`. Other types are
/// encoded as JSON and sent to the database as text.
public struct SQLiteDataEncoder: Sendable {
    /// A wrapper to silence `Sendable` warnings for `JSONEncoder` when not on macOS.
    struct FakeSendable<T>: @unchecked Sendable { let value: T }
    
    /// The `JSONEncoder` used for encoding values that can't be directly converted.
    let json: FakeSendable<JSONEncoder>
    
    /// Initialize a ``SQLiteDataEncoder`` with an unconfigured JSON encoder.
    public init() {
        self.init(json: .init())
    }
    
    /// Initialize a ``SQLiteDataEncoder`` with a JSON encoder.
    ///
    /// - Parameter json: A `JSONEncoder` to use for encoding types that can't be directly converted.
    public init(json: JSONEncoder) {
        self.json = .init(value: json)
    }
    
    /// Convert the given `Encodable` value to an `SQLiteData` value, if possible.
    ///
    /// - Parameter value: The value to convert.
    /// - Returns: A converted `SQLiteData` value, if successful.
    public func encode(_ value: any Encodable) throws -> SQLiteData {
        if let data = (value as? any SQLiteDataConvertible)?.sqliteData {
            return data
        } else {
            let encoder = NestedSingleValueUnwrappingEncoder(dataEncoder: self)
            
            do {
                try value.encode(to: encoder)
                guard let value = encoder.value else {
                    throw SQLCodingError.unsupportedOperation("missing value", codingPath: [])
                }
                return value
            } catch is SQLCodingError {
                // Starting with SQLite 3.45.0 (2024-01-15), sending textual JSON as a blob will cause inexplicable
                // errors due to the data being interpreted as JSONB (arguably not the best behavior for SQLite's API,
                // but not technically a compatibility break). As there is no good way to get at the underlying SQLite
                // version from the data encoder, and extending `SQLiteData` would make a rather epic mess, we now just
                // always send JSON as text instead. This is technically what we should have been doing all along
                // anyway, meaning this change is a bugfix. Good thing, too - otherwise we'd be stuck trying to retain
                // bug-for-bug compatibility, starting with reverse-engineering SQLite's JSONB format (which is not the
                // same as PostgreSQL's, of course).
                //
                // Update: SQLite 3.45.1 (2024-01-30) fixed the JSON-blob behavior, but as noted above, we prefer
                // sending JSON as text anyway, so we've left it as-is.
                return .text(.init(decoding: try self.json.value.encode(value), as: UTF8.self))
            }
        }
    }

    /// A trivial encoder for unwrapping types which encode as trivial single-value containers. This allows for
    /// correct handling of types such as `Optional` when they do not conform to `SQLiteDataConvertible`.
    private final class NestedSingleValueUnwrappingEncoder: Encoder, SingleValueEncodingContainer {
        // See `Encoder.userInfo`.
        var userInfo: [CodingUserInfoKey: Any] { [:] }
        
        // See `Encoder.codingPath` and `SingleValueEncodingContainer.codingPath`.
        var codingPath: [any CodingKey] { [] }
        
        /// The parent ``SQLiteDataEncoder``.
        let dataEncoder: SQLiteDataEncoder
        
        /// Storage for the resulting converted value.
        var value: SQLiteData? = nil
        
        /// Create a new encoder with an ``SQLiteDataEncoder``.
        init(dataEncoder: SQLiteDataEncoder) {
            self.dataEncoder = dataEncoder
        }
        
        // See `Encoder.container(keyedBy:)`.
        func container<K: CodingKey>(keyedBy: K.Type) -> KeyedEncodingContainer<K> {
            .invalid(at: self.codingPath)
        }
        
        // See `Encoder.unkeyedContainer`.
        func unkeyedContainer() -> any UnkeyedEncodingContainer {
            .invalid(at: self.codingPath)
        }
        
        // See `Encoder.singleValueContainer`.
        func singleValueContainer() -> any SingleValueEncodingContainer {
            self
        }
        
        // See `SingleValueEncodingContainer.encodeNil()`.
        func encodeNil() throws {
            self.value = .null
        }
        
        // See `SingleValueEncodingContainer.encode(_:)`.
        func encode(_ value: Bool) throws {
            self.value = .integer(value ? 1 : 0)
        }
        
        // See `SingleValueEncodingContainer.encode(_:)`.
        func encode(_ value: String) throws {
            self.value = .text(value)
        }
        
        // See `SingleValueEncodingContainer.encode(_:)`.
        func encode(_ value: Float) throws {
            self.value = .float(Double(value))
        }
        
        // See `SingleValueEncodingContainer.encode(_:)`.
        func encode(_ value: Double) throws {
            self.value = .float(value)
        }
        
        // See `SingleValueEncodingContainer.encode(_:)`.
        func encode(_ value: Int8) throws {
            self.value = .integer(numericCast(value))
        }
        
        // See `SingleValueEncodingContainer.encode(_:)`.
        func encode(_ value: Int16) throws {
            self.value = .integer(numericCast(value))
        }
        
        // See `SingleValueEncodingContainer.encode(_:)`.
        func encode(_ value: Int32) throws {
            self.value = .integer(numericCast(value))
        }
        
        // See `SingleValueEncodingContainer.encode(_:)`.
        func encode(_ value: Int64) throws {
            self.value = .integer(numericCast(value))
        }
        
        // See `SingleValueEncodingContainer.encode(_:)`.
        func encode(_ value: Int) throws {
            self.value = .integer(numericCast(value))
        }
        
        // See `SingleValueEncodingContainer.encode(_:)`.
        func encode(_ value: UInt8) throws {
            self.value = .integer(numericCast(value))
        }
        
        // See `SingleValueEncodingContainer.encode(_:)`.
        func encode(_ value: UInt16) throws {
            self.value = .integer(numericCast(value))
        }
        
        // See `SingleValueEncodingContainer.encode(_:)`.
        func encode(_ value: UInt32) throws {
            self.value = .integer(numericCast(value))
        }
        
        // See `SingleValueEncodingContainer.encode(_:)`.
        func encode(_ value: UInt64) throws {
            self.value = .integer(numericCast(value))
        }
        
        // See `SingleValueEncodingContainer.encode(_:)`.
        func encode(_ value: UInt) throws {
            self.value = .integer(numericCast(value))
        }
        
        // See `SingleValueEncodingContainer.encode(_:)`.
        func encode(_ value: some Encodable) throws {
            self.value = try self.dataEncoder.encode(value)
        }
    }
}
