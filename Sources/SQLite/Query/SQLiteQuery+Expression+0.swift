extension SQLiteQuery {
    public indirect enum Expression {
        public struct Function {
            public enum Parameters {
                case all
                case expressions(distinct: Bool, [Expression])
            }
            
            public var name: String
            public var parameters: Parameters?
            
            public init(name: String, parameters: Parameters? = nil) {
                self.name = name
                self.parameters = parameters
            }
        }
        
        public enum NullOperator {
            /// `ISNULL`
            case isNull
            /// `NOT NULL` or `NOTNULL`
            case notNull
        }
        
        
        public enum IdentityOperator {
            /// `IS`
            case `is`
            
            /// `IS NOT`
            case isNot
        }
        
        public enum BetweenOperator {
            case between
            case notBetween
        }
        
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
        
        public enum ExistsOperator {
            case exists
            case notExists
        }
        
        public struct CaseCondition {
            public var when: Expression
            public var then: Expression
        }
        
        public enum RaiseFunction {
            public enum Fail {
                case rollback
                case abort
                case fail
            }
            case ignore
            case fail(Fail, message: String)
        }
        
        case literal(Literal)
        case data(SQLiteData)
        case column(QualifiedColumnName)
        case unary(UnaryOperator, Expression)
        case binary(Expression, BinaryOperator, Expression)
        case function(Function)
        case expressions([Expression])
        /// `CAST (<expr> AS <typname>)`
        case cast(Expression, typeName: TypeName)
        /// `<expr> COLLATE <name>`
        case collate(Expression, String)
        /// <expr> NOT LIKE <expr> ESCAPE <expr>
        case compare(Compare)
        /// <expr> IS NULL
        case nullOperator(Expression, NullOperator)
        /// <expr> IS NOT <expr>
        case identityOperator(Expression, IdentityOperator, Expression)
        // <expr> BETWEEN <expr> AND <expr>
        case betweenOperator(Expression, BetweenOperator, Expression, Expression)
        // `<expr> IN (<in-expr>)`
        case subsetOperator(Expression, SubsetOperator, SubsetExpression)
        case subSelect(ExistsOperator?, Select)
        /// CASE <expr> (WHEN <expr> THEN <expr>) ELSE <expr> END
        case caseExpression(Expression?, [CaseCondition], Expression?)
        case raiseFunction(RaiseFunction)
    }
}

extension SQLiteQuery.Expression {
    public static func bind<E>(_ value: E) throws -> SQLiteQuery.Expression where E: Encodable {
        return try SQLiteQueryExpressionEncoder().encode(value)
    }
}

extension SQLiteQuery.Expression: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self = .column(.init(stringLiteral: value))
    }
}

extension SQLiteQuery.Expression: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: SQLiteQuery.Expression...) {
        self = .expressions(elements)
    }
}

extension SQLiteSerializer {
    func serialize(_ expr: SQLiteQuery.Expression, _ binds: inout [SQLiteData]) -> String {
        switch expr {
        case .data(let value):
            binds.append(value)
            return "?"
        case .literal(let literal): return serialize(literal)
        case .unary(let op, let expr):
            return serialize(op) + " " + serialize(expr, &binds)
        case .binary(let lhs, let op, let rhs):
            return serialize(lhs, &binds) + " " + serialize(op) + " " + serialize(rhs, &binds)
        case .column(let col): return serialize(col)
        case .compare(let compare): return serialize(compare, &binds)
        case .expressions(let exprs):
            return "(" + exprs.map { serialize($0, &binds) }.joined(separator: ", ") + ")"
        default: return "\(expr)"
        }
    }
}
