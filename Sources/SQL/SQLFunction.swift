public protocol SQLFunction: SQLSerializable {
    associatedtype Query: SQLQuery
    static func function(_ name: String, _ args: [Argument]) -> Self
}

// MARK: Generic

public struct GenericSQLFunction<Query>: SQLFunction where Query: SQLQuery {
    public typealias `Self` = GenericSQLFunction<Query>

    /// See `SQLFunction`.
    public static func function(_ name: String, _ args: [Query.FunctionArgument]) -> Self {
        return .init(name: name, arguments: args)
    }
    
    public var name: String
    public var arguments: [Query.FunctionArgument]
    
    /// See `SQLSerializable`.
    public func serialize(_ binds: inout [Encodable]) -> String {
        return name + "(" + arguments.map { $0.serialize(&binds) }.joined(separator: ", ") + ")"
    }
}
