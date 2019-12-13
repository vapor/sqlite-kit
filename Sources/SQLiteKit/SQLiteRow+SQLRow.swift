extension SQLiteRow: SQLRow {
    public var allColumns: [String] {
        .init(self.columns.offsets.keys)
    }

    public func decodeNil(column: String) throws -> Bool {
        self.columns.offsets.keys.contains(column)
    }

    public func contains(column: String) -> Bool {
        return self.column(column) != nil
    }

    public func decode<D>(column: String, as type: D.Type) throws -> D where D : Decodable {
        guard let data = self.column(column) else {
            throw MissingColumn(column: column)
        }
        return try SQLiteDataDecoder().decode(D.self, from: data)
    }
}

struct MissingColumn: Error {
    let column: String
}
