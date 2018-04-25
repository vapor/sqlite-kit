import CSQLite

/// SQlite database. Used to make connections.
public final class SQLiteDatabase: Database, LogSupporting {
    /// The path to the SQLite file.
    public let storage: SQLiteStorage

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
    }

    /// See `Database`.
    public func newConnection(on worker: Worker) -> Future<SQLiteConnection> {
        let promise = worker.eventLoop.newPromise(SQLiteConnection.self)
        do {
            // make connection
            let options = SQLITE_OPEN_CREATE | SQLITE_OPEN_READWRITE | SQLITE_OPEN_NOMUTEX
            var raw: SQLiteConnection.Raw?
            guard sqlite3_open_v2(storage.path, &raw, options, nil) == SQLITE_OK else {
                throw SQLiteError(problem: .error, reason: "Could not open database.", source: .capture())
            }

            guard let r = raw else {
                throw SQLiteError(problem: .error, reason: "Unexpected nil database.", source: .capture())
            }

            let conn = SQLiteConnection(raw: r, on: worker)
            promise.succeed(result: conn)
        } catch {
            promise.fail(error: error)
        }
        return promise.futureResult
    }

    /// See `LogSupporting`.
    public static func enableLogging(_ logger: DatabaseLogger, on conn: SQLiteConnection) {
        conn.logger = logger
    }
}

extension DatabaseIdentifier {
    /// Default `DatabaseIdentifier` for SQLite databases.
    public static var sqlite: DatabaseIdentifier<SQLiteDatabase> {
        return "sqlite"
    }
}
