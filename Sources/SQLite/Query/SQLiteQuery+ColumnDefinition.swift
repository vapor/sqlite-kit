extension SQLiteQuery {
    public struct ColumnDefinition {
        public var name: ColumnName
        public var typeName: TypeName?
        public var constraints: [ColumnConstraint]
    }
}

extension SQLiteSerializer {
    func serialize(_ columnDefinition: SQLiteQuery.ColumnDefinition, _ binds: inout [SQLiteData]) -> String {
        var sql: [String] = []
        sql.append(serialize(columnDefinition.name))
        if let typeName = columnDefinition.typeName {
            sql.append(serialize(typeName))
        }
        sql += columnDefinition.constraints.map { serialize($0, &binds) }
        return sql.joined(separator: " ")
    }
}
