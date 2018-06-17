public protocol SQLTableConstraintAlgorithm: SQLSerializable {
    associatedtype Query: SQLQuery
    static func primaryKey(_ columns: [Query.ColumnIdentifier],_ primaryKey: Query.PrimaryKey) -> Self
    static var notNull: Self { get }
    static func unique(_ columns: [Query.ColumnIdentifier]) -> Self
    static func check(_ expression: Query.Expression) -> Self
    static func foreignKey(_ columns: [Query.ColumnIdentifier], _ foreignKey: Query.ForeignKey) -> Self
}

// MARK: Generic

public enum GenericSQLTableConstraintAlgorithm<Query>: SQLTableConstraintAlgorithm where Query: SQLQuery
{
    public typealias `Self` = GenericSQLTableConstraintAlgorithm<Query>
    
    /// See `SQLColumnConstraintAlgorithm`.
    public static func primaryKey(_ columns: [Query.ColumnIdentifier], _ primaryKey: Query.PrimaryKey) -> Self {
        return ._primaryKey(columns, primaryKey)
    }
    
    /// See `SQLColumnConstraintAlgorithm`.
    public static var notNull: Self {
        return ._notNull
    }
    
    /// See `SQLColumnConstraintAlgorithm`.
    public static func unique(_ columns: [Query.ColumnIdentifier]) -> Self {
        return ._unique(columns)
    }
    
    /// See `SQLColumnConstraintAlgorithm`.
    public static func check(_ expression: Query.Expression) -> Self {
        return ._check(expression)
    }
    
    /// See `SQLColumnConstraintAlgorithm`.
    public static func foreignKey(_ columns: [Query.ColumnIdentifier], _ foreignKey: Query.ForeignKey) -> Self {
        return ._foreignKey(columns, foreignKey)
    }
    
    case _primaryKey([Query.ColumnIdentifier], Query.PrimaryKey)
    case _notNull
    case _unique([Query.ColumnIdentifier])
    case _check(Query.Expression)
    case _foreignKey([Query.ColumnIdentifier], Query.ForeignKey)
    
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
