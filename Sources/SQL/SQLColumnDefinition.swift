public protocol SQLColumnDefinition: SQLSerializable {
    associatedtype Query: SQLQuery
    static func columnDefinition(
        _ column: Query.ColumnIdentifier,
        _ dataType: Query.DataType,
        _ constraints: [Query.ColumnConstraint]
    ) -> Self
}

// MARK: Generic

public struct GenericSQLColumnDefinition<Query>: SQLColumnDefinition where Query: SQLQuery {
    public typealias `Self` = GenericSQLColumnDefinition<Query>
    
    /// See `SQLColumnDefinition`.
    public static func columnDefinition(_ column: Query.ColumnIdentifier, _ dataType: Query.DataType, _ constraints: [Query.ColumnConstraint]) -> Self {
        return .init(column: column, dataType: dataType, constraints: constraints)
    }
    
    public var column: Query.ColumnIdentifier
    public var dataType: Query.DataType
    public var constraints: [Query.ColumnConstraint]
    
    /// See `SQLSerializable`.
    public func serialize(_ binds: inout [Encodable]) -> String {
        var sql: [String] = []
        sql.append(column.identifier.serialize(&binds))
        sql.append(dataType.serialize(&binds))
        sql.append(constraints.serialize(&binds, joinedBy: " "))
        return sql.joined(separator: " ")
    }
}
