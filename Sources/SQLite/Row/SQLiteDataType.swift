public enum SQLiteDataType: SQLDataType {
    case integer
    case real
    case text
    case blob
    case null
    
    /// See `SQLSerializable`.
    public func serialize(_ binds: inout [Encodable]) -> String {
        switch self {
        case .integer: return "INTEGER"
        case .real: return "REAL"
        case .text: return "TEXT"
        case .blob: return "BLOB"
        case .null: return "NULL"
        }
    }
}
