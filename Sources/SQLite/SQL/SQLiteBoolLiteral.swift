public enum SQLiteBoolLiteral: SQLBoolLiteral {
    /// See `SQLBoolLiteral`.
    public static var `true`: SQLiteBoolLiteral {
        return ._true
    }
    
    /// See `SQLBoolLiteral`.
    public static var `false`: SQLiteBoolLiteral {
        return ._false
    }
    
    case _true
    case _false
    
    /// See `SQLSerializable`.
    public func serialize(_ binds: inout [Encodable]) -> String {
        switch self {
        case ._false: return "0"
        case ._true: return "1"
        }
    }
}
