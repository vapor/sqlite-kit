extension SQLiteRow: SQLRow {
    public func contains(column: String) -> Bool {
        return self.column(column) != nil
    }

    public func decode<D>(column: String, as type: D.Type) throws -> D where D : Decodable {
        guard let data = self.column(column) else {
            fatalError("no value found for \(column)")
        }
        return try SQLiteDataDecoder().decode(D.self, from: data)
    }
}
