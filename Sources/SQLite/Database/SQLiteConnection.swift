#if os(Linux)
import CSQLite
#else
import SQLite3
#endif

/// A connection to a SQLite database, created by `SQLiteDatabase`.
///
///     let conn = try sqliteDB.newConnection(on: ...).wait()
///
/// Use this connection to execute queries on the database.
///
///     try conn.query("SELECT sqlite_version();").wait()
///
/// You can also build queries, using the available query builders.
///
///     let res = try conn.select()
///         .column(function: "sqlite_version", as: "version")
///         .run().wait()
///
public final class SQLiteConnection: BasicWorker, DatabaseConnection, DatabaseQueryable, SQLConnection {
    /// See `DatabaseConnection`.
    public typealias Database = SQLiteDatabase
    
    /// See `DatabaseConnection`.
    public var isClosed: Bool {
        return handle == nil
    }

    /// See `DatabaseConnection`.
    public var extend: Extend

    /// Optional logger, if set queries should be logged to it.
    public var logger: DatabaseLogger?

    /// Reference to parent `SQLiteDatabase` that created this connection.
    /// This reference will ensure the DB stays alive since this connection uses
    /// it's thread pool.
    private let database: SQLiteDatabase

    /// Internal SQLite database handle.
    internal private(set) var handle: OpaquePointer!

    /// See `BasicWorker`.
    public let eventLoop: EventLoop

    /// Create a new SQLite conncetion.
    internal init(database: SQLiteDatabase, on worker: Worker) throws {
        self.extend = [:]
        self.database = database
        self.handle = try database.openConnection()
        self.eventLoop = worker.eventLoop
    }

    /// Returns an identifier for the last inserted row.
    public var lastAutoincrementID: Int64? {
        return sqlite3_last_insert_rowid(handle)
    }
    
    /// Returns the last error message, if one exists.
    internal var errorMessage: String? {
        if let raw = sqlite3_errmsg(handle) {
            return String(cString: raw)
        } else {
            return nil
        }
    }
    
    /// See `SQLConnection`.
    public func decode<D>(_ type: D.Type, from row: [SQLiteColumn: SQLiteData], table: GenericSQLTableIdentifier<SQLiteIdentifier>?) throws -> D where D : Decodable {
        return try SQLiteRowDecoder().decode(D.self, from: row, table: table)
    }
    
    /// Executes the supplied `SQLiteQuery` on the connection, calling the supplied closure for each row returned.
    ///
    ///     try conn.query("SELECT * FROM users") { row in
    ///         print(row)
    ///     }.wait()
    ///
    /// - parameters:
    ///     - query: `SQLiteQuery` to execute.
    ///     - onRow: Callback for handling each row.
    /// - returns: A `Future` that signals completion of the query.
    public func query(_ query: SQLiteQuery, _ onRow: @escaping ([SQLiteColumn: SQLiteData]) throws -> Void) -> Future<Void> {
        var binds: [Encodable] = []
        let sql = query.serialize(&binds)
        let data = try! binds.map(SQLiteDataEncoder().encode)

        // log before anything happens, in case there's an error
        logger?.record(query: sql, values: data.map(String.init(describing:)))

        let promise = eventLoop.newPromise(Void.self)
        database.blockingIO.submit { _ in
            do {
                let statement = try SQLiteStatement(query: sql, on: self)
                try statement.bind(data)
                if let columns = try statement.getColumns() {
                    while let row = try statement.nextRow(for: columns) {
                        self.eventLoop.execute {
                            do {
                                try onRow(row)
                            } catch {
                                promise.fail(error: error)
                            }
                        }
                    }
                }
                self.eventLoop.execute {
                    promise.succeed()
                }
            } catch {
                self.eventLoop.execute {
                    promise.fail(error: error)
                }
            }
        }
        return promise.futureResult
    }
    
    /// See `DatabaseConnection`.
    public func close() {
        sqlite3_close(handle)
        handle = nil
    }
}
