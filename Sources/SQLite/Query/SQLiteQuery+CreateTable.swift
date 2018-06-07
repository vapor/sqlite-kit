extension SQLiteQuery {
    public struct ForeignKey {
        public var foreignTable: TableName
        public var columns: String
    }
    public struct ColumnConstraint {
        public enum Constraint {
            public struct PrimaryKey {
                public var direction: Direction?
                public var conflictResolution: ConflictResolution?
                public var autoincrement: Bool
            }
            
            public struct Nullability {
                public var allowNull: Bool
                public var conflictResolution: ConflictResolution?
            }
            
            public struct Unique {
                public var conflictResolution: ConflictResolution?
            }
            
            public enum Default {
                case literal(Expression.Literal)
                case expression(Expression)
            }
            
            case primaryKey(PrimaryKey)
            case nullability(Nullability)
            case unique(Unique)
            case check(Expression)
            case `default`(Default)
            case collate(String)
            
        }
        public var name: String?
        public var constraint: Constraint
    }
    
    public struct ColumnDefinition {
        public var name: String
        public var typeName: TypeName?
        public var constraints: [ColumnConstraint]
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
