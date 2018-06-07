public enum SQLiteQuery {
    case alterTable(AlterTable)
    case createTable(CreateTable)
    case delete(Delete)
    case dropTable(DropTable)
    case insert(Insert)
    case select(Select)
    case update(Update)
}

extension SQLiteQuery {
    public struct JoinClause {
        public struct Join {
            public enum Operator {
                case left(outer: Bool)
                case inner
                case cross
                
            }
            
            public enum Constraint {
                case condition(Expression)
                case using([ColumnName])
            }
            
            public var natrual: Bool
            public var op: Operator?
            public var table: TableOrSubquery
            public var constraint: Constraint?
        }
        public var table: TableOrSubquery
        public var joins: [Join]
    }
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
