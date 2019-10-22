public struct SQLiteDialect: SQLDialect {
    public var identifierQuote: SQLExpression {
        return SQLRaw("'")
    }

    public var literalStringQuote: SQLExpression {
        return SQLRaw("\"")
    }

    public var autoIncrementClause: SQLExpression {
        return SQLRaw("AUTOINCREMENT")
    }

    public mutating func nextBindPlaceholder() -> SQLExpression {
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
