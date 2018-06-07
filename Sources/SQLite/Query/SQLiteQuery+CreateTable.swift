extension SQLiteQuery {
    public struct ColumnDefinition {
        
    }
    
    public struct TableConstraint {
        
    }
    
    public struct CreateTable {
        public struct Schema {
            public var columns: [ColumnDefinition]
            public var tableConstraints: [TableConstraint]
            public var withoutRowID: Bool
            
            public init(
                columns: [ColumnDefinition],
                tableConstraints: [TableConstraint] = [],
                withoutRowID: Bool = false
            ) {
                self.columns = columns
                self.tableConstraints = tableConstraints
                self.withoutRowID = withoutRowID
            }
        }
        
        public enum Source {
            case schema(Schema)
            case select(Select)
        }
        
        public var temporary: Bool
        public var ifNotExists: Bool
        // FIXME: table name should not support alias
        public var table: TableName
        public var source: Source
        
        public init(
            temporary: Bool = false,
            ifNotExists: Bool = false,
            table: TableName,
            source: Source
        ) {
            self.temporary = temporary
            self.ifNotExists = ifNotExists
            self.table = table
            self.source = source
        }
    }
}

extension SQLiteSerializer {
    func serialize(_ create: SQLiteQuery.CreateTable) -> String {
        var sql: [String] = []
        sql.append("CREATE")
        if create.temporary {
            sql.append("TEMP")
        }
        sql.append("TABLE")
        if create.ifNotExists {
            sql.append("IF NOT EXISTS")
        }
        sql.append(serialize(create.table))
        
        return sql.joined(separator: " ")
    }
}
