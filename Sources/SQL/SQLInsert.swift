public protocol SQLInsert: SQLSerializable {
    associatedtype Query: SQLQuery

    static func insert(_ table: Query.TableIdentifier) -> Self
    var columns: [Query.ColumnIdentifier] { get set }
    var values: [[Query.Expression]] { get set }
}

// MARK: Generic

public struct GenericSQLInsert<Query>: SQLInsert where Query: SQLQuery {
    public typealias `Self` = GenericSQLInsert<Query>
    
    /// See `SQLInsert`.
    public static func insert(_ table: TableIdentifier) -> Self {
        return .init(table: table, columns: [], values: [])
    }
    
    public var table: Query.TableIdentifier
    public var columns: [Query.ColumnIdentifier]
    public var values: [[Query.Expression]]
    
    /// See `SQLSerializable`.
    public func serialize(_ binds: inout [Encodable]) -> String {
        var sql: [String] = []
        sql.append("INSERT INTO")
        sql.append(table.serialize(&binds))
        sql.append("(" + columns.serialize(&binds) + ")")
        sql.append("VALUES")
        sql.append(values.map { "(" + $0.serialize(&binds) + ")"}.joined(separator: ", "))
        return sql.joined(separator: " ")
    }
}
