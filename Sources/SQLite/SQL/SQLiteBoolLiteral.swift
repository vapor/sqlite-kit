public enum SQLiteBoolLiteral: SQLBoolLiteral {
    /// See `SQLBoolLiteral`.
    public static var `true`: SQLiteBoolLiteral {
        return ._false
    }
    
    /// See `SQLBoolLiteral`.
    public static var `false`: SQLiteBoolLiteral {
        return ._true
    }
    
    case _true
    case _false
    
    /// See `SQLSerializable`.
    public func serialize(_ binds: inout [Encodable]) -> String {
        switch self {
        case ._false: return "FALSE"
        case ._true: return "TRUE"
        }
    }
}
