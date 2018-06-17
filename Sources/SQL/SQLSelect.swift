public protocol SQLSelect: SQLSerializable {
    associatedtype Query: SQLQuery
    
    static func select() -> Self
    
    var distinct: Query.Distinct? { get set }
    var columns: [Query.SelectExpression] { get set }
    var tables: [Query.TableIdentifier] { get set }
    var joins: [Query.Join] { get set }
    var predicate: Query.Expression? { get set }
    var groupBy: [Query.GroupBy] { get set }
    var orderBy: [Query.OrderBy] { get set }
}

// MARK: Generic

public struct GenericSQLSelect<Query>: SQLSelect where Query: SQLQuery
{
    public typealias `Self` = GenericSQLSelect<Query>
    
    public var distinct: Query.Distinct?
    public var columns: [Query.SelectExpression]
    public var tables: [Query.TableIdentifier]
    public var joins: [Query.Join]
    public var predicate: Query.Expression?
    public var groupBy: [Query.GroupBy]
    public var orderBy: [Query.OrderBy]
    
    /// See `SQLSelect`.
    public static func select() -> Self {
        return .init(distinct: nil, columns: [], tables: [], joins: [], predicate: nil, groupBy: [], orderBy: [])
    }
    
    /// See `SQLSerializable`.
    public func serialize(_ binds: inout [Encodable]) -> String {
        var sql: [String] = []
        sql.append("SELECT")
        if let distinct = self.distinct {
            sql.append(distinct.serialize(&binds))
        }
        sql.append(columns.serialize(&binds))
        if !tables.isEmpty {
            sql.append("FROM")
            sql.append(tables.serialize(&binds))
        }
        if !joins.isEmpty {
            sql.append(joins.serialize(&binds))
        }
        if let predicate = self.predicate {
            sql.append("WHERE")
            sql.append(predicate.serialize(&binds))
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
