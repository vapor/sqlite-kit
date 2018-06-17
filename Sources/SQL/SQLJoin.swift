public protocol SQLJoin: SQLSerializable {
    associatedtype Query: SQLQuery
    
    static func join(
        _ method: Query.JoinMethod,
        _ table: Query.TableIdentifier,
        _ expression: Query.Expression
    ) -> Self
}

public struct GenericSQLJoin<Query>: SQLJoin where Query: SQLQuery {
    /// See `SQLJoin`.
    public static func join(
        _ method: Query.JoinMethod,
        _ table: Query.TableIdentifier,
        _ expression: Query.Expression
    ) -> GenericSQLJoin<Query> {
        return .init(method: method, table: table, expression: expression)
    }
    
    public var method: Query.JoinMethod
    public var table: Query.TableIdentifier
    public var expression: Query.Expression
    
    /// See `SQLSerializable`.
    public func serialize(_ binds: inout [Encodable]) -> String {
        return method.serialize(&binds) + " JOIN " + table.serialize(&binds) + " ON " + expression.serialize(&binds)
    }
}
