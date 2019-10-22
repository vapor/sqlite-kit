import Logging

public final class SQLiteConnectionSource: ConnectionPoolSource {
    private let storage: SQLiteConnection.Storage
    private let threadPool: NIOThreadPool
    private let logger: Logger

    public init(
        configuration: SQLiteConfiguration,
        threadPool: NIOThreadPool,
        logger: Logger = .init(label: "codes.sqlite.connection-source")
    ) {
        switch configuration.storage {
        case .memory:
            self.storage = .file(path: "file:\(ObjectIdentifier(threadPool).unique)?mode=memory&cache=shared")
        case .connection(let storage):
            self.storage = storage
        }
        self.threadPool = threadPool
        self.logger = logger
    }

    public func makeConnection(on eventLoop: EventLoop) -> EventLoopFuture<SQLiteConnection> {
        return SQLiteConnection.open(storage: self.storage, threadPool: self.threadPool, on: eventLoop)
    }
}

public struct SQLiteConfiguration {
    public enum Storage {
        case memory
        case connection(SQLiteConnection.Storage)
    }

    public var storage: Storage

    public init(storage: Storage) {
        self.storage = storage
    }
}

extension SQLiteConnection: ConnectionPoolItem { }


private extension ObjectIdentifier {
    var unique: String {
        let raw = "\(self)"
        let parts = raw.split(separator: "(")
        switch parts.count {
        case 2:
            return parts[1].split(separator: ")").first.flatMap(String.init) ?? raw
        default:
            return raw
        }
    }
}
