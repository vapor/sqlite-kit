public enum SQLiteQuery {
    case alterTable(AlterTable)
    case createTable(CreateTable)
    case delete(Delete)
    case dropTable(DropTable)
    case insert(Insert)
    case select(Select)
    case update(Update)
}

extension SQLiteSerializer {
    func serialize(_ query: SQLiteQuery, _ binds: inout [SQLiteData]) -> String {
        switch query {
        case .alterTable(let alterTable): return serialize(alterTable, &binds)
        case .createTable(let createTable): return serialize(createTable, &binds)
        case .delete(let delete): return serialize(delete, &binds)
        case .dropTable(let dropTable): return serialize(dropTable)
        case .select(let select): return serialize(select, &binds)
        case .insert(let insert): return serialize(insert, &binds)
        case .update(let update): return serialize(update, &binds)
        }
    }
}
