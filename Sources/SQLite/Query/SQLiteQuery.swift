public enum SQLiteQuery {
    case insert(Insert)
    case select(Select)
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
                case using([Column])
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
        case .select(let select): return serialize(select, &binds)
        case .insert(let insert): return serialize(insert, &binds)
        }
    }
}
