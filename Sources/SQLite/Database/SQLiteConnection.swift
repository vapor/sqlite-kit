import CSQLite

/// SQlite connection. Use this to create statements that can be executed.
public final class SQLiteConnection: BasicWorker, DatabaseConnection {
    /// Raw SQLite connection type.
    internal typealias Raw = OpaquePointer

    /// See `DatabaseConnection`
    public var isClosed: Bool

    /// See `BasicWorker`.
    public let eventLoop: EventLoop

    /// See `Extendable`.
    public var extend: Extend

    /// Optional logger, if set queries should be logged to it.
    public var logger: DatabaseLogger?

    /// Raw pointer to this SQLite connection.
    internal var raw: Raw

    /// Returns the last error message, if one exists.
    internal var errorMessage: String? {
        guard let raw = sqlite3_errmsg(raw) else {
            return nil
        }
        return String(cString: raw)
    }

    /// Create a new SQLite conncetion.
    internal init(raw: Raw, on worker: Worker) {
        self.raw = raw
        self.eventLoop = worker.eventLoop
        self.extend = [:]
        self.isClosed = false
    }

    /// Returns an identifier for the last inserted row.
    public var lastAutoincrementID: Int? {
        let id = sqlite3_last_insert_rowid(raw)
        return Int(id)
    }

    /// Closes the database connection.
    public func close() {
        isClosed = true
        sqlite3_close(raw)
    }

    /// Convenience for creating a SQLite query.
    public func query(string: String) -> SQLiteQuery {
        return SQLiteQuery(string: string, connection: self)
    }

    /// Closes the database when deinitialized.
    deinit {
        close()
    }
}
