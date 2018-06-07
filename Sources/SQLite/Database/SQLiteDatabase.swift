#if os(Linux)
import CSQLite
#else
import SQLite3
#endif

/// SQlite database. Used to make connections.
public final class SQLiteDatabase: Database, LogSupporting {
    /// The path to the SQLite file.
    public let storage: SQLiteStorage
    
    private let blockingIO: BlockingIOThreadPool

    /// Create a new SQLite database.
    public init(storage: SQLiteStorage) throws {
        self.storage = storage
        switch storage {
        case .memory:
            if FileManager.default.fileExists(atPath: storage.path) {
                try FileManager.default.removeItem(atPath: storage.path)
            }
        case .file: break
        }
        self.blockingIO = BlockingIOThreadPool(numberOfThreads: 1) // FIXME: configurable
        self.blockingIO.start()
    }

    /// See `Database`.
    public func newConnection(on worker: Worker) -> Future<SQLiteConnection> {
        let promise = worker.eventLoop.newPromise(SQLiteConnection.self)
        blockingIO.submit { state in
            // make connection
            let options = SQLITE_OPEN_CREATE | SQLITE_OPEN_READWRITE | SQLITE_OPEN_NOMUTEX
            var handle: OpaquePointer?
            guard sqlite3_open_v2(self.storage.path, &handle, options, nil) == SQLITE_OK, let c = handle else {
                let error = SQLiteError(problem: .error, reason: "Could not open database.", source: .capture())
                promise.fail(error: error)
                return
            }
            let conn = SQLiteConnection(c: c, blockingIO: self.blockingIO, on: worker)
            return promise.succeed(result: conn)
        }
        return promise.futureResult
    }

    /// See `LogSupporting`.
    public static func enableLogging(_ logger: DatabaseLogger, on conn: SQLiteConnection) {
        conn.logger = logger
    }
    
    deinit {
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
