extension SQLiteQuery {
    public final class SelectBuilder: SQLitePredicateBuilder {
        public var select: Select
        
        public var predicate: SQLiteQuery.Expression? {
            get { return select.predicate }
            set { select.predicate = newValue }
        }
        
        public let connection: SQLiteConnection
        
        init(on connection: SQLiteConnection) {
            self.select = .init()
            self.connection = connection
        }
        
        public func column(function: String, as alias: String? = nil) -> Self {
            return column(function: function, .expressions(distinct: false, []), as: alias)
        }
        
        public func column(function: String, _ parameters: Expression.Function.Parameters?, as alias: String? = nil) -> Self {
            return column(expression: .function(.init(name: function, parameters: parameters)), as: alias)
        }
        
        public func column(expression: Expression, as alias: String? = nil) -> Self {
            return column(.expression(expression, alias: alias))
        }
        
        public func all(table: String? = nil) -> Self {
            return column(.all(table))
        }
        
        public func column(_ column: Select.ResultColumn) -> Self {
            select.columns.append(column)
            return self
        }
        
        public func from(_ tables: TableOrSubquery...) -> Self {
            select.tables += tables
            return self
        }
        
        public func from<Table>(_ table: Table.Type) -> Self
            where Table: SQLiteTable
        {
            select.tables.append(.table(.init(table:.init(table: Table.sqliteTableName))))
            return self
        }
        
        public func join<Table>(_ table: Table.Type, on expr: Expression) -> Self
            where Table: SQLiteTable
        {
            switch select.tables.count {
            case 0: fatalError("Must select from a atable before joining.")
            default:
                let join = SQLiteQuery.JoinClause.init(
                    table: select.tables[0],
                    joins: [
                        SQLiteQuery.JoinClause.Join(
                            natural: false,
                            .inner,
                            table: .table(.init(table:.init(table: Table.sqliteTableName))),
                            constraint: .condition(expr)
                        )
                    ]
                )
                select.tables[0] = .joinClause(join)
            }
            return self
        }
        
        public func run<D>(decoding type: D.Type) -> Future<[D]>
            where D: Decodable
        {
            return run { try SQLiteRowDecoder().decode(D.self, from: $0) }
        }
        
        public func run<T>(_ convert: @escaping ([SQLiteColumn: SQLiteData]) throws -> (T)) -> Future<[T]> {
            return run().map { try $0.map { try convert($0) } }
        }
        
        
        public func run() -> Future<[[SQLiteColumn: SQLiteData]]> {
            return connection.query(.select(select))
        }
    }
}

extension Dictionary where Key == SQLiteColumn, Value == SQLiteData {
    public func decode<Table>(_ type: Table.Type) throws -> Table where Table: SQLiteTable {
        return try decode(Table.self, from: Table.sqliteTableName.name.string)
    }
    
    public func decode<D>(_ type: D.Type, from table: String) throws -> D where D: Decodable {
        return try SQLiteRowDecoder().decode(D.self, from: self, table: table)
    }
}

public func ==<Table, Value>(_ lhs: KeyPath<Table, Value>, _ rhs: Value) throws -> SQLiteQuery.Expression
    where Table: SQLiteTable, Value: Encodable
{
    return try .binary(.column(lhs.sqliteColumnName), .equal, .bind(rhs))
}

public func ==<TableA, ValueA, TableB, ValueB>(
    _ lhs: KeyPath<TableA, ValueA>, _ rhs: KeyPath<TableB, ValueB>
) -> SQLiteQuery.Expression
    where TableA: SQLiteTable, ValueA: Encodable, TableB: SQLiteTable, ValueB: Encodable
{
    return .binary(.column(lhs.sqliteColumnName), .equal, .column(rhs.sqliteColumnName))
}

public func !=<Table, Value>(_ lhs: KeyPath<Table, Value>, _ rhs: Value) throws -> SQLiteQuery.Expression
    where Table: SQLiteTable, Value: Encodable
{
    return try .binary(.column(lhs.sqliteColumnName), .notEqual, .bind(rhs))
}

public protocol SQLiteTable: Codable, Reflectable {
    static var sqliteTableName: SQLiteQuery.TableName { get }
}

extension SQLiteTable {
    public static var sqliteTableName: SQLiteQuery.TableName {
        return .init(stringLiteral: "\(Self.self)")
    }
}

extension KeyPath where Root: SQLiteTable {
    public var sqliteColumnName: SQLiteQuery.ColumnName {
        guard let property = try! Root.reflectProperty(forKey: self) else {
            fatalError("Could not reflect property of type \(Value.self) on \(Root.self): \(self)")
        }
        return .init(
            table: .init(Root.sqliteTableName),
            name: .init(property.path[0])
        )
    }
}


extension SQLiteConnection {
    public func select() -> SQLiteQuery.SelectBuilder {
        return .init(on: self)
    }
}
