public protocol SQLQuery: SQLSerializable {
    associatedtype CreateTable: SQLCreateTable
    associatedtype Delete: SQLDelete
    associatedtype DropTable: SQLDropTable
    associatedtype Insert: SQLInsert
    associatedtype Select: SQLSelect
    associatedtype Update: SQLUpdate
    
    associatedtype RowDecoder: SQLRowDecoder
    
    static func createTable(_ createTable: CreateTable) -> Self
    static func delete(_ delete: Delete) -> Self 
    static func dropTable(_ dropTable: DropTable) -> Self
    static func insert(_ insert: Insert) -> Self
    static func select(_ select: Select) -> Self
    static func update(_ update: Update) -> Self
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
//public func `as`(_ closure: (SQLiteConnection) -> SelectBuilder) -> Self {
//    create.schemaSource = .select(closure(connection).select)
//    return self
//}
//
