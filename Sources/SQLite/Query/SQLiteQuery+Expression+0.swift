extension SQLiteQuery {
    public indirect enum Expression {
        /// Binds an `Encodable` value as an `Expression`.
        ///
        /// - parameters:
        ///     - value: `Encodable` value to bind.
        /// - returns: `Expression`.
        public static func bind<E>(_ value: E) throws -> SQLiteQuery.Expression where E: Encodable {
            return try SQLiteQueryExpressionEncoder().encode(value)
        }
        
        /// Literal strings, integers, and constants.
        case literal(Literal)
        
        /// Bound data.
        case data(SQLiteData)
        
        /// Column name.
        case column(ColumnName)
        
        /// Binary expression.
        case binary(Expression, BinaryOperator, Expression)
        
        /// Function.
        case function(Function)
        
        /// Group of expressions.
        case expressions([Expression])
        
        /// `CAST (<expr> AS <typname>)`
        case cast(Expression, typeName: TypeName)
        
        /// `<expr> COLLATE <name>`
        case collate(Expression, String)
        
        /// `(SELECT ...)`
        case subSelect(Select)
    }
}

// MARK: Swift Literals

extension SQLiteQuery.Expression: ExpressibleByStringLiteral {
    /// See `ExpressibleByStringLiteral`.
    public init(stringLiteral value: String) {
        self = .column(.init(stringLiteral: value))
    }
}

extension SQLiteQuery.Expression: ExpressibleByArrayLiteral {
    /// See `ExpressibleByArrayLiteral`.
    public init(arrayLiteral elements: SQLiteQuery.Expression...) {
        self = .expressions(elements)
    }
}

// MARK: Serialize

extension SQLiteSerializer {
    internal func serialize(_ expr: SQLiteQuery.Expression, _ binds: inout [SQLiteData]) -> String {
        switch expr {
        case .data(let value):
            binds.append(value)
            return "?"
        case .literal(let literal): return serialize(literal)
        case .binary(let lhs, let op, let rhs):
            switch (op, rhs) {
            case (.equal, .literal(let l)) where l == .null: return serialize(lhs, &binds) + " IS NULL"
            case (.notEqual, .literal(let l)) where l == .null: return serialize(lhs, &binds) + " IS NOT NULL"
            default: return serialize(lhs, &binds) + " " + serialize(op) + " " + serialize(rhs, &binds)
            }
        case .column(let col): return serialize(col)
        case .expressions(let exprs):
            return "(" + exprs.map { serialize($0, &binds) }.joined(separator: ", ") + ")"
        case .function(let function):
            return serialize(function, &binds)
        case .subSelect(let select): return "(" + serialize(select, &binds) + ")"
        case .collate(let expr, let collate):
            return serialize(expr, &binds) + " COLLATE " + collate
        case .cast(let expr, let typeName):
            return "CAST (" + serialize(expr, &binds) + " AS " + serialize(typeName) + ")"
        }
    }
    
    func serialize(_ function: SQLiteQuery.Expression.Function, _ binds: inout [SQLiteData]) -> String {
        if let parameters = function.parameters {
            return function.name + "(" + serialize(parameters, &binds) + ")"
        } else {
            return function.name
        }
    }
    
    func serialize(_ parameters: SQLiteQuery.Expression.Function.Parameters, _ binds: inout [SQLiteData]) -> String {
        switch parameters {
        case .all: return "*"
        case .expressions(let distinct, let exprs):
            var sql: [String] = []
            if distinct {
                sql.append("DISTINCT")
            }
            sql.append(exprs.map { serialize($0, &binds) }.joined(separator: ", "))
            return sql.joined(separator: " ")
        }
    }
}
