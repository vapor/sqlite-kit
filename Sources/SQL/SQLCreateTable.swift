public protocol SQLCreateTable: SQLSerializable {
    associatedtype Query: SQLQuery
    
    static func createTable(_ table: Query.TableIdentifier) -> Self
    
    /// If the "TEMP" or "TEMPORARY" keyword occurs between the "CREATE" and "TABLE" then the new table is created in the temp database.
    var temporary: Bool { get set }
    
    /// It is usually an error to attempt to create a new table in a database that already contains a table, index or view of the
    /// same name. However, if the "IF NOT EXISTS" clause is specified as part of the CREATE TABLE statement and a table or view
    /// of the same name already exists, the CREATE TABLE command simply has no effect (and no error message is returned). An
    /// error is still returned if the table cannot be created because of an existing index, even if the "IF NOT EXISTS" clause is
    /// specified.
    var ifNotExists: Bool { get set }
    
    var table: TableIdentifier { get set }
    var columns: [ColumnDefinition] { get set }
    var tableConstraints: [TableConstraint] { get set }
}

/// The `CREATE TABLE` command is used to create a new table in a database.
public struct GenericSQLCreateTable<Query>: SQLCreateTable where Query: SQLQuery {
    public typealias `Self` = GenericSQLCreateTable<Query>
    
    /// See `SQLCreateTable`.
    public static func createTable(_ table: Query.TableIdentifier) -> Self {
        return .init(temporary: false, ifNotExists: false, table: table, columns: [], tableConstraints: [])
    }
    
    /// See `SQLCreateTable`.
    public var temporary: Bool
    
    /// See `SQLCreateTable`.
    public var ifNotExists: Bool
    
    /// See `SQLCreateTable`.
    public var table: Query.TableIdentifier
    
    /// See `SQLCreateTable`.
    public var columns: [Query.ColumnDefinition]
    
    /// See `SQLCreateTable`.
    public var tableConstraints: [Query.TableConstraint]
    
    /// See `SQLSerializable`.
    public func serialize(_ binds: inout [Encodable]) -> String {
        var sql: [String] = []
        sql.append("CREATE")
        if temporary {
            sql.append("TEMPORARY")
        }
        sql.append("TABLE")
        if ifNotExists {
            sql.append("IF NOT EXISTS")
        }
        sql.append(table.serialize(&binds))
        sql.append("(" + columns.serialize(&binds) + tableConstraints.serialize(&binds) + ")")
        return sql.joined(separator: " ")
    }
}
