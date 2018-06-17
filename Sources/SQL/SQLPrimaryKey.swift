public protocol SQLPrimaryKey: SQLSerializable {
    associatedtype Query: SQLQuery
    static func primaryKey() -> Self
}

// MARK: Generic

public struct GenericSQLPrimaryKey<Query>: SQLPrimaryKey where Query: SQLQuery {
    public typealias `Self` = GenericSQLPrimaryKey<Query>

    /// See `SQLPrimaryKey`.
    public static func primaryKey() -> Self {
        return .init()
    }
    
    /// See `SQLSerializable`.
    public func serialize(_ binds: inout [Encodable]) -> String {
        return ""
    }
}
