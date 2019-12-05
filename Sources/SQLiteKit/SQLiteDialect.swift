public struct SQLiteDialect: SQLDialect {
    public var name: String {
        "sqlite"
    }
    
    public var identifierQuote: SQLExpression {
        return SQLRaw("\"")
    }

    public var literalStringQuote: SQLExpression {
        return SQLRaw("'")
    }

    public var autoIncrementClause: SQLExpression {
        return SQLRaw("AUTOINCREMENT")
    }

    public func bindPlaceholder(at position: Int) -> SQLExpression {
        return SQLRaw("?")
    }

    public func literalBoolean(_ value: Bool) -> SQLExpression {
        switch value {
        case true: return SQLRaw("TRUE")
        case false: return SQLRaw("FALSE")
        }
    }

    public var literalDefault: SQLExpression {
        return SQLLiteral.null
    }
    
    public init() { }
}
