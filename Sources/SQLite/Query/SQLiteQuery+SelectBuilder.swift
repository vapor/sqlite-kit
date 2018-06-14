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
        
        @discardableResult
        public func all() -> Self {
            return columns(.all(nil))
        }
        
        @discardableResult
        public func columns(_ columns: Select.ResultColumn...) -> Self {
            select.columns += columns
            return self
        }
        
        public func from(_ tables: TableOrSubquery...) -> Self {
            select.tables += tables
            return self
        }
        
        public func from<Table>(_ table: Table.Type) -> Self
            where Table: SQLiteTable
        {
            select.tables.append(.table(.init(stringLiteral: Table.sqliteTableName)))
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
                        SQLiteQuery.JoinClause.Join.init(
                            natural: false,
                            .inner,
                            table: .init(stringLiteral: Table.sqliteTableName),
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
        return try decode(Table.self, from: Table.sqliteTableName)
    }
    
    public func decode<D>(_ type: D.Type, from table: String) throws -> D where D: Decodable {
        return try SQLiteRowDecoder().decode(D.self, from: self, table: table)
    }
}

public func ==<Table, Value>(_ lhs: KeyPath<Table, Value>, _ rhs: Value) throws -> SQLiteQuery.Expression
    where Table: SQLiteTable, Value: Encodable
{
    return try .binary(.column(lhs.qualifiedColumnName), .equal, .bind(rhs))
}

public func ==<TableA, ValueA, TableB, ValueB>(
    _ lhs: KeyPath<TableA, ValueA>, _ rhs: KeyPath<TableB, ValueB>
) -> SQLiteQuery.Expression
    where TableA: SQLiteTable, ValueA: Encodable, TableB: SQLiteTable, ValueB: Encodable
{
    return .binary(.column(lhs.qualifiedColumnName), .equal, .column(rhs.qualifiedColumnName))
}

public func !=<Table, Value>(_ lhs: KeyPath<Table, Value>, _ rhs: Value) throws -> SQLiteQuery.Expression
    where Table: SQLiteTable, Value: Encodable
{
    return try .binary(.column(lhs.qualifiedColumnName), .notEqual, .bind(rhs))
}

public protocol SQLiteTable: Codable, Reflectable {
    static var sqliteTableName: String { get }
}

extension KeyPath where Root: SQLiteTable {
    public var qualifiedColumnName: SQLiteQuery.QualifiedColumnName {
        guard let property = try! Root.reflectProperty(forKey: self) else {
            fatalError("Could not reflect property of type \(Value.self) on \(Root.self): \(self)")
        }
        return .init(
            table: Root.sqliteTableName,
            name: .init(property.path[0])
        )
    }
}

extension SQLiteTable {
    public static var sqliteTableName: String {
        return "\(Self.self)"
    }
}

extension SQLiteConnection {
    public func select() -> SQLiteQuery.SelectBuilder {
        return .init(on: self)
    }
}
