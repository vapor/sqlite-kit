public struct SQLiteFunction: SQLFunction {
    public typealias Argument = GenericSQLFunctionArgument<SQLiteExpression>
    
    public static var count: SQLiteFunction {
        return .init(name: "COUNT", arguments: [.all])
    }
    
    public static func function(_ name: String, _ args: [Argument]) -> SQLiteFunction {
        return .init(name: name, arguments: args)
    }
    
    public let name: String
    public let arguments: [Argument]
    
    public func serialize(_ binds: inout [Encodable]) -> String {
        return name + "(" + arguments.map { $0.serialize(&binds) }.joined(separator: ", ") + ")"
    }
}

extension SQLSelectExpression where Expression.Function == SQLiteFunction, Identifier == SQLiteIdentifier {
    public static func count(as alias: SQLiteIdentifier? = nil) -> Self {
        return .expression(.function(.count), alias: alias)
    }
}
