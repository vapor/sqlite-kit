import SQLKit
import SQLiteNIO

extension SQLiteRow {
    /// Return an `SQLRow` interface to this row.
    ///
    /// - Parameter decoder: An ``SQLiteDataDecoder`` used to translate `SQLiteData` values into output values in
    ///   `SQLRow`s.
    /// - Returns: An instance of `SQLRow` which accesses the same data as `self`.
    func sql(decoder: SQLiteDataDecoder = .init()) -> any SQLRow {
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
