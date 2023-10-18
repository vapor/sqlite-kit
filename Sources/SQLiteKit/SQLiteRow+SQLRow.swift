import SQLKit
import SQLiteNIO

extension SQLiteRow: SQLRow {
    public var allColumns: [String] {
        self.columns.map { $0.name }
    }

    public func decodeNil(column: String) throws -> Bool {
        guard let data = self.column(column) else {
            return true
        }
        return data == .null
    }

    public func contains(column: String) -> Bool {
        self.column(column) != nil
    }

    public func decode<D: Decodable>(column: String, as: D.Type) throws -> D {
        guard let data = self.column(column) else {
            throw MissingColumn(column: column)
        }
        return try SQLiteDataDecoder().decode(D.self, from: data)
    }
}

struct MissingColumn: Error {
    let column: String
}
