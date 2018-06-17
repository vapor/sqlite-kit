public protocol SQLSelectExpression: SQLSerializable {
    associatedtype Expression: SQLExpression
    
    static var all: Self { get }
    static func allTable(_ table: String) -> Self
    static func expression(_ expression: Expression, alias: String?) -> Self
    
    var isAll: Bool { get }
    var allTable: String? { get }
    var expression: (expression: Expression, alias: String?)? { get }
}

// MARK: Default

extension SQLSelectExpression {
    public func serialize(_ binds: inout [Encodable]) -> String {
        switch (isAll, allTable, expression) {
        case (true, .none, .none): return "*"
        case (false, .some(let table), .none): return table + ".*"
        case (false, .none, .some(let e)):
            switch e.alias {
            case .none: return e.expression.serialize(&binds)
            case .some(let alias): return e.expression.serialize(&binds) + " AS " + alias
            }
        default: fatalError("Unsupported SQLSelectExpression.")
        }
    }
}


// MARK: Convenience

extension SQLSelectExpression {
    public static func function(_ function: Expression, as alias: String? = nil) -> Self {
        return .expression(function, alias: alias)
    }
}

// MARK: Generic

public enum GenericSQLSelectExpression<Expression>: SQLSelectExpression where Expression: SQLExpression {
    /// See `SQLSelectExpression`.
    public static var all: GenericSQLSelectExpression<Expression> {
        return ._all
    }
    
    /// See `SQLSelectExpression`.
    public static func allTable(_ table: String) -> GenericSQLSelectExpression<Expression> {
        return ._allTable(table)
    }
    
    /// See `SQLSelectExpression`.
    public static func expression(_ expression: Expression, alias: String?) -> GenericSQLSelectExpression<Expression> {
        return ._expression(expression, alias: alias)
    }
    
    /// See `SQLSelectExpression`.
    public var isAll: Bool {
        switch self {
        case ._all: return true
        default: return false
        }
    }
    
    /// See `SQLSelectExpression`.
    public var allTable: String? {
        switch self {
        case ._allTable(let table): return table
        default: return nil
        }
    }
    
    /// See `SQLSelectExpression`.
    public var expression: (expression: Expression, alias: String?)? {
        switch self {
        case ._expression(let expr, let alias): return (expr, alias)
        default: return nil
        }
    }
    
    /// `*`
    case _all
    
    /// `table.*`
    case _allTable(String)
    
    /// `md5(a) AS hash`
    case _expression(Expression, alias: String?)
}
