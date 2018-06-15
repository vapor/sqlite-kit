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
    
    /// Internal SQLite database handle.
    internal let handle: OpaquePointer

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
        self.blockingIO.start()
        // make connection
        let options = SQLITE_OPEN_CREATE | SQLITE_OPEN_READWRITE | SQLITE_OPEN_FULLMUTEX
        var handle: OpaquePointer?
        guard sqlite3_open_v2(self.storage.path, &handle, options, nil) == SQLITE_OK, let c = handle else {
            throw SQLiteError(problem: .error, reason: "Could not open database.", source: .capture())
        }
        self.handle = c
    }

    /// See `Database`.
    public func newConnection(on worker: Worker) -> Future<SQLiteConnection> {
        let conn = SQLiteConnection(database: self, on: worker)
        return worker.future(conn)
    }

    /// See `LogSupporting`.
    public static func enableLogging(_ logger: DatabaseLogger, on conn: SQLiteConnection) {
        conn.logger = logger
    }
    
    /// Closes the open SQLite handle on deinit.
    deinit {
        sqlite3_close(handle)
        self.blockingIO.shutdownGracefully { error in
            if let error = error {
                print("[SQLite] [ERROR] Could not shutdown BlockingIOThreadPool: \(error)")
            }
        }
    }
}
