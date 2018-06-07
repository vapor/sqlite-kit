extension SQLiteQuery {
    public indirect enum Expression {
        public enum UnaryOperator {
            /// `-`
            case negative
            /// `+`
            case noop
            /// `~`
            case collate
            /// `NOT`
            case not
        }
        
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
        }
        
        public struct Function {
            public enum Parameters {
                case all
                case expressions(distinct: Bool, [Expression])
            }
            
            public var name: String
            public var parameters: Parameters?
        }
        
        public struct TypeName {
            public enum Parameters {
                case one(Int)
                case two(Int, Int)
            }
            public var name: String
            public var parameters: Parameters?
        }
        
        public enum LiteralValue {
            case numeric(String)
            case string(String)
            case blob(Data)
            case null
            case bool(Bool)
            case currentTime
            case currentDate
            case currentTimestamp
        }
        
        case literalValue(LiteralValue)
        case bindParameter
        case column(Column)
        case unaryOperator(UnaryOperator, Expression)
        case binaryOperator(Expression, BinaryOperator, Expression)
        case function(Function)
        case expressions([Expression])
        /// `CAST (<expr> AS <typname>)`
        case cast(Expression, typeName: TypeName)
        /// `<expr> COLLATE <name>`
        case collate(Expression, String)
        
        public enum CompareOperator {
            /// `LIKE`
            case like
            
            /// `GLOB`
            case glob
            
            /// `MATCH`
            case match
            
            /// `REGEXP`
            case regexp
        }
        
        /// <expr> NOT LIKE <expr> ESCAPE <expr>
        case compareOperator(Expression, not: Bool, CompareOperator, Expression, escape: Expression?)
        
        public enum NullOperator {
            /// `ISNULL`
            case isNull
            /// `NOT NULL` or `NOTNULL`
            case notNull
        }
        
        /// <expr> IS NULL
        case nullOperator(Expression, NullOperator)
        
        public enum IdentityOperator {
            /// `IS`
            case `is`
            
            /// `IS NOT`
            case isNot
        }
        
        /// <expr> IS NOT <expr>
        case identityOperator(Expression, IdentityOperator, Expression)
        
        public enum BetweenOperator {
            case between
            case notBetween
        }
        
        // <expr> BETWEEN <expr> AND <expr>
        case betweenOperator(Expression, BetweenOperator, Expression, Expression)
        
        public enum SubsetOperator {
            case `in`
            case notIn
        }
        
        public enum SubsetExpression {
            case subSelect(Select)
            case expressions([Expression])
            case table(schemaName: String?, name: String)
            case tableFunction(schemaName: String?, name: String, parameters: [Expression])
        }
        
        // `<expr> IN (<in-expr>)`
        case subsetOperator(Expression, SubsetOperator, SubsetExpression)
        
        public enum ExistsOperator {
            case exists
            case notExists
        }
        
        case subSelect(ExistsOperator?, Select)
        
        public struct CaseCondition {
            public var when: Expression
            public var then: Expression
        }
        
        /// CASE <expr> (WHEN <expr> THEN <expr>) ELSE <expr> END
        case caseExpression(Expression?, [CaseCondition], Expression?)
        
        public enum RaiseFunction {
            public enum Fail {
                case rollback
                case abort
                case fail
            }
            case ignore
            case fail(Fail, message: String)
        }
        
        case raiseFunction(RaiseFunction)
    }
}

extension SQLiteSerializer {
    func serialize(_ expr: SQLiteQuery.Expression, _ binds: inout [SQLiteData]) -> String {
        switch expr {
        case .bindParameter: return "?"
        case .literalValue(let literal): return serialize(literal)
        default: return "\(expr)"
        }
    }
    
    func serialize(_ expr: SQLiteQuery.Expression.LiteralValue) -> String {
        switch expr {
        case .numeric(let string): return string
        default: return "\(expr)"
        }
    }
}
