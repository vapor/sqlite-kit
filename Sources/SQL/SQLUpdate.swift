public protocol SQLUpdate: SQLSerializable {
    associatedtype TableIdentifier: SQLTableIdentifier
    associatedtype Identifier: SQLIdentifier
    associatedtype Expression: SQLExpression
    
    static func update(_ table: TableIdentifier) -> Self
    
    var table: TableIdentifier { get set }
    var values: [(Identifier, Expression)] { get set }
    var `where`: Expression? { get set }
}

// MARK: Generic

public struct GenericSQLUpdate<TableIdentifier, Identifier, Expression>: SQLUpdate
    where TableIdentifier: SQLTableIdentifier, Identifier: SQLIdentifier, Expression: SQLExpression
{
    public typealias `Self` = GenericSQLUpdate<TableIdentifier, Identifier, Expression>
    
    public static func update(_ table: TableIdentifier) -> Self {
        return .init(table: table, values: [], where: nil)
    }
    
    public var table: TableIdentifier
    public var values: [(Identifier, Expression)]
    public var `where`: Expression?
    
    /// See `SQLSerializable`.
    public func serialize(_ binds: inout [Encodable]) -> String {
        var sql: [String] = []
        sql.append("UPDATE")
        sql.append(table.serialize(&binds))
        sql.append("SET")
        sql.append(values.map { $0.0.serialize(&binds) + " = " + $0.1.serialize(&binds) }.joined(separator: ", "))
        if let `where` = self.where {
            sql.append("WHERE")
            sql.append(`where`.serialize(&binds))
        }
        return sql.joined(separator: " ")
    }
}
