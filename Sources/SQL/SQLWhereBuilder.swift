public protocol SQLWhereBuilder: class {
    associatedtype Expression: SQLExpression
    var `where`: Expression? { get set }
}

extension SQLWhereBuilder {
    public func `where`(_ expressions: Expression...) -> Self {
        for expression in expressions {
            self.where &= expression
        }
        return self
    }
    
    public func orWhere(_ expressions: Expression...) -> Self {
        for expression in expressions {
            self.where |= expression
        }
        return self
    }
    
    public func `where`(_ lhs: Expression, _ op: Expression.BinaryOperator, _ rhs: Expression) -> Self {
        self.where &= .binary(lhs, op, rhs)
        return self
    }
    
    public func orWhere(_ lhs: Expression, _ op: Expression.BinaryOperator, _ rhs: Expression) -> Self {
        self.where |= .binary(lhs, op, rhs)
        return self
    }
    
    public func `where`(group: (NestedSQLWhereBuilder<Self>) throws -> ()) rethrows -> Self {
        let builder = NestedSQLWhereBuilder(Self.self)
        try group(builder)
        if let sub = builder.where {
            self.where &= sub
        }
        return self
    }
}

public final class NestedSQLWhereBuilder<WhereBuilder>: SQLWhereBuilder where WhereBuilder: SQLWhereBuilder {
    public typealias Expression = WhereBuilder.Expression
    public var `where`: WhereBuilder.Expression?
    internal init(_ type: WhereBuilder.Type) { }
}
