extension SQLiteQuery {
    public final class SelectBuilder {
        var select: Select {
            didSet {
                print("SELECT:")
                print(select)
                print()
                print()
                print()
            }
        }
        var connection: SQLiteConnection
        init(on connection: SQLiteConnection) {
            self.select = .init()
            self.connection = connection
        }
        
        public func columns(_ columns: Select.ResultColumn...) -> Self {
            select.columns += columns
            return self
        }
        
        public func from(_ tables: TableOrSubquery...) -> Self {
            select.tables += tables
            return self
        }
        
        public func from<Table>(_ table: Table.Type) -> Self where Table: SQLiteTable {
            select.tables.append(.table(schema: nil, name: Table.sqliteTableName, alias: nil, nil))
            return self
        }
        
        public func `where`(_ expressions: Expression...) -> Self {
            for expression in expressions {
                select.predicate &= expression
            }
            return self
        }
        
        @discardableResult
        public func `where`(or expressions: Expression...) -> Self {
            for expression in expressions {
                select.predicate |= expression
            }
            return self
        }
        
        public func `where`(group: (SelectBuilder) throws -> ()) rethrows -> Self {
            let builder = SelectBuilder(on: connection)
            try group(builder)
            switch (select.predicate, builder.select.predicate) {
            case (.some(let a), .some(let b)):
                select.predicate = a && .expressions([b])
            case (.none, .some(let b)):
                select.predicate = .expressions([b])
            case (.some, .none), (.none, .none): break
            }
            return self
        }
        
        public func all<D>(_ type: D.Type) -> Future<[D]>
            where D: Decodable
        {
            return all().map { try $0.map { try SQLiteRowDecoder().decode(D.self, from: $0) } }
        }
        
        public func all() -> Future<[[SQLiteColumn: SQLiteData]]> {
            return connection.query(.select(select))
        }
    }
}

public func ==<Table, Value>(_ lhs: KeyPath<Table, Value>, _ rhs: Value) throws -> SQLiteQuery.Expression
    where Table: SQLiteTable, Value: Encodable
{
    return try _binary(.equal, lhs, rhs)
}

public func !=<Table, Value>(_ lhs: KeyPath<Table, Value>, _ rhs: Value) throws -> SQLiteQuery.Expression
    where Table: SQLiteTable, Value: Encodable
{
    return try _binary(.notEqual, lhs, rhs)
}

private func _binary<Table, Value>(
    _ op: SQLiteQuery.Expression.BinaryOperator,
    _ lhs: KeyPath<Table, Value>,
    _ rhs: Value
) throws -> SQLiteQuery.Expression
    where Table: SQLiteTable, Value: Encodable
{
    guard let property = try Table.reflectProperty(forKey: lhs) else {
        fatalError()
    }
    let column: SQLiteQuery.Expression = .column(.init(table: Table.sqliteTableName, name: property.path[0]))
    return try .binary(column, op, .bind(rhs))
}

public protocol SQLiteTable: Codable, Reflectable {
    static var sqliteTableName: String { get }
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
