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
    
    /// Thread pool for performing blocking IO work. See `BlockingIOThreadPool`.
    internal let blockingIO: BlockingIOThreadPool
    
    /// Create a new SQLite database.
    ///
    ///     let sqliteDB = SQLiteDatabase(storage: .memory)
    ///
    /// - parameters:
    ///     - storage: SQLite storage method. See `SQLiteStorage`.
    ///     - threadPool: Thread pool for performing blocking IO work. See `BlockingIOThreadPool`.
    /// - throws: Errors creating the SQLite database.
    public init(storage: SQLiteStorage = .memory, threadPool: BlockingIOThreadPool? = nil) throws {
        self.storage = storage
        self.blockingIO = threadPool ?? BlockingIOThreadPool(numberOfThreads: 2)
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
