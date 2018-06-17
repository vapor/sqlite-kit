public protocol SQLOrderBy: SQLSerializable {
    associatedtype Query: SQLQuery
    static func orderBy(_ expression: Query.Expression, _ direction: Query.Direction) -> Self
}

// MARK: Generic

public struct GenericSQLOrderBy<Query>: SQLOrderBy where Query: SQLQuery {
    public typealias `Self` = GenericSQLOrderBy<Query>

    public static func orderBy(_ expression: Query.Expression, _ direction: Query.Direction) -> Self {
        return .init(expression: expression, direction: direction)
    }
    
    public var expression: Query.Expression
    public var direction: Query.Direction
    
    public func serialize(_ binds: inout [Encodable]) -> String {
        return expression.serialize(&binds) + " " + direction.serialize(&binds)
    }
}
