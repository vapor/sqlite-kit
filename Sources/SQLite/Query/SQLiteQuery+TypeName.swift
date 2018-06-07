extension SQLiteQuery {
    public enum TypeName {
        case text
        case numeric
        case integer
        case real
        case none
    }
}

extension SQLiteSerializer {
    func serialize(_ type: SQLiteQuery.TypeName) -> String {
        switch type {
        case .integer: return "INTEGER"
        case .none: return "NONE"
        case .numeric: return "NUMERIC"
        case .real: return "REAL"
        case .text: return "TEXT"
        }
    }
}
