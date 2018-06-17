public protocol SQLBind: SQLSerializable {
    associatedtype Query: SQLQuery
    static func encodable<E>(_ value: E) -> Self
        where E: Encodable
}

// MARK: Generic

public struct GenericSQLBind<Query>: SQLBind where Query: SQLQuery {
    /// See `SQLBind`.
    public static func encodable<E>(_ value: E) -> GenericSQLBind<Query>
        where E: Encodable
    {
        return self.init(value: value)
    }
    
    public var value: Encodable
    
    /// See `SQLSerializable`.
    public func serialize(_ binds: inout [Encodable]) -> String {
        binds.append(value)
        return "?"
    }
}
