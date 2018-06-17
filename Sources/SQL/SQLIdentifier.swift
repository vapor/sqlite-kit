public protocol SQLIdentifier: SQLSerializable {
    associatedtype Query: SQLQuery
    static func identifier(_ string: String) -> Self
}

// MARK: Generic

public struct GenericSQLIdentifier<Query>: SQLIdentifier where Query: SQLQuery {
    public typealias `Self` = GenericSQLIdentifier<Query>

    public static func identifier(_ string: String) -> Self {
        return self.init(string: string)
    }
    
    public let string: String
    
    public func serialize(_ binds: inout [Encodable]) -> String {
        return "\"" + string + "\""
    }
}
