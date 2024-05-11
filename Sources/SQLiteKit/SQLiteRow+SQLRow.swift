import SQLKit
import SQLiteNIO

extension SQLiteRow {
    /// Return an `SQLRow` interface to this row.
    ///
    /// - Parameter decoder: An ``SQLiteDataDecoder`` used to translate `SQLiteData` values into output values in
    ///   `SQLRow`s.
    /// - Returns: An instance of `SQLRow` which accesses the same data as `self`.
    public func sql(decoder: SQLiteDataDecoder = .init()) -> any SQLRow {
        SQLiteSQLRow(row: self, decoder: decoder)
    }
}

/// An error used to signal that a column requested from a `MySQLRow` using the `SQLRow` interface is not present.
struct MissingColumn: Error {
    let column: String
}

/// Wraps an `SQLiteRow` with the `SQLRow` protocol.
private struct SQLiteSQLRow: SQLRow {
    /// The underlying `SQLiteRow`.
    let row: SQLiteRow
    
    /// A ``SQLiteDataDecoder`` used to translate `SQLiteData` values into output values.
    let decoder: SQLiteDataDecoder

    // See `SQLRow.allColumns`.
    var allColumns: [String] {
        self.row.columns.map { $0.name }
    }

    // See `SQLRow.contains(column:)`.
    func contains(column: String) -> Bool {
        self.row.column(column) != nil
    }

    // See `SQLRow.decodeNil(column:)`.
    func decodeNil(column: String) throws -> Bool {
        guard let data = self.row.column(column) else {
            return true
        }
        return data == .null
    }

    // See `SQLRow.decode(column:as:)`.
    func decode<D: Decodable>(column: String, as: D.Type) throws -> D {
        guard let data = self.row.column(column) else {
            throw MissingColumn(column: column)
        }
        return try self.decoder.decode(D.self, from: data)
    }
}

/// A legacy deprecated conformance of `SQLiteRow` directly to `SQLRow`. This interface exists solely
/// because its absence would be a public API break.
///
/// Do not use these methods directly. Call `sql(decoder:)` instead to access `SQLiteRow`s through
/// an `SQLKit` interface.
@available(*, deprecated, message: "Use SQLiteRow.sql(decoder:) to access an SQLiteRow as an SQLRow.")
extension SQLiteNIO.SQLiteRow: SQLKit.SQLRow {
    // See `SQLRow.allColumns`.
    public var allColumns: [String] { self.columns.map { $0.name } }

    // See `SQLRow.contains(column:)`.
    public func contains(column: String) -> Bool { self.column(column) != nil }

    // See `SQLRow.decodeNil(column:)`.
    public func decodeNil(column: String) throws -> Bool { (self.column(column) ?? .null) == .null }

    // See `SQLRow.decode(column:as:)`.
    public func decode<D: Decodable>(column: String, as: D.Type) throws -> D {
        guard let data = self.column(column) else { throw MissingColumn(column: column) }
        return try SQLiteDataDecoder().decode(D.self, from: data)
    }

    // See `SQLRow.decode(column:inferringAs:)`.
    public func decode<D: Decodable>(column c: String, inferringAs: D.Type = D.self) throws -> D { try self.decode(column: c, as: D.self) }

    // See `SQLRow.decode(model:prefix:keyDecodingStrategy:userInfo:)`.
    public func decode<D: Decodable>(
        model: D.Type, prefix: String? = nil, keyDecodingStrategy: SQLRowDecoder.KeyDecodingStrategy = .useDefaultKeys,
        userInfo: [CodingUserInfoKey: any Sendable] = [:]
    ) throws -> D {
        try self.decode(model: D.self, with: .init(prefix: prefix, keyDecodingStrategy: keyDecodingStrategy, userInfo: userInfo))
    }

    // See `SQLRow.decode(model:with:)`.
    public func decode<D: Decodable>(model: D.Type, with: SQLRowDecoder) throws -> D { try with.decode(D.self, from: self) }
}
