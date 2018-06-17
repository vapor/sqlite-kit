public protocol SQLSelect: SQLSerializable {
    associatedtype Distinct: SQLDistinct
    associatedtype SelectExpression: SQLSelectExpression
    associatedtype TableIdentifier: SQLTableIdentifier
    associatedtype Expression: SQLExpression
    associatedtype GroupBy: SQLGroupBy
    associatedtype OrderBy: SQLOrderBy
    
    static func select() -> Self
    
    var distinct: Distinct? { get set }
    var columns: [SelectExpression] { get set }
    var from: [TableIdentifier] { get set }
    var `where`: Expression? { get set }
    var groupBy: [GroupBy] { get set }
    var orderBy: [OrderBy] { get set }
}

// MARK: Generic

public struct GenericSQLSelect<Distinct, SelectExpression, TableIdentifier, Expression, GroupBy, OrderBy>: SQLSelect
    where Distinct: SQLDistinct, SelectExpression: SQLSelectExpression, TableIdentifier: SQLTableIdentifier, Expression: SQLExpression, GroupBy: SQLGroupBy, OrderBy: SQLOrderBy
{
    public typealias `Self` = GenericSQLSelect<Distinct, SelectExpression, TableIdentifier, Expression, GroupBy, OrderBy>
    
    public var distinct: Distinct?
    public var columns: [SelectExpression]
    public var from: [TableIdentifier]
    public var `where`: Expression?
    public var groupBy: [GroupBy]
    public var orderBy: [OrderBy]
    
    /// See `SQLSelect`.
    public static func select() -> Self {
        return .init(distinct: nil, columns: [], from: [], where: nil, groupBy: [], orderBy: [])
    }
    
    /// See `SQLSerializable`.
    public func serialize(_ binds: inout [Encodable]) -> String {
        var sql: [String] = []
        sql.append("SELECT")
        if let distinct = self.distinct {
            sql.append(distinct.serialize(&binds))
        }
        sql.append(columns.serialize(&binds))
        if !from.isEmpty {
            sql.append("FROM")
            sql.append(from.serialize(&binds))
        }
        if let `where` = self.where {
            sql.append("WHERE")
            sql.append(`where`.serialize(&binds))
        }
        if !groupBy.isEmpty {
            sql.append("GROUP BY")
            sql.append(groupBy.serialize(&binds))
        }
        if !orderBy.isEmpty {
            sql.append("ORDER BY")
            sql.append(orderBy.serialize(&binds))
        }
        return sql.joined(separator: " ")
        
    }
}
