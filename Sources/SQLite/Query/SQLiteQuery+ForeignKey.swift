extension SQLiteQuery {
    public struct ForeignKey {
        public enum Action {
            case setNull
            case setDefault
            case cascade
            case restrict
            case noAction
        }
        
        public enum Deferrence {
            case not
            case immediate
        }
        
        public struct Reference {
            public var foreignTable: TableName
            public var foreignColumns: [Name]
            public var onDelete: Action?
            public var onUpdate: Action?
            public var deferrence: Deferrence?
            
            public init(
                foreignTable: TableName,
                foreignColumns: [Name],
                onDelete: Action? = nil,
                onUpdate: Action? = nil,
                deferrence: Deferrence? = nil
            ) {
                self.foreignTable = foreignTable
                self.foreignColumns = foreignColumns
                self.onDelete = onDelete
                self.onUpdate = onUpdate
                self.deferrence = deferrence
            }
        }
        
        public var columns: [Name]
        public var reference: Reference
        
        public init(columns: [Name], reference: Reference) {
            self.columns = columns
            self.reference = reference
        }
    }
}

extension SQLiteSerializer {
    func serialize(_ foreignKey: SQLiteQuery.ForeignKey) -> String {
        var sql: [String] = []
        sql.append("FOREIGN KEY")
        sql.append(serialize(foreignKey.columns))
        sql.append(serialize(foreignKey.reference))
        return sql.joined(separator: " ")
    }
    
    func serialize(_ foreignKey: SQLiteQuery.ForeignKey.Reference) -> String {
        var sql: [String] = []
        sql.append("REFERENCES")
        sql.append(serialize(foreignKey.foreignTable))
        if !foreignKey.foreignColumns.isEmpty {
            sql.append(serialize(foreignKey.foreignColumns))
        }
        if let onDelete = foreignKey.onDelete {
            sql.append("ON DELETE")
            sql.append(serialize(onDelete))
        }
        if let onUpdate = foreignKey.onUpdate {
            sql.append("ON UPDATE")
            sql.append(serialize(onUpdate))
        }
        if let deferrence = foreignKey.deferrence {
            sql.append(serialize(deferrence))
        }
        return sql.joined(separator: " ")
    }
    
    func serialize(_ action: SQLiteQuery.ForeignKey.Action) -> String {
        switch action {
        case .cascade: return "CASCADE"
        case .noAction: return "NO ACTION"
        case .restrict: return "RESTRICT"
        case .setDefault: return "SET DEFAULT"
        case .setNull: return "SET NULL"
        }
    }
    
    func serialize(_ deferrence: SQLiteQuery.ForeignKey.Deferrence) -> String {
        switch deferrence {
        case .not: return "NOT DEFERRABLE"
        case .immediate: return "DEFERRABLE INITIALLY IMMEDIATE"
        }
    }
}
