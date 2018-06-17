public protocol SQLDelete: SQLSerializable {
    associatedtype TableIdentifier: SQLTableIdentifier
    associatedtype Expression: SQLExpression
    
    static func delete(_ table: TableIdentifier) -> Self
    
    var from: TableIdentifier { get set }
    
    /// If the WHERE clause is not present, all records in the table are deleted. If a WHERE clause is supplied,
    /// then only those rows for which the WHERE clause boolean expression is true are deleted. Rows for which
    /// the expression is false or NULL are retained.
    var `where`: Expression? { get set }
}

// MARK: Generic

public struct GenericSQLDelete<TableIdentifier, Expression>: SQLDelete
    where TableIdentifier: SQLTableIdentifier, Expression: SQLExpression
{
    /// See `SQLDelete`.
    public static func delete(_ table: TableIdentifier) -> GenericSQLDelete<TableIdentifier, Expression> {
        return .init(from: table, where: nil)
    }
    
    /// See `SQLDelete`.
    public var from: TableIdentifier
    
    /// See `SQLDelete`.
    public var `where`: Expression?
    
    /// See `SQLSerializable`.
    public func serialize(_ binds: inout [Encodable]) -> String {
        var sql: [String] = []
        sql.append("DELETE FROM")
        sql.append(from.serialize(&binds))
        if let `where` = self.where {
            sql.append("WHERE")
            sql.append(`where`.serialize(&binds))
        }
        return sql.joined(separator: " ")
    }
}
