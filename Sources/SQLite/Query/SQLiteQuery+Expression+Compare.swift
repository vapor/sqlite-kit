extension SQLiteQuery.Expression {
    public struct Compare {
        public enum Operator {
            /// `LIKE`
            case like
            
            /// `GLOB`
            case glob
            
            /// `MATCH`
            case match
            
            /// `REGEXP`
            case regexp
        }
        
        public var left: SQLiteQuery.Expression
        public var not: Bool
        public var op: Operator
        public var right: SQLiteQuery.Expression
        public var escape: SQLiteQuery.Expression?
        
        public init(
            _ left: SQLiteQuery.Expression,
            not: Bool = false,
            _ op: Operator,
            _ right: SQLiteQuery.Expression,
            escape: SQLiteQuery.Expression? = nil
        ) {
            self.left = left
            self.not = not
            self.op = op
            self.right = right
            self.escape = escape
        }
    }
}

infix operator ~~
public func ~~(_ lhs: SQLiteQuery.Expression, _ rhs: SQLiteQuery.Expression) -> SQLiteQuery.Expression {
    return .compare(.init(lhs, .like, rhs))
}

extension SQLiteSerializer {
    func serialize(_ compare: SQLiteQuery.Expression.Compare, _ binds: inout [SQLiteData]) -> String {
        var sql: [String] = []
        sql.append(serialize(compare.left, &binds))
        if compare.not {
            sql.append("NOT")
        }
        sql.append(serialize(compare.op))
        sql.append(serialize(compare.right, &binds))
        if let escape = compare.escape {
            sql.append("ESCAPE")
            sql.append(serialize(escape, &binds))
        }
        return sql.joined(separator: " ")
    }
    func serialize(_ expr: SQLiteQuery.Expression.Compare.Operator) -> String {
        switch expr {
        case .like: return "LIKE"
        case .glob: return "GLOB"
        case .match: return "MATCH"
        case .regexp: return "REGEXP"
        }
    }
}
