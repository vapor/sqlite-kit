public final class SQLSelectBuilder<Connection>: SQLQueryFetcher, SQLPredicateBuilder
    where Connection: SQLConnection
{
    /// `Select` query being built.
    public var select: Connection.Query.Select
    
    /// See `SQLQueryBuilder`.
    public var connection: Connection
    
    /// See `SQLQueryBuilder`.
    public var query: Connection.Query {
        return .select(select)
    }
    
    /// See `SQLWhereBuilder`.
    public var predicate: Connection.Query.Expression? {
        get { return select.predicate }
        set { select.predicate = newValue }
    }
    
    /// Creates a new `SQLCreateTableBuilder`.
    public init(_ select: Connection.Query.Select, on connection: Connection) {
        self.select = select
        self.connection = connection
    }
    
    public func column(
        function: String,
        _ arguments: Connection.Query.Select.Function.Argument...,
        as alias: String? = nil
    ) -> Self {
        return column(expression: .function(.function(function, arguments)), as: alias)
    }
    
    public func column(expression: Connection.Query.Select.SelectExpression.Expression, as alias: String? = nil) -> Self {
        return column(.expression(expression, alias: alias))
    }
    
    public func all() -> Self {
        return column(.all)
    }
    
    public func all(table: String) -> Self {
        return column(.allTable(table))
    }
    
    public func column(_ column: Connection.Query.Select.SelectExpression) -> Self {
        select.columns.append(column)
        return self
    }
    
    public func from(_ tables: Connection.Query.Select.TableIdentifier...) -> Self {
        select.tables += tables
        return self
    }
    
    public func from<Table>(_ table: Table.Type) -> Self
        where Table: SQLTable
    {
        select.tables.append(.table(.identifier(Table.sqlTableIdentifierString)))
        return self
    }
    
    public func join<A, B, C, D>(
        _ local: KeyPath<A, B>,
        to foreign: KeyPath<C, D>
    ) -> Self where A: SQLTable, B: Encodable, C: SQLTable, D: Encodable {
        return join(.default, local, to: foreign)
    }
    
    public func join<A, B, C, D>(
        _ method: Connection.Query.JoinMethod,
        _ local: KeyPath<A, B>,
        to foreign: KeyPath<C, D>
    ) -> Self where A: SQLTable, B: Encodable, C: SQLTable, D: Encodable {
        return join(method, C.self, on: local == foreign)
    }
    
    public func join<Table>(_ table: Table.Type, on expression: Connection.Query.Expression) -> Self
        where Table: SQLTable
    {
        return join(.default, table, on: expression)
    }
    
    public func join<Table>(_ method: Connection.Query.JoinMethod, _ table: Table.Type, on expression: Connection.Query.Expression) -> Self
        where Table: SQLTable
    {
        select.joins.append(.join(method, .table(Table.self), expression))
        return self
    }
    
    public func groupBy<T,V>(_ keyPath: KeyPath<T, V>) -> Self
        where T: SQLTable
    {
        return groupBy(.column(.keyPath(keyPath)))
    }
    
    public func groupBy(_ expression: Connection.Query.Select.GroupBy.Expression) -> Self {
        select.groupBy.append(.groupBy(expression))
        return self
    }
    
    public func orderBy<T,V>(_ keyPath: KeyPath<T, V>, _ direction: Connection.Query.Select.OrderBy.Direction = .ascending) -> Self
        where T: SQLTable
    {
        return orderBy(.column(.keyPath(keyPath)), direction)
    }
    
    public func orderBy(_ expression: Connection.Query.Select.OrderBy.Expression, _ direction: Connection.Query.Select.OrderBy.Direction = .ascending) -> Self {
        select.orderBy.append(.orderBy(expression, direction))
        return self
    }
    
    //        public func join<Table>(_ table: Table.Type, on expr: Expression) -> Self
    //            where Table: SQLiteTable
    //        {
    //            switch select.tables.count {
    //            case 0: fatalError("Must select from a atable before joining.")
    //            default:
    //                let join = SQLiteQuery.JoinClause.init(
    //                    table: select.tables[0],
    //                    joins: [
    //                        SQLiteQuery.JoinClause.Join(
    //                            natural: false,
    //                            .inner,
    //                            table: .table(.init(table:.init(table: Table.sqliteTableName))),
    //                            constraint: .condition(expr)
    //                        )
    //                    ]
    //                )
    //                select.tables[0] = .joinClause(join)
    //            }
    //            return self
    //        }
}

// MARK: Connection

extension SQLConnection {
    public func select() -> SQLSelectBuilder<Self> {
        return .init(.select(), on: self)
    }
}
