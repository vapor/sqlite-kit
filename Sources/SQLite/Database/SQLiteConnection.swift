import CSQLite

public final class SQLiteConnection: BasicWorker, DatabaseConnection {
    public typealias Database = SQLiteDatabase
    
    public var isClosed: Bool

    public let eventLoop: EventLoop

    public var extend: Extend

    /// Optional logger, if set queries should be logged to it.
    public var logger: DatabaseLogger?
    
    private let blockingIO: BlockingIOThreadPool

    internal let c: OpaquePointer

    /// Returns the last error message, if one exists.
    internal var errorMessage: String? {
        guard let raw = sqlite3_errmsg(c) else {
            return nil
        }
        return String(cString: raw)
    }

    /// Create a new SQLite conncetion.
    internal init(c: OpaquePointer, blockingIO: BlockingIOThreadPool, on worker: Worker) {
        self.c = c
        self.eventLoop = worker.eventLoop
        self.extend = [:]
        self.isClosed = false
        self.blockingIO = blockingIO
    }

    /// Returns an identifier for the last inserted row.
    public var lastAutoincrementID: Int? {
        let id = sqlite3_last_insert_rowid(c)
        return Int(id)
    }

    /// Closes the database connection.
    public func close() {
        isClosed = true
        sqlite3_close(c)
    }
    
    public func query(_ query: SQLiteQuery) -> Future<[[SQLiteColumn: SQLiteData]]> {
        var binds: [SQLiteData] = []
        let sql = query.serialize(&binds)
        return self.query(sql, binds)
    }
//
//    public func query(_ query: SQLQuery, onRow: @escaping ([SQLiteColumn: SQLiteData]) throws -> ()) -> Future<Void> {
//        var binds = Binds()
//        let sql = SQLiteSerializer().serialize(query: query, binds: &binds)
//        return self.query(sql, binds.values, onRow: onRow)
//    }
//    
    public func query<D>(_ string: String, _ parameters: [SQLiteData] = [], decoding: D.Type) -> Future<[D]>
        where D: Decodable
    {
        return query(string, parameters).map { try $0.map { try SQLiteRowDecoder().decode(D.self, from: $0) } }
    }
    
    public func query(_ string: String, _ parameters: [SQLiteData] = []) -> Future<[[SQLiteColumn: SQLiteData]]> {
        var rows: [[SQLiteColumn: SQLiteData]] = []
        return query(string, parameters) { rows.append($0) }.map { rows }
    }
    
    public func query<D>(_ string: String, _ parameters: [SQLiteData] = [], decoding: D.Type, onRow: @escaping (D) throws -> ()) -> Future<Void>
        where D: Decodable
    {
        return query(string, parameters) { try onRow(SQLiteRowDecoder().decode(D.self, from: $0)) }
    }
    
    public func query(_ string: String, _ parameters: [SQLiteData] = [], onRow: @escaping ([SQLiteColumn: SQLiteData]) throws -> ()) -> Future<Void> {
        let promise = eventLoop.newPromise(Void.self)
        // log before anything happens, in case there's an error
        logger?.record(query: string, values: parameters.map { $0.description })
        blockingIO.submit { state in
            do {
                let statement = try SQLiteStatement(query: string, on: self)
                try statement.bind(parameters)
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
                return promise.succeed(result: ())
            } catch {
                return promise.fail(error: error)
            }
        }
        return promise.futureResult
    }

    /// Closes the database when deinitialized.
    deinit {
        close()
    }
}
