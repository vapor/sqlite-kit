public protocol SQLUpdate: SQLSerializable {
    associatedtype Query: SQLQuery
    
    static func update(_ table: Query.TableIdentifier) -> Self
    
    var table: Query.TableIdentifier { get set }
    var values: [(Query.Identifier, Query.Expression)] { get set }
    var predicate: Query.Expression? { get set }
}

// MARK: Generic

public struct GenericSQLUpdate<Query>: SQLUpdate where Query: SQLQuery {
    public typealias `Self` = GenericSQLUpdate<Query>
    
    public static func update(_ table: Query.TableIdentifier) -> Self {
        return .init(table: table, values: [], predicate: nil)
    }
    
    public var table: Query.TableIdentifier
    public var values: [(Query.Identifier, Query.Expression)]
    public var predicate: Query.Expression?
    
    /// See `SQLSerializable`.
    public func serialize(_ binds: inout [Encodable]) -> String {
        var sql: [String] = []
        sql.append("UPDATE")
        sql.append(table.serialize(&binds))
        sql.append("SET")
        sql.append(values.map { $0.0.serialize(&binds) + " = " + $0.1.serialize(&binds) }.joined(separator: ", "))
        if let predicate = self.predicate {
            sql.append("WHERE")
            sql.append(predicate.serialize(&binds))
        }
        return sql.joined(separator: " ")
    }
}
