public protocol SQLTableConstraint: SQLSerializable {
    associatedtype Query: SQLQuery
    static func constraint(_ algorithm: Query.TableConstraintAlgorithm, _ identifier: Query.Identifier?) -> Self
}

// MARK: Convenience

extension SQLTableConstraint {
    public static func primaryKey(
        _ columns: Query.ColumnIdentifier...,
        identifier: Query.Identifier? = nil
    ) -> Self {
        return .constraint(.primaryKey(columns, .primaryKey()), identifier)
    }
    public static func unique(
        _ columns: Query.ColumnIdentifier...,
        identifier: Query.Identifier? = nil
    ) -> Self {
        return .constraint(.unique(columns), identifier)
    }
    
    public static func foreignKey(
        _ columns: [Query.ColumnIdentifier],
        references foreignTable: Query.TableIdentifier,
        _ foreignColumns: [Query.Identifier],
        onDelete: Query.ConflictResolution? = nil,
        onUpdate: Query.ConflictResolution? = nil,
        identifier: Query.Identifier? = nil
    ) -> Self {
        return .constraint(.foreignKey(columns, .foreignKey(foreignTable, foreignColumns, onDelete: onDelete, onUpdate: onUpdate)), identifier)
    }
}

// MARK: Generic

public struct GenericSQLTableConstraint<Query>: SQLTableConstraint where Query: SQLQuery {
    public typealias `Self` = GenericSQLTableConstraint<Query>
    
    /// See `SQLColumnConstraint`.
    public static func constraint(_ algorithm: Query.TableConstraintAlgorithm, _ identifier: Query.Identifier?) -> Self {
        return .init(identifier: identifier, algorithm: algorithm)
    }
    
    public var identifier: Query.Identifier?
    
    public var algorithm: Query.TableConstraintAlgorithm
    
    /// See `SQLSerializable`.
    public func serialize(_ binds: inout [Encodable]) -> String {
        if let identifier = self.identifier {
            return "CONSTRAINT " + identifier.serialize(&binds) + " " + algorithm.serialize(&binds)
        } else {
            return algorithm.serialize(&binds)
        }
    }
}
