public protocol SQLColumnConstraintAlgorithm: SQLSerializable {
    associatedtype Query: SQLQuery
    static func primaryKey(_ primaryKey: Query.PrimaryKey) -> Self
    static var notNull: Self { get }
    static var unique: Self { get }
    static func check(_ expression: Query.Expression) -> Self
    static func collate(_ collation: Query.Collation) -> Self
    static func `default`(_ expression: Query.Expression) -> Self
    static func foreignKey(_ foreignKey: Query.ForeignKey) -> Self
}

// MARK: Generic

public enum GenericSQLColumnConstraintAlgorithm<Query>: SQLColumnConstraintAlgorithm where Query: SQLQuery {
    public typealias `Self` = GenericSQLColumnConstraintAlgorithm<Query>
    
    /// See `SQLColumnConstraintAlgorithm`.
    public static func primaryKey(_ primaryKey: Query.PrimaryKey) -> Self {
        return ._primaryKey(primaryKey)
    }
    
    /// See `SQLColumnConstraintAlgorithm`.
    public static var notNull: Self {
        return ._notNull
    }
    
    /// See `SQLColumnConstraintAlgorithm`.
    public static var unique: Self {
        return ._unique
    }
    
    /// See `SQLColumnConstraintAlgorithm`.
    public static func check(_ expression: Query.Expression) -> Self {
        return ._check(expression)
    }
    
    /// See `SQLColumnConstraintAlgorithm`.
    public static func collate(_ collation: Query.Collation) -> Self {
        return .collate(collation)
    }
    
    /// See `SQLColumnConstraintAlgorithm`.
    public static func `default`(_ expression: Query.Expression) -> Self {
        return ._default(expression)
    }
    
    /// See `SQLColumnConstraintAlgorithm`.
    public static func foreignKey(_ foreignKey: Query.ForeignKey) -> Self {
        return ._foreignKey(foreignKey)
    }
    
    case _primaryKey(PrimaryKey)
    case _notNull
    case _unique
    case _check(Expression)
    case _collate(Collation)
    case _default(Expression)
    case _foreignKey(ForeignKey)
    
    /// See `SQLSerializable`.
    public func serialize(_ binds: inout [Encodable]) -> String {
        switch self {
        case ._primaryKey(let primaryKey):
            let pk = primaryKey.serialize(&binds)
            if pk.isEmpty {
                return "PRIMARY KEY"
            } else {
                return "PRIMARY KEY " + pk
            }
        case ._notNull: return "NOT NULL"
        case ._unique: return "UNIQUE"
        case ._check(let expression):
            return "CHECK (" + expression.serialize(&binds) + ")"
        case ._collate(let collation):
            return "COLLATE " + collation.serialize(&binds)
        case ._default(let expression):
            return "DEFAULT (" + expression.serialize(&binds) + ")"
        case ._foreignKey(let foreignKey): return "REFERENCES " + foreignKey.serialize(&binds)
        }
    }
}
