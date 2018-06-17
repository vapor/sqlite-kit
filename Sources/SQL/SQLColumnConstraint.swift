public protocol SQLColumnConstraint: SQLSerializable {
    associatedtype Query: SQLQuery
    static func constraint(_ algorithm: Query.ColumnConstraintAlgorithm, _ identifier: Query.Identifier?) -> Self
}

// MARK: Convenience

extension SQLColumnConstraint {
    public static var primaryKey: Self {
        return .primaryKey(identifier: nil)
    }
    
    /// Creates a new `PRIMARY KEY` column constraint.
    ///
    /// - parameters:
    ///     - identifier: Optional constraint name.
    /// - returns: New column constraint.
    public static func primaryKey(identifier: Query.Identifier?) -> Self {
        return .constraint(.primaryKey(.primaryKey()), identifier)
    }
    
    public static var notNull: Self {
        return .notNull(identifier: nil)
    }
    
    /// Creates a new `NOT NULL` column constraint.
    ///
    /// - parameters:
    ///     - identifier: Optional constraint name.
    /// - returns: New column constraint.
    public static func notNull(identifier: Query.Identifier?) -> Self {
        return .constraint(.notNull, identifier)
    }
    
    /// Creates a new `UNIQUE` column constraint.
    ///
    /// - parameters:
    ///     - identifier: Optional constraint name.
    /// - returns: New column constraint.
    public static func unique(identifier: Query.Identifier? = nil) -> Self {
        return .constraint(.unique, identifier)
    }
    
    /// Creates a new `DEFAULT <expr>` column constraint.
    ///
    /// - parameters
    ///     - expression: Expression to evaluate when setting the default value.
    ///     - identifier: Optional constraint name.
    /// - returns: New column constraint.
    public static func `default`(
        _ expression: Query.Expression,
        identifier: Query.Identifier? = nil
    ) -> Self {
        return .constraint(.default(expression), identifier)
    }
    
    public static func references<T, V>(
        _ keyPath: KeyPath<T, V>,
        onDelete: Query.ConflictResolution? = nil,
        onUpdate: Query.ConflictResolution? = nil,
        identifier: Query.Identifier? = nil
        ) -> Self
        where T: SQLTable
    {
        return references(.keyPath(keyPath), [.keyPath(keyPath)], onDelete: onDelete, onUpdate: onUpdate, identifier: identifier)
    }
    
    public static func references(
        _ foreignTable: Query.TableIdentifier,
        _ foreignColumns: [Query.Identifier],
        onDelete: Query.ConflictResolution? = nil,
        onUpdate: Query.ConflictResolution? = nil,
        identifier: Query.Identifier? = nil
        ) -> Self {
        return .constraint(.foreignKey(.foreignKey(foreignTable, foreignColumns, onDelete: onDelete, onUpdate: onUpdate)), identifier)
    }
}


// MARK: Generic

public struct GenericSQLColumnConstraint<Query>: SQLColumnConstraint where Query: SQLQuery {
    public typealias `Self` = GenericSQLColumnConstraint<Query>
    
    /// See `SQLColumnConstraint`.
    public static func constraint(_ algorithm: Query.ColumnConstraintAlgorithm, _ identifier: Query.Identifier?) -> Self {
        return .init(identifier: identifier, algorithm: algorithm)
    }
    
    public var identifier: Identifier?
    
    public var algorithm: Query.ColumnConstraintAlgorithm
    
    /// See `SQLSerializable`.
    public func serialize(_ binds: inout [Encodable]) -> String {
        if let identifier = self.identifier {
            return "CONSTRAINT " + identifier.serialize(&binds) + " " + algorithm.serialize(&binds)
        } else {
            return algorithm.serialize(&binds)
        }
    }
}
