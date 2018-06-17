public protocol SQLTableConstraintAlgorithm: SQLSerializable {
    associatedtype ColumnIdentifier: SQLColumnIdentifier
    associatedtype Expression: SQLExpression
    associatedtype Collation: SQLCollation
    associatedtype PrimaryKey: SQLPrimaryKey
    associatedtype ForeignKey: SQLForeignKey
    static func primaryKey(_ columns: [ColumnIdentifier],_ primaryKey: PrimaryKey) -> Self
    static var notNull: Self { get }
    static func unique(_ columns: [ColumnIdentifier]) -> Self
    static func check(_ expression: Expression) -> Self
    static func foreignKey(_ columns: [ColumnIdentifier], _ foreignKey: ForeignKey) -> Self
}

// MARK: Generic

public enum GenericSQLTableConstraintAlgorithm<ColumnIdentifier, Expression, Collation, PrimaryKey, ForeignKey>: SQLTableConstraintAlgorithm
    where ColumnIdentifier: SQLColumnIdentifier, Expression: SQLExpression, Collation: SQLCollation, PrimaryKey: SQLPrimaryKey, ForeignKey: SQLForeignKey
{
    public typealias `Self` = GenericSQLTableConstraintAlgorithm<ColumnIdentifier, Expression, Collation, PrimaryKey, ForeignKey>
    
    /// See `SQLColumnConstraintAlgorithm`.
    public static func primaryKey(_ columns: [ColumnIdentifier], _ primaryKey: PrimaryKey) -> Self {
        return ._primaryKey(columns, primaryKey)
    }
    
    /// See `SQLColumnConstraintAlgorithm`.
    public static var notNull: Self {
        return ._notNull
    }
    
    /// See `SQLColumnConstraintAlgorithm`.
    public static func unique(_ columns: [ColumnIdentifier]) -> Self {
        return ._unique(columns)
    }
    
    /// See `SQLColumnConstraintAlgorithm`.
    public static func check(_ expression: Expression) -> Self {
        return ._check(expression)
    }
    
    /// See `SQLColumnConstraintAlgorithm`.
    public static func foreignKey(_ columns: [ColumnIdentifier], _ foreignKey: ForeignKey) -> Self {
        return ._foreignKey(columns, foreignKey)
    }
    
    case _primaryKey([ColumnIdentifier], PrimaryKey)
    case _notNull
    case _unique([ColumnIdentifier])
    case _check(Expression)
    case _foreignKey([ColumnIdentifier], ForeignKey)
    
    /// See `SQLSerializable`.
    public func serialize(_ binds: inout [Encodable]) -> String {
        switch self {
        case ._primaryKey(let columns, let primaryKey):
            var sql: [String] = []
            sql.append("PRIMARY KEY")
            sql.append("(" + columns.serialize(&binds) + ")")
            sql.append(primaryKey.serialize(&binds))
            return sql.joined(separator: " ")
        case ._notNull: return "NOT NULL"
        case ._unique(let columns):
            var sql: [String] = []
            sql.append("UNIQUE")
            sql.append("(" + columns.serialize(&binds) + ")")
            return sql.joined(separator: " ")
        case ._check(let expression):
            return "CHECK (" + expression.serialize(&binds) + ")"
        case ._foreignKey(let columns, let foreignKey):
            var sql: [String] = []
            sql.append("FOREIGN KEY")
            sql.append("(" + columns.serialize(&binds) + ")")
            sql.append("REFERENCES")
            sql.append(foreignKey.serialize(&binds))
            return sql.joined(separator: " ")
        }
    }
}
