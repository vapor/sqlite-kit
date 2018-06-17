public protocol SQLForeignKey: SQLSerializable {
    associatedtype Query: SQLQuery
    
    static func foreignKey(
        _ foreignTable: Query.TableIdentifier,
        _ foreignColumns: [Query.Identifier],
        onDelete: Query.ConflictResolution?,
        onUpdate: Query.ConflictResolution?
    ) -> Self
}

// MARK: Generic

public struct GenericSQLForeignKey<Query>: SQLForeignKey where Query: SQLQuery {
    public typealias `Self` = GenericSQLForeignKey<Query>
    
    /// See `SQLForeignKey`.
    public static func foreignKey(
        _ foreignTable: Query.TableIdentifier,
        _ foreignColumns: [Query.Identifier],
        onDelete: Query.ConflictResolution?,
        onUpdate: Query.ConflictResolution?
    ) -> Self {
        return .init(foreignTable: foreignTable, foreignColumns: foreignColumns, onDelete: onDelete, onUpdate: onUpdate)
    }
    
    public var foreignTable: Query.TableIdentifier
    
    public var foreignColumns: [Query.Identifier]
    
    public var onDelete: Query.ConflictResolution?
    
    public var onUpdate: Query.ConflictResolution?
    
    /// See `SQLSerializable`.
    public func serialize(_ binds: inout [Encodable]) -> String {
        var sql: [String] = []
        sql.append(foreignTable.serialize(&binds))
        sql.append("(" + foreignColumns.serialize(&binds) + ")")
        if let onDelete = onDelete {
            sql.append("ON DELETE")
            sql.append(onDelete.serialize(&binds))
        }
        if let onUpdate = onUpdate {
            sql.append("ON UPDATE")
            sql.append(onUpdate.serialize(&binds))
        }
        return sql.joined(separator: " ")
    }
}
