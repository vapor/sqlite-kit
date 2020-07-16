import Logging

public struct SQLiteConnectionSource: ConnectionPoolSource {
    private let configuration: SQLiteConfiguration
    private let threadPool: NIOThreadPool

    private var connectionStorage: SQLiteConnection.Storage {
        switch self.configuration.storage {
        case .memory(let identifier):
            return .file(
                path: "file:\(identifier)?mode=memory&cache=shared"
            )
        case .file(let path):
            return .file(path: path)
        }
    }
    
    public init(
        configuration: SQLiteConfiguration,
        threadPool: NIOThreadPool
    ) {
        self.configuration = configuration
        self.threadPool = threadPool
    }

    public func makeConnection(
        logger: Logger,
        on eventLoop: EventLoop
    ) -> EventLoopFuture<SQLiteConnection> {
        return SQLiteConnection.open(
            storage: self.connectionStorage,
            threadPool: self.threadPool,
            logger: logger,
            on: eventLoop
        ).flatMap { conn in
            if self.configuration.enableForeignKeys {
                return conn.query("PRAGMA foreign_keys = ON")
                    .map { _ in conn }
            } else {
                return eventLoop.makeSucceededFuture(conn)
            }
        }
    }
}

extension SQLiteConnection: ConnectionPoolItem { }
