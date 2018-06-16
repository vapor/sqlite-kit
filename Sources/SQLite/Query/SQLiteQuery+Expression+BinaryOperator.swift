extension SQLiteQuery.Expression {
    public enum BinaryOperator {
        /// `||`
        case concatenate
        
        /// `*`
        case multiply
        
        /// `/`
        case divide
        
        /// `%`
        case modulo
        
        /// `+`
        case add
        
        /// `-`
        case subtract
        
        /// `<<`
        case bitwiseShiftLeft
        
        /// `>>`
        case bitwiseShiftRight
        
        /// `&`
        case bitwiseAnd
        
        /// `|`
        case bitwiseOr
        
        /// `<`
        case lessThan
        
        /// `<=`
        case lessThanOrEqual
        
        /// `>`
        case greaterThan
        
        /// `>=`
        case greaterThanOrEqual
        
        /// `=` or `==`
        case equal
        
        /// `!=` or `<>`
        case notEqual
        
        /// `AND`
        case and
        
        /// `OR`
        case or
        
        /// `IS`
        case `is`
        
        /// `IS NOT`
        case isNot
        
        /// `IN`
        case `in`
        
        /// `NOT IN`
        case notIn
        
        /// `LIKE`
        case like
        
        /// `NOT LIKE`
        case notLike
        
        /// `GLOB`
        case glob
        
        /// `NOT GLOB`
        case notGlob
        
        /// `MATCH`
        case match
        
        /// `NOT MATCH`
        case notMatch
        
        /// `REGEXP`
        case regexp
        
        /// `NOT REGEXP`
        case notRegexp
    }
}

// MARK: Serialize

extension SQLiteSerializer {
    func serialize(_ expr: SQLiteQuery.Expression.BinaryOperator) -> String {
        switch expr {
        case .add: return "+"
        case .bitwiseAnd: return "&"
        case .bitwiseOr: return "|"
        case .bitwiseShiftLeft: return "<<"
        case .bitwiseShiftRight: return ">>"
        case .concatenate: return "||"
        case .divide: return "/"
        case .equal: return "="
        case .greaterThan: return ">"
        case .greaterThanOrEqual: return ">="
        case .lessThan: return "<"
        case .lessThanOrEqual: return "<="
        case .modulo: return "%"
        case .multiply: return "*"
        case .notEqual: return "!="
        case .subtract: return "-"
        case .and: return "AND"
        case .or: return "OR"
        case .in: return "IN"
        case .notIn: return "NOT IN"
        case .is: return "IS"
        case .isNot: return "IS NOT"
        case .like: return "LIKE"
        case .glob: return "GLOB"
        case .match: return "MATCH"
        case .regexp: return "REGEXP"
        case .notLike: return "NOT LIKE"
        case .notGlob: return "NOT GLOB"
        case .notMatch: return "NOT MATCH"
        case .notRegexp: return "NOT REGEXP"
        }
    }
}
