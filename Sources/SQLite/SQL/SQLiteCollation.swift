/// SQLite specific `SQLCollation`.
public enum SQLiteCollation: SQLCollation {
    /// See `SQLSerializable`.
    public func serialize(_ binds: inout [Encodable]) -> String {
        return "X"
    }
}
