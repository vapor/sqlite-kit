import SQLKit
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

    public var enumSyntax: SQLEnumSyntax {
        .unsupported
    }

    public var supportsAutoIncrement: Bool {
        false
    }

    public var alterTableSyntax: SQLAlterTableSyntax {
        .init(
            alterColumnDefinitionClause: nil,
            alterColumnDefinitionTypeKeyword: nil,
            allowsBatch: false
        )
    }

    public var triggerSyntax: SQLTriggerSyntax {
        return .init(create: [.supportsBody, .supportsCondition])
    }
    
    public var upsertSyntax: SQLUpsertSyntax {
        .standard
    }
    
    public func customDataType(for dataType: SQLDataType) -> SQLExpression? {
        if case .bigint = dataType {
            // would prefer to do this only when `PRIMARY KEY` is also specified to minimize disruption,
            // but can't figure that out from here without more info
            return SQLDataType.int
        }
        return nil
    }
    
    public init() { }
}
