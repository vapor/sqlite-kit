#if os(Linux)
import CSQLite
#else
import SQLite3
#endif

/// An open SQLite database using in-memory or file-based storage.
///
///     let sqliteDB = SQLiteDatabase(storage: .memory)
///
/// Use this database to create new connections for executing queries.
///
///     let conn = try sqliteDB.newConnection(on: ...).wait()
///     try conn.query("SELECT sqlite_version();").wait()
///
public final class SQLiteDatabase: Database, LogSupporting {
    /// SQLite storage method. See `SQLiteStorage`.
    public let storage: SQLiteStorage
    
    /// Dispatch queue for performing blocking IO work. See `DispatchQueue`.
    internal let queue: DispatchQueue
    
    /// Create a new SQLite database.
    ///
    ///     let sqliteDB = SQLiteDatabase(storage: .memory)
    ///
    /// - parameters:
    ///     - storage: SQLite storage method. See `SQLiteStorage`.
    ///     - queue: Dispatch queue for performing blocking IO work. See `DispatchQueue`.
    /// - throws: Errors creating the SQLite database.
    public init(storage: SQLiteStorage = .memory, queue: DispatchQueue = DispatchQueue(label: "SQLite Database Queue", attributes: .concurrent)) throws {
        self.storage = storage
        self.queue = queue
    }
    
    /// See `Database`.
    public func newConnection(on worker: Worker) -> Future<SQLiteConnection> {
        do {
            let conn = try SQLiteConnection(database: self, on: worker)
            return worker.future(conn)
        } catch {
            return worker.future(error: error)
        }
    }
    
    /// See `LogSupporting`.
    public static func enableLogging(_ logger: DatabaseLogger, on conn: SQLiteConnection) {
        conn.logger = logger
    }
}
