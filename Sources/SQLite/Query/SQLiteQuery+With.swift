extension SQLiteQuery {
    public struct With {
        public struct CommonTableExpression {
            public var table: String
            public var columns: [String]
            public var select: Select
        }
        
        public var recursive: Bool
        public var expressions: [CommonTableExpression]
    }
    
}

extension SQLiteSerializer {
    func serialize(_ with: SQLiteQuery.With, _ binds: inout [SQLiteData]) -> String {
        var sql: [String] = []
        sql.append("WITH")
        if with.recursive {
            sql.append("RECURSIVE")
        }
        sql.append(with.expressions.map { serialize($0, &binds) }.joined(separator: ", "))
        return sql.joined(separator: " ")
    }
    
    func serialize(_ with: SQLiteQuery.With.CommonTableExpression, _ binds: inout [SQLiteData]) -> String {
        return "FOO"
    }
}
