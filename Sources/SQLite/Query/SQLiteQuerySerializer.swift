extension SQLiteQuery {
    public func serialize(_ binds: inout [SQLiteData]) -> String {
        return SQLiteSerializer().serialize(self, &binds)
    }
}

struct SQLiteSerializer {
    init() { }
    
    func escapeString(_ string: String) -> String {
        return "\"" + string + "\""
    }
}

public protocol SQLitePredicateBuilder: class {
    var connection: SQLiteConnection { get }
    var predicate: SQLiteQuery.Expression? { get set }
}

extension SQLitePredicateBuilder {
    public func `where`(_ expressions: SQLiteQuery.Expression...) -> Self {
        for expression in expressions {
            self.predicate &= expression
        }
        return self
    }
    
    public func orWhere(_ expressions: SQLiteQuery.Expression...) -> Self {
        for expression in expressions {
            self.predicate |= expression
        }
        return self
    }
    
    public func `where`(_ lhs: SQLiteQuery.Expression, _ op: SQLiteQuery.Expression.BinaryOperator, _ rhs: SQLiteQuery.Expression) -> Self {
        predicate &= .binary(lhs, op, rhs)
        return self
    }
    
    public func orWhere(_ lhs: SQLiteQuery.Expression, _ op: SQLiteQuery.Expression.BinaryOperator, _ rhs: SQLiteQuery.Expression) -> Self {
        predicate |= .binary(lhs, op, rhs)
        return self
    }
    
    public func `where`(group: (SQLitePredicateBuilder) throws -> ()) rethrows -> Self {
        let builder = SQLiteQuery.SelectBuilder(on: connection)
        try group(builder)
        switch (self.predicate, builder.select.predicate) {
        case (.some(let a), .some(let b)):
            self.predicate = a && .expressions([b])
        case (.none, .some(let b)):
            self.predicate = .expressions([b])
        case (.some, .none), (.none, .none): break
        }
        return self
    }
}
