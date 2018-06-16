extension SQLiteQuery {
    /// Builds `CreateTable` queries.
    public final class CreateTableBuilder<Table> where Table: SQLiteTable {
        /// Query being built.
        public var create: CreateTable
        
        /// Database connection to execute the query on.
        public let connection: SQLiteConnection
        
        /// Creates a new `CreateTableBuilder`.
        ///
        /// - parameters:
        ///     - table: Name of existing table to create.
        ///     - connection: `SQLiteConnection` to perform the query on.
        init(table: Table.Type, on connection: SQLiteConnection) {
            self.create = .init(table: Table.sqliteTableName, schemaSource: .definition(.init(columns: [])))
            self.connection = connection
        }
        
        /// If the "TEMP" or "TEMPORARY" keyword occurs between the "CREATE" and "TABLE" then the new table is created in the temp database.
        public func temporary() -> Self {
            create.temporary = true
            return self
        }
        
        /// It is usually an error to attempt to create a new table in a database that already contains a table, index or view of the
        /// same name. However, if the "IF NOT EXISTS" clause is specified as part of the CREATE TABLE statement and a table or view
        /// of the same name already exists, the CREATE TABLE command simply has no effect (and no error message is returned). An
        /// error is still returned if the table cannot be created because of an existing index, even if the "IF NOT EXISTS" clause is
        /// specified.
        public func ifNotExists() -> Self {
            create.ifNotExists = true
            return self
        }
        
        /// Adds a column to the table.
        ///
        ///     conn.create(table: Planet.self).column(for: \.name, type: .text, .notNull).run()
        ///
        /// - parameters:
        ///     - keyPath: Swift `KeyPath` to property that should be added.
        ///     - type: Name of type to use for this column.
        ///     - constraints: Zero or more column constraints to add.
        /// - returns: Self for chaining.
        public func column<Value>(
            for keyPath: KeyPath<Table, Value>,
            type typeName: TypeName,
            _ constraints: SQLiteQuery.ColumnConstraint...
        ) -> Self {
            return column(.init(
                name: keyPath.sqliteColumnName.name,
                typeName: typeName,
                constraints: constraints
            ))
        }
        /// Adds a column to the table.
        ///
        ///     conn.create(table: Planet.self).column(...).run()
        ///
        /// - parameters:
        ///     - columnDefinition: Column definition to add.
        /// - returns: Self for chaining.
        public func column(_ columnDefinition: ColumnDefinition) -> Self {
            schemaDefinition.columns.append(columnDefinition)
            return self
        }
        
        /// By default, every row in SQLite has a special column, usually called the "rowid", that uniquely identifies that row within
        /// the table. However if the phrase "WITHOUT ROWID" is added to the end of a CREATE TABLE statement, then the special "rowid"
        /// column is omitted. There are sometimes space and performance advantages to omitting the rowid.
        ///
        /// https://www.sqlite.org/withoutrowid.html
        public func withoutRowID() -> Self {
            schemaDefinition.withoutRowID = true
            return self
        }
        
        /// A `CREATE TABLE ... AS SELECT` statement creates and populates a database table based on the results of a SELECT statement.
        /// The table has the same number of columns as the rows returned by the SELECT statement. The name of each column is the same
        /// as the name of the corresponding column in the result set of the SELECT statement.
        ///
        ///     conn.create(table: GalaxyCopy.self).as { $0.select().all().from(Galaxy.self) }.run()
        ///
        /// - parameters:
        ///     - closure: Closure accepting a `SQLiteConnection` and returning a `SelectBuilder`.
        /// - returns: Self for chaining.
        public func `as`(_ closure: (SQLiteConnection) -> SelectBuilder) -> Self {
            create.schemaSource = .select(closure(connection).select)
            return self
        }
        
        // TODO: Support adding table constraints.
        
        /// Runs the `CREATE` query.
        ///
        /// - returns: A `Future` that signals completion.
        public func run() -> Future<Void> {
            return connection.query(.createTable(create)).transform(to: ())
        }
        
        // MARK: Private
        
        /// Convenience accessor for setting schema.
        private var schemaDefinition: CreateTable.SchemaDefinition {
            get {
                switch create.schemaSource {
                case .definition(let definition): return definition
                case .select: return .init(columns: [])
                }
            }
            set {
                create.schemaSource = .definition(newValue)
            }
        }
    }
}

extension SQLiteConnection {
    /// Creates a new `CreateTableBuilder`.
    ///
    ///     conn.create(table: Planet.self)...
    ///
    /// - parameters:
    ///     - table: Table to create.
    /// - returns: `CreateTableBuilder`.
    public func create<Table>(table: Table.Type) -> SQLiteQuery.CreateTableBuilder<Table>
        where Table: SQLiteTable
    {
        return .init(table: Table.self, on: self)
    }
}
