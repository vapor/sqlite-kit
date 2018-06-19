public struct SQLiteDefaultLiteral: SQLDefaultLiteral {
    /// See `SQLDefaultLiteral`.
    public static func `default`() -> SQLiteDefaultLiteral {
        return self.init()
    }
    
    /// See `SQLSerializable`.
    public func serialize(_ binds: inout [Encodable]) -> String {
        return "NULL"
    }
}
