extension SQLiteQuery {
    public struct Select {
        public enum Distinct {
            case distinct
            case all
        }
        
        public enum ResultColumn {
            /// `*` and `table.*`
            case all(String?)
            /// `md5(a) AS hash`
            case expression(Expression, alias: String?)
        }
        
        public var with: With?
        public var distinct: Distinct?
        public var columns: [ResultColumn]
        public var tables: [TableOrSubquery]
    }
}


extension SQLiteSerializer {
    func serialize(_ select: SQLiteQuery.Select, _ binds: inout [SQLiteData]) -> String {
        var sql: [String] = []
        sql.append("SELECT")
        if let with = select.with {
            sql.append(serialize(with, &binds))
        }
        if let distinct = select.distinct {
            sql.append(serialize(distinct))
        }
        sql.append(select.columns.map { serialize($0, &binds) }.joined(separator: ", "))
        if !select.tables.isEmpty {
            sql.append("FROM")
            sql.append(select.tables.map { serialize($0, &binds) }.joined(separator: ", "))
        }
        return sql.joined(separator: " ")
    }
    
    func serialize(_ distinct: SQLiteQuery.Select.Distinct) -> String {
        switch distinct {
        case .all: return "ALL"
        case .distinct: return "DISTINCT"
        }
    }
    
    func serialize(_ distinct: SQLiteQuery.Select.ResultColumn, _ binds: inout [SQLiteData]) -> String {
        switch distinct {
        case .all(let table):
            if let table = table {
                return escapeString(table) + ".*"
            } else {
                return "*"
            }
        case .expression(let expr, let alias):
            if let alias = alias {
                return serialize(expr, &binds) + " AS " + escapeString(alias)
            } else {
                return serialize(expr, &binds)
            }
        }
    }
}
