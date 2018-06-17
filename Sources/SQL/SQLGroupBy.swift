public protocol SQLGroupBy: SQLSerializable {
    associatedtype Query: SQLQuery
    static func groupBy(_ expression: Query.Expression) -> Self
}

// MARK: Generic

public struct GenericSQLGroupBy<Query>: SQLGroupBy where Query: SQLQuery {
    public typealias `Self` = GenericSQLGroupBy<Query>

    public static func groupBy(_ expression: Expression) -> Self {
        return .init(expression: expression)
    }
    
    public var expression: Query.Expression
    
    public func serialize(_ binds: inout [Encodable]) -> String {
        return expression.serialize(&binds)
    }
}
