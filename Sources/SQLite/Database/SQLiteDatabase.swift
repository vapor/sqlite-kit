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
    
    /// If the database uses in-memory storage, this property will be set to
    /// keep the database alive when there is no `SQLiteConnection` to it.
    private var handle: OpaquePointer?

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
        if case .memory = storage {
            self.handle = try openConnection()
        }
    }

    // Make database connection
    internal func openConnection() throws -> OpaquePointer {
        let path: String
        switch storage {
        case .memory:
            path = "file:\(ObjectIdentifier(self))?mode=memory&cache=shared"
        case .file(let file):
            path = file
        }
        var handle: OpaquePointer?
        let options = SQLITE_OPEN_CREATE | SQLITE_OPEN_READWRITE | SQLITE_OPEN_FULLMUTEX
        guard sqlite3_open_v2(path, &handle, options, nil) == SQLITE_OK,
            let c = handle,
            sqlite3_busy_handler(c, { _, _ in 1 }, nil) == SQLITE_OK else {
                throw SQLiteError(problem: .error, reason: "Could not open database.", source: .capture())
        }
        return c
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
    
    deinit {
        self.blockingIO.shutdownGracefully { [handle] error in
            if let error = error {
                print("[SQLite] [ERROR] Could not shutdown BlockingIOThreadPool: \(error)")
            }
            if let handle = handle, sqlite3_close(handle) != SQLITE_OK {
                print("[SQLite] [ERROR] Could not close database.")
            }
        }
    }
}
