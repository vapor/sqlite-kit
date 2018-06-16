extension SQLiteQuery {
    /// The `CREATE TABLE` command is used to create a new table in an SQLite database.
    ///
    /// https://www.sqlite.org/lang_createtable.html
    public struct CreateTable {
        /// A collection of columns and constraints defining a table.
        public struct SchemaDefinition {
            /// Columns to create.
            public var columns: [ColumnDefinition]
            
            /// Table constraints (different from column constraints) to create.
            public var tableConstraints: [TableConstraint]
            
            /// By default, every row in SQLite has a special column, usually called the "rowid", that uniquely identifies that row within
            /// the table. However if the phrase "WITHOUT ROWID" is added to the end of a CREATE TABLE statement, then the special "rowid"
            /// column is omitted. There are sometimes space and performance advantages to omitting the rowid.
            ///
            /// https://www.sqlite.org/withoutrowid.html
            public var withoutRowID: Bool
            
            /// Creates a new `CreateTable`.
            ///
            /// - parameters:
            ///     - columns: Columns to create.
            ///     - tableConstraints: Table constraints (different from column constraints) to create.
            ///     - withoutRowID: See `withoutRowID`.
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
        
        /// Source for table schema. Either a definition or the results of a `SELECT` statement.
        public enum SchemaSource {
            /// A collection of columns and constraints defining a table.
            case definition(SchemaDefinition)
            /// The results of a `SELECT` statement.
            case select(Select)
        }
        
        /// If the "TEMP" or "TEMPORARY" keyword occurs between the "CREATE" and "TABLE" then the new table is created in the temp database.
        public var temporary: Bool
        
        /// It is usually an error to attempt to create a new table in a database that already contains a table, index or view of the
        /// same name. However, if the "IF NOT EXISTS" clause is specified as part of the CREATE TABLE statement and a table or view
        /// of the same name already exists, the CREATE TABLE command simply has no effect (and no error message is returned). An
        /// error is still returned if the table cannot be created because of an existing index, even if the "IF NOT EXISTS" clause is
        /// specified.
        public var ifNotExists: Bool
        
        /// Name of the table to create.
        public var table: TableName
        
        /// Source of the schema information.
        public var schemaSource: SchemaSource
        
        /// Creates a new `CreateTable` query.
        public init(
            temporary: Bool = false,
            ifNotExists: Bool = false,
            table: TableName,
            schemaSource: SchemaSource
        ) {
            self.temporary = temporary
            self.ifNotExists = ifNotExists
            self.table = table
            self.schemaSource = schemaSource
        }
    }
}

extension SQLiteSerializer {
    func serialize(_ create: SQLiteQuery.CreateTable, _ binds: inout [SQLiteData]) -> String {
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
        sql.append(serialize(create.schemaSource, &binds))
        return sql.joined(separator: " ")
    }
    
    func serialize(_ source: SQLiteQuery.CreateTable.SchemaSource, _ binds: inout [SQLiteData]) -> String {
        switch source {
        case .definition(let schema): return serialize(schema, &binds)
        case .select(let select): return "AS " + serialize(select, &binds)
        }
    }
    func serialize(_ schema: SQLiteQuery.CreateTable.SchemaDefinition, _ binds: inout [SQLiteData]) -> String {
        var sql: [String] = []
        sql.append("(" + (
            schema.columns.map { serialize($0, &binds) } + schema.tableConstraints.map { serialize($0, &binds) }
        ).joined(separator: ", ") + ")")
        if schema.withoutRowID {
            sql.append("WITHOUT ROWID")
        }
        return sql.joined(separator: " ")
    }
}
