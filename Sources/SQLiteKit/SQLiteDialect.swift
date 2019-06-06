struct SQLiteDialect: SQLDialect {
    var identifierQuote: SQLExpression {
        return SQLRaw("'")
    }

    var literalStringQuote: SQLExpression {
        return SQLRaw("\"")
    }

    var autoIncrementClause: SQLExpression {
        return SQLRaw("AUTOINCREMENT")
    }

    mutating func nextBindPlaceholder() -> SQLExpression {
        return SQLRaw("?")
    }

    func literalBoolean(_ value: Bool) -> SQLExpression {
        switch value {
        case true: return SQLRaw("TRUE")
        case false: return SQLRaw("FALSE")
        }
    }
}
