public protocol SQLPredicateBuilder: class {
    associatedtype Connection: SQLConnection
    var predicate: Connection.Query.Expression? { get set }
}

extension SQLPredicateBuilder {
    public func `where`(_ expressions: Connection.Query.Expression...) -> Self {
        for expression in expressions {
            self.predicate &= expression
        }
        return self
    }
    
    public func orWhere(_ expressions: Connection.Query.Expression...) -> Self {
        for expression in expressions {
            self.predicate |= expression
        }
        return self
    }
    
    public func `where`(
        _ lhs: Connection.Query.Expression, _ op: Connection.Query.BinaryOperator, _ rhs: Connection.Query.Expression
    ) -> Self {
        self.predicate &= .binary(lhs, op, rhs)
        return self
    }
    
    public func orWhere(
        _ lhs: Connection.Query.Expression, _ op: Connection.Query.BinaryOperator, _ rhs: Connection.Query.Expression
    ) -> Self {
        self.predicate |= .binary(lhs, op, rhs)
        return self
    }
    
    public func `where`(group: (NestedSQLPredicateBuilder<Self>) throws -> ()) rethrows -> Self {
        let builder = NestedSQLPredicateBuilder(Self.self)
        try group(builder)
        if let sub = builder.predicate {
            self.predicate &= sub
        }
        return self
    }
}

public final class NestedSQLPredicateBuilder<PredicateBuilder>: SQLPredicateBuilder where PredicateBuilder: SQLPredicateBuilder {
    public typealias Expression = PredicateBuilder.Expression
    public var predicate: PredicateBuilder.Expression?
    internal init(_ type: PredicateBuilder.Type) { }
}
