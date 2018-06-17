public enum SQLiteQuery: SQLQuery {    
    /// See `SQLQuery`.
    public static func createTable(_ createTable: SQLiteCreateTable) -> SQLiteQuery {
        return ._createTable(createTable)
    }
    
    /// See `SQLQuery`.
    public static func delete(_ delete: SQLiteQuery.Delete) -> SQLiteQuery {
        return ._delete(delete)
    }
    
    /// See `SQLQuery`.
    public static func dropTable(_ dropTable: GenericSQLDropTable<TableIdentifier>) -> SQLiteQuery {
        return ._dropTable(dropTable)
    }
    
    /// See `SQLQuery`.
    public static func insert(_ insert: Insert) -> SQLiteQuery {
        return ._insert(insert)
    }
    
    /// See `SQLQuery`.
    public static func select(_ select: Select) -> SQLiteQuery {
        return ._select(select)
    }
    
    /// See `SQLQuery`.
    public static func update(_ update: SQLiteQuery.Update) -> SQLiteQuery {
        return ._update(update)
    }
    
    /// See `SQLQuery`.
    public typealias BinaryOperator = GenericSQLBinaryOperator
    
    /// See `SQLQuery`.
    public typealias Collation = SQLiteCollation
    
    /// See `SQLQuery`.
    public typealias ColumnConstraintAlgorithm = GenericSQLColumnConstraintAlgorithm<Expression, Collation, PrimaryKey, ForeignKey>
    
    /// See `SQLQuery`.
    public typealias ColumnConstraint = GenericSQLColumnConstraint<Identifier, ColumnConstraintAlgorithm>
    
    /// See `SQLQuery`.
    public typealias ColumnDefinition = GenericSQLColumnDefinition<ColumnIdentifier, DataType, ColumnConstraint>
    
    /// See `SQLQuery`.
    public typealias ColumnIdentifier = GenericSQLColumnIdentifier<TableIdentifier, Identifier>
    
    /// See `SQLQuery`.
    public typealias ConflictResolution = GenericSQLConflictResolution
    
    /// See `SQLQuery`.
    public typealias CreateTable = SQLiteCreateTable
    
    /// See `SQLQuery`.
    public typealias DataType = SQLiteDataType
    
    /// See `SQLQuery`.
    public typealias Delete = GenericSQLDelete<TableIdentifier, Expression>
    
    /// See `SQLQuery`.
    public typealias Direction = GenericSQLDirection
    
    /// See `SQLQuery`.
    public typealias Distinct = GenericSQLDistinct
    
    /// See `SQLQuery`.
    public typealias DropTable = GenericSQLDropTable<TableIdentifier>
    
    /// See `SQLQuery`.
    public typealias Expression = GenericSQLExpression<Literal, SQLiteBind, ColumnIdentifier, BinaryOperator, SQLiteFunction, SQLiteQuery>
    
    /// See `SQLQuery`.
    public typealias ForeignKey = GenericSQLForeignKey<TableIdentifier, Identifier, ConflictResolution>
    
    /// See `SQLQuery`.
    public typealias GroupBy = GenericSQLGroupBy<Expression>
    
    /// See `SQLQuery`.
    public typealias Identifier = GenericSQLIdentifier
    
    /// See `SQLQuery`.
    public typealias Insert = GenericSQLInsert<TableIdentifier, ColumnIdentifier, Expression>
    
    /// See `SQLQuery`.
    public typealias Literal = GenericSQLLiteral
    
    /// See `SQLQuery`.
    public typealias OrderBy = GenericSQLOrderBy<Expression, Direction>
    
    /// See `SQLQuery`.
    public typealias PrimaryKey = SQLitePrimaryKey
    
    /// See `SQLQuery`.
    public typealias Select = GenericSQLSelect<Distinct, SelectExpression, TableIdentifier, Expression, GroupBy, OrderBy>
    
    /// See `SQLQuery`.
    public typealias SelectExpression = GenericSQLSelectExpression<Expression>
    
    /// See `SQLQuery`.
    public typealias TableConstraintAlgorithm = GenericSQLTableConstraintAlgorithm<ColumnIdentifier, Expression, Collation, PrimaryKey, ForeignKey>
    
    /// See `SQLQuery`.
    public typealias TableConstraint = GenericSQLTableConstraint<Identifier, TableConstraintAlgorithm>
    
    /// See `SQLQuery`.
    public typealias TableIdentifier = GenericSQLTableIdentifier<Identifier>
    
    /// See `SQLQuery`.
    public typealias Update = GenericSQLUpdate<TableIdentifier, Identifier, Expression>
    
    /// See `SQLQuery`.
    public typealias RowDecoder = SQLiteRowDecoder
    
    /// See `SQLQuery`.
//    case alterTable(AlterTable)
    
    /// See `SQLQuery`.
    case _createTable(SQLiteCreateTable)
    
    /// See `SQLQuery`.
    case _delete(Delete)
    
    /// See `SQLQuery`.
    case _dropTable(DropTable)
    
    /// See `SQLQuery`.
    case _insert(Insert)
    
    /// See `SQLQuery`.
    case _select(Select)
    
    /// See `SQLQuery`.
    case _update(Update)
    
    /// See `SQLQuery`.
    case _raw(String, [Encodable])
    
    /// See `SQLSerializable`.
    public func serialize(_ binds: inout [Encodable]) -> String {
        switch self {
        case ._createTable(let createTable): return createTable.serialize(&binds)
        case ._delete(let delete): return delete.serialize(&binds)
        case ._dropTable(let dropTable): return dropTable.serialize(&binds)
        case ._insert(let insert): return insert.serialize(&binds)
        case ._select(let select): return select.serialize(&binds)
        case ._update(let update): return update.serialize(&binds)
        case ._raw(let sql, let values):
            binds = values
            return sql
        }
    }
}

extension SQLiteQuery: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self = ._raw(value, [])
    }
}
