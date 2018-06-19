public struct SQLiteBind: SQLBind {
    /// See `SQLBind`.
    public static func encodable<E>(_ value: E) -> SQLiteBind
        where E: Encodable
    {
        if let expr = value as? SQLiteQueryExpressionRepresentable {
            return self.init(value: .expression(expr.sqliteQueryExpression))
        } else {
            return self.init(value: .encodable(value))
        }
    }
    
    public enum Value {
        case expression(SQLiteExpression)
        case encodable(Encodable)
    }
    
    public var value: Value
    
    /// See `SQLSerializable`.
    public func serialize(_ binds: inout [Encodable]) -> String {
        switch value {
        case .expression(let expr): return expr.serialize(&binds)
        case .encodable(let value):
            binds.append(value)
            return "?"
        }
    }
}
