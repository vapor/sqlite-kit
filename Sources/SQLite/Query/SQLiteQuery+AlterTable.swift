extension SQLiteQuery {
    public struct AlterTable {
        public enum Value {
            case rename(String)
            case addColumn(ColumnDefinition)
        }
        
        public var table: TableName
        public var value: Value
        
        public init(table: TableName, value: Value) {
            self.table = table
            self.value = value
        }
    }
}

extension SQLiteSerializer {
    func serialize(_ alter: SQLiteQuery.AlterTable, _ binds: inout [SQLiteData]) -> String {
        var sql: [String] = []
        sql.append("ALTER TABLE")
        sql.append(serialize(alter.table))
        sql.append(serialize(alter.value, &binds))
        return sql.joined(separator: " ")
    }
    
    func serialize(_ value: SQLiteQuery.AlterTable.Value, _ binds: inout [SQLiteData]) -> String {
        var sql: [String] = []
        switch value {
        case .rename(let name):
            sql.append("RENAME TO")
            sql.append(escapeString(name))
        case .addColumn(let columnDefinition):
            sql.append("ADD")
            sql.append(serialize(columnDefinition, &binds))
        }
        return sql.joined(separator: " ")
    }
}
