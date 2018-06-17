public protocol SQLTableConstraint: SQLSerializable {
    associatedtype Identifier: SQLIdentifier
    associatedtype TableConstraintAlgorithm: SQLTableConstraintAlgorithm
    static func constraint(_ algorithm: TableConstraintAlgorithm, _ identifier: Identifier?) -> Self
}

// MARK: Convenience

extension SQLTableConstraint {
    public static func primaryKey(
        _ columns: TableConstraintAlgorithm.ColumnIdentifier...,
        identifier: Identifier? = nil
    ) -> Self {
        return .constraint(.primaryKey(columns, .primaryKey()), identifier)
    }
    public static func unique(
        _ columns: TableConstraintAlgorithm.ColumnIdentifier...,
        identifier: Identifier? = nil
    ) -> Self {
        return .constraint(.unique(columns), identifier)
    }
    
    public static func foreignKey(
        _ columns: [TableConstraintAlgorithm.ColumnIdentifier],
        references foreignTable: TableConstraintAlgorithm.ForeignKey.TableIdentifier,
        _ foreignColumns: [TableConstraintAlgorithm.ForeignKey.Identifier],
        onDelete: TableConstraintAlgorithm.ForeignKey.ConflictResolution? = nil,
        onUpdate: TableConstraintAlgorithm.ForeignKey.ConflictResolution? = nil,
        identifier: Identifier? = nil
    ) -> Self {
        return .constraint(.foreignKey(columns, .foreignKey(foreignTable, foreignColumns, onDelete: onDelete, onUpdate: onUpdate)), identifier)
    }
}

// MARK: Generic

public struct GenericSQLTableConstraint<Identifier, TableConstraintAlgorithm>: SQLTableConstraint
    where Identifier: SQLIdentifier, TableConstraintAlgorithm: SQLTableConstraintAlgorithm
{
    public typealias `Self` = GenericSQLTableConstraint<Identifier, TableConstraintAlgorithm>
    
    /// See `SQLColumnConstraint`.
    public static func constraint(_ algorithm: TableConstraintAlgorithm, _ identifier: Identifier?) -> Self {
        return .init(identifier: identifier, algorithm: algorithm)
    }
    
    public var identifier: Identifier?
    
    public var algorithm: TableConstraintAlgorithm
    
    /// See `SQLSerializable`.
    public func serialize(_ binds: inout [Encodable]) -> String {
        if let identifier = self.identifier {
            return "CONSTRAINT " + identifier.serialize(&binds) + " " + algorithm.serialize(&binds)
        } else {
            return algorithm.serialize(&binds)
        }
    }
}
