/// SQLite specific `SQLQuery`.
public enum SQLiteQuery: SQLQuery {
    /// See `SQLQuery`.
    public typealias AlterTable = SQLiteAlterTable
    
    /// See `SQLQuery`.
    public typealias CreateIndex = SQLiteCreateIndex

    /// See `SQLQuery`.
    public typealias CreateTable = SQLiteCreateTable

    /// See `SQLQuery`.
    public typealias Delete = SQLiteDelete

    /// See `SQLQuery`.
    public typealias DropIndex = SQLiteDropIndex
    
    /// See `SQLQuery`.
    public typealias DropTable = SQLiteDropTable

    /// See `SQLQuery`.
    public typealias Insert = SQLiteInsert

    /// See `SQLQuery`.
    public typealias Select = SQLiteSelect

    /// See `SQLQuery`.
    public typealias Update = SQLiteUpdate

    /// See `SQLQuery`.
    public typealias RowDecoder = SQLiteRowDecoder

    /// See `SQLQuery`.
    public static func alterTable(_ alterTable: SQLiteAlterTable) -> SQLiteQuery {
        return ._alterTable(alterTable)
    }
    
    /// See `SQLQuery`.
    public static func createIndex(_ createIndex: SQLiteCreateIndex) -> SQLiteQuery {
        return ._createIndex(createIndex)
    }

    /// See `SQLQuery`.
    public static func createTable(_ createTable: SQLiteCreateTable) -> SQLiteQuery {
        return ._createTable(createTable)
    }
    
    /// See `SQLQuery`.
    public static func delete(_ delete: SQLiteDelete) -> SQLiteQuery {
        return ._delete(delete)
    }
    
    /// See `SQLQuery`.
    public static func dropIndex(_ dropIndex: SQLiteDropIndex) -> SQLiteQuery {
        return ._dropIndex(dropIndex)
    }
    
    /// See `SQLQuery`.
    public static func dropTable(_ dropTable: SQLiteDropTable) -> SQLiteQuery {
        return ._dropTable(dropTable)
    }
    
    /// See `SQLQuery`.
    public static func insert(_ insert: SQLiteInsert) -> SQLiteQuery {
        return ._insert(insert)
    }
    
    /// See `SQLQuery`.
    public static func select(_ select: SQLiteSelect) -> SQLiteQuery {
        return ._select(select)
    }
    
    /// See `SQLQuery`.
    public static func update(_ update: SQLiteUpdate) -> SQLiteQuery {
        return ._update(update)
    }

    /// See `SQLQuery`.
    public static func raw(_ sql: String, binds: [Encodable]) -> SQLiteQuery {
        return ._raw(sql, binds)
    }
    
    /// See `SQLQuery`.
    case _alterTable(SQLiteAlterTable)
    
    /// See `SQLQuery`.
    case _createIndex(SQLiteCreateIndex)

    /// See `SQLQuery`.
    case _createTable(SQLiteCreateTable)
    
    /// See `SQLQuery`.
    case _delete(SQLiteDelete)
    
    /// See `SQLQuery`.
    case _dropIndex(SQLiteDropIndex)
    
    /// See `SQLQuery`.
    case _dropTable(SQLiteDropTable)
    
    /// See `SQLQuery`.
    case _insert(SQLiteInsert)
    
    /// See `SQLQuery`.
    case _select(SQLiteSelect)
    
    /// See `SQLQuery`.
    case _update(SQLiteUpdate)
    
    /// See `SQLQuery`.
    case _raw(String, [Encodable])
    
    /// See `SQLSerializable`.
    public func serialize(_ binds: inout [Encodable]) -> String {
        switch self {
        case ._alterTable(let alterTable): return alterTable.serialize(&binds)
        case ._createIndex(let createIndex): return createIndex.serialize(&binds)
        case ._createTable(let createTable): return createTable.serialize(&binds)
        case ._delete(let delete): return delete.serialize(&binds)
        case ._dropIndex(let dropIndex): return dropIndex.serialize(&binds)
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
    /// See `ExpressibleByStringLiteral`.
    public init(stringLiteral value: String) {
        self = ._raw(value, [])
    }
}
