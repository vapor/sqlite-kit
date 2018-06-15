#if os(Linux)
import CSQLite
#else
import SQLite3
#endif

/// SQlite database. Used to make connections.
public final class SQLiteDatabase: Database, LogSupporting {
    /// The path to the SQLite file.
    public let storage: SQLiteStorage
    
    internal let blockingIO: BlockingIOThreadPool
    
    internal let handle: OpaquePointer

    /// Create a new SQLite database.
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
    
    deinit {
        sqlite3_close(handle)
        self.blockingIO.shutdownGracefully { error in
            if let error = error {
                print("[SQLite] [ERROR] Could not shutdown BlockingIOThreadPool: \(error)")
            }
        }
    }
}

extension DatabaseIdentifier {
    /// Default `DatabaseIdentifier` for SQLite databases.
    public static var sqlite: DatabaseIdentifier<SQLiteDatabase> {
        return "sqlite"
    }
}
