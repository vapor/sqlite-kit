public protocol SQLExpression: SQLSerializable {
    associatedtype Query: SQLQuery
    
    /// Literal strings, integers, and constants.
    static func literal(_ literal: Query.Literal) -> Self
    
    /// Bound value.
    static func bind(_ bind: Query.Bind) -> Self
    
    /// Column name.
    static func column(_ column: Query.ColumnIdentifier) -> Self
    
    /// Binary expression.
    static func binary(_ lhs: Self, _ op: Query.BinaryOperator, _ rhs: Self) -> Self
    
    /// Function.
    static func function(_ function: Query.Function) -> Self
    
    /// Group of expressions.
    static func group(_ expressions: [Self]) -> Self
    
    /// `(SELECT ...)`
    static func subquery(_ subquery: Query.Select) -> Self
    
    // FIXME: collate
    // FIXME: cast
    
    var isNull: Bool { get }
}

// MARK: Convenience

public func && <E>(_ lhs: E, _ rhs: E) -> E where E: SQLExpression {
    return E.binary(lhs, .and, rhs)
}

public func || <E>(_ lhs: E, _ rhs: E) -> E where E: SQLExpression {
    return E.binary(lhs, .or, rhs)
}

public func &= <E>(_ lhs: inout E?, _ rhs: E) where E: SQLExpression {
    if let l = lhs {
        lhs = l && rhs
    } else {
        lhs = rhs
    }
}

public func |= <E>(_ lhs: inout E?, _ rhs: E) where E: SQLExpression {
    if let l = lhs {
        lhs = l || rhs
    } else {
        lhs = rhs
    }
}


// MARK: Generic

public indirect enum GenericSQLExpression<Query>: SQLExpression where Query: SQLQuery
{
    public typealias `Self` = GenericSQLExpression<Query>

    public static func literal(_ literal: Literal) -> Self {
        return ._literal(literal)
    }
    
    public static func bind(_ bind: Bind) -> Self {
        return ._bind(bind)
    }

    public static func column(_ column: ColumnIdentifier) -> Self {
        return ._column(column)
    }

    public static func binary(_ lhs: Self, _ op: BinaryOperator, _ rhs: Self) -> Self {
        return ._binary(lhs, op, rhs)
    }

    public static func function(_ function: Function) -> Self {
        return ._function(function)
    }

    public static func group(_ expressions: [Self]) -> Self {
        return ._group(expressions)
    }

    public static func subquery(_ subquery: Subquery) -> Self {
        return ._subquery(subquery)
    }

    case _literal(Literal)
    case _bind(Bind)
    case _column(ColumnIdentifier)
    case _binary(`Self`, BinaryOperator, `Self`)
    case _function(Function)
    case _group([`Self`])
    case _subquery(Subquery)

    public var isNull: Bool {
        switch self {
        case ._literal(let literal): return literal.isNull
        default: return false
        }
    }
    
    public func serialize(_ binds: inout [Encodable]) -> String {
        switch self {
        case ._literal(let literal): return literal.serialize(&binds)
        case ._bind(let bind): return bind.serialize(&binds)
        case ._column(let column): return column.serialize(&binds)
        case ._binary(let lhs, let op, let rhs):
            return lhs.serialize(&binds) + " " + op.serialize(&binds) + " " + rhs.serialize(&binds)
        case ._function(let function): return function.serialize(&binds)
        case ._group(let group):
            return "(" + group.map { $0.serialize(&binds) }.joined(separator: ", ") + ")"
        case ._subquery(let subquery):
            return "(" + subquery.serialize(&binds) + ")"
        }
    }
}
