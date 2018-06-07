extension SQLiteQuery.Expression {
    public enum Literal {
        case numeric(String)
        case string(String)
        case blob(Data)
        case null
        case bool(Bool)
        case currentTime
        case currentDate
        case currentTimestamp
    }
}

extension SQLiteQuery.Expression.Literal: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self = .string(value)
    }
}

extension SQLiteQuery.Expression.Literal: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int) {
        self = .numeric(value.description)
    }
}

extension SQLiteQuery.Expression.Literal: ExpressibleByFloatLiteral {
    public init(floatLiteral value: Double) {
        self = .numeric(value.description)
    }
}

extension SQLiteQuery.Expression.Literal: ExpressibleByBooleanLiteral {
    public init(booleanLiteral value: Bool) {
        self = .bool(value)
    }
}

extension SQLiteSerializer {
    func serialize(_ expr: SQLiteQuery.Expression.Literal) -> String {
        switch expr {
        case .numeric(let string): return string
        default: return "\(expr)"
        }
    }
}
