extension SQLiteQuery.Expression {
    public enum Literal: Equatable {
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
    func serialize(_ literal: SQLiteQuery.Expression.Literal) -> String {
        switch literal {
        case .numeric(let string): return string
        case .string(let string): return "'" + string + "'"
        case .blob(let blob): return "0x" + blob.hexEncodedString()
        case .null: return "NULL"
        case .bool(let bool): return bool.description.uppercased()
        case .currentTime: return "CURRENT_TIME"
        case .currentDate: return "CURRENT_DATE"
        case .currentTimestamp: return "CURRENT_TIMESTAMP"
        }
    }
}
