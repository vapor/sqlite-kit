extension SQLiteQuery {
    public indirect enum TableOrSubquery {
        public enum TableIndex {
            case indexed(String)
            case notIndexed
        }
        
        case table(schema: String?, name: String, alias: String?, TableIndex?)
        case tableFunction(schemaName: String?, name: String, parameters: [Expression], alias: String?)
        case joinClause(JoinClause)
        case tables([TableOrSubquery])
        case subQuery(Select, alias: String?)
    }
}

extension SQLiteQuery.TableOrSubquery: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self = .table(schema: nil, name: value, alias: nil, nil)
    }
}

extension SQLiteSerializer {
    func serialize(_ table: SQLiteQuery.TableOrSubquery, _ binds: inout [SQLiteData]) -> String {
        var sql: [String] = []
        switch table {
        case .table(let schema, let name, let alias, let index):
            if let schema = schema {
                sql.append(escapeString(schema) + "." + escapeString(name))
            } else {
                sql.append(escapeString(name))
            }
            if let alias = alias {
                sql.append("AS")
                sql.append(escapeString(alias))
            }
            if let index = index {
                sql.append(serialize(index))
            }
        default: return "\(table)"
        }
        return sql.joined(separator: " ")
    }
    
    func serialize(_ index: SQLiteQuery.TableOrSubquery.TableIndex) -> String {
        return "\(index)"
    }
}
