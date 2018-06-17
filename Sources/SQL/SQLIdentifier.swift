public protocol SQLIdentifier: SQLSerializable {
    static func identifier(_ string: String) -> Self
}

// MARK: Generic

public struct GenericSQLIdentifier: SQLIdentifier {
    public static func identifier(_ string: String) -> GenericSQLIdentifier {
        return self.init(string: string)
    }
    
    public let string: String
    
    public func serialize(_ binds: inout [Encodable]) -> String {
        return "\"" + string + "\""
    }
}
