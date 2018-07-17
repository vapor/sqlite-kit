/// SQLite specific `SQLDefaultLiteral`.
public struct SQLiteDefaultLiteral: SQLDefaultLiteral {
    /// See `SQLDefaultLiteral`.
    public static var `default`: SQLiteDefaultLiteral {
        return self.init()
    }
    
    /// See `SQLSerializable`.
    public func serialize(_ binds: inout [Encodable]) -> String {
        return "NULL"
    }
}
