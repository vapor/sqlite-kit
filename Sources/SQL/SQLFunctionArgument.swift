public protocol SQLFunctionArgument: SQLSerializable {
    associatedtype Query: SQLQuery
    static var all: Self { get }
    static func expression(_ expression: Expression) -> Self
}

// MARK: Generic

public enum GenericSQLFunctionArgument<Query>: SQLFunctionArgument where Query: SQLQuery {
    public typealias `Self` = GenericSQLFunctionArgument<Query>

    /// See `SQLFunctionArgument`.
    public static var all: Self {
        return ._all
    }
    
    /// See `SQLFunctionArgument`.
    public static func expression(_ expression: Expression) -> Self {
        return ._expression(expression)
    }
    
    case _all
    case _expression(Query.Expression)
    
    /// See `SQLSerializable`.
    public func serialize(_ binds: inout [Encodable]) -> String {
        switch self {
        case ._all: return "*"
        case ._expression(let expr): return expr.serialize(&binds)
        }
    }
}
