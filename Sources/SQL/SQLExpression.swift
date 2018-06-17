public protocol SQLExpression: SQLSerializable {
    associatedtype Literal: SQLLiteral
    associatedtype Bind: SQLBind
    associatedtype ColumnIdentifier: SQLColumnIdentifier
    associatedtype BinaryOperator: SQLBinaryOperator
    associatedtype Function: SQLFunction
    associatedtype Subquery: SQLSerializable
    
    /// Literal strings, integers, and constants.
    static func literal(_ literal: Literal) -> Self
    
    /// Bound value.
    static func bind(_ bind: Bind) -> Self
    
    /// Column name.
    static func column(_ column: ColumnIdentifier) -> Self
    
    /// Binary expression.
    static func binary(_ lhs: Self, _ op: BinaryOperator, _ rhs: Self) -> Self
    
    /// Function.
    static func function(_ function: Function) -> Self
    
    /// Group of expressions.
    static func group(_ expressions: [Self]) -> Self
    
    /// `(SELECT ...)`
    static func subquery(_ subquery: Subquery) -> Self
    
    // FIXME: collate
    // FIXME: cast
    
    var isNull: Bool { get }
//    var literal: Literal? { get }
//    var bind: Bind? { get }
//    var column: ColumnIdentifier? { get }
//    var binary: (Self, BinaryOperator, Self)? { get }
//    var function: Function? { get }
//    var group: [Self]? { get }
//    var select: Select? { get }
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

public indirect enum GenericSQLExpression<Literal, Bind, ColumnIdentifier, BinaryOperator, Function, Subquery>: SQLExpression
    where Literal: SQLLiteral, Bind: SQLBind, ColumnIdentifier: SQLColumnIdentifier, BinaryOperator: SQLBinaryOperator, Function: SQLFunction, Subquery: SQLSerializable
{
    public typealias `Self` = GenericSQLExpression<Literal, Bind, ColumnIdentifier, BinaryOperator, Function, Subquery>

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

//    public var literal: Literal? {
//        switch self {
//        case ._literal(let literal): return literal
//        default: return nil
//        }
//    }
//
//    public var bind: Bind? {
//        switch self {
//        case ._bind(let bind): return bind
//        default: return nil
//        }
//    }
//
//    public var column: ColumnIdentifier? {
//        switch self {
//        case ._column(let column): return column
//        default: return nil
//        }
//    }
//
//    public var binary: (Self, BinaryOperator, Self)? {
//        switch self {
//        case ._binary(let lhs, let op, let rhs): return (lhs, op, rhs)
//        default: return nil
//        }
//    }
//
//    public var function: Function? {
//        switch self {
//        case ._function(let function): return function
//        default: return nil
//        }
//    }
//
//    public var group: [Self]? {
//        switch self {
//        case ._group(let group): return group
//        default: return nil
//        }
//    }
//
//    public var select: Select? {
//        switch self {
//        case ._select(let select): return select
//        default: return nil
//        }
//    }

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
