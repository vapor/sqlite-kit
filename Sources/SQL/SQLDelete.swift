public protocol SQLDelete: SQLSerializable {
    associatedtype Query: SQLQuery
    
    static func delete(_ table: Query.TableIdentifier) -> Self
    
    var table: Query.TableIdentifier { get set }
    
    /// If the WHERE clause is not present, all records in the table are deleted. If a WHERE clause is supplied,
    /// then only those rows for which the WHERE clause boolean expression is true are deleted. Rows for which
    /// the expression is false or NULL are retained.
    var predicate: Query.Expression? { get set }
}

// MARK: Generic

public struct GenericSQLDelete<Query>: SQLDelete where Query: SQLQuery {
    /// See `SQLDelete`.
    public static func delete(_ table: Query.TableIdentifier) -> GenericSQLDelete<Query> {
        return .init(table: table, predicate: nil)
    }
    
    /// See `SQLDelete`.
    public var table: Query.TableIdentifier
    
    /// See `SQLDelete`.
    public var predicate: Query.Expression?
    
    /// See `SQLSerializable`.
    public func serialize(_ binds: inout [Encodable]) -> String {
        var sql: [String] = []
        sql.append("DELETE FROM")
        sql.append(table.serialize(&binds))
        if let predicate = self.predicate {
            sql.append("WHERE")
            sql.append(predicate.serialize(&binds))
        }
        return sql.joined(separator: " ")
    }
}
