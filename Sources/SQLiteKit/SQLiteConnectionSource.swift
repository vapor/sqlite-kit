import Logging

public struct SQLiteConnectionSource: ConnectionPoolSource {
    private let configuration: SQLiteConfiguration
    private let threadPool: NIOThreadPool

    private var connectionStorage: SQLiteConnection.Storage {
        switch self.configuration.storage {
        case .memory:
            return .file(
                path: "file:\(ObjectIdentifier(threadPool).unique)?mode=memory&cache=shared"
            )
        case .file(let path):
            return .file(path: path)
        case .connection(let storage):
            return storage
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
        )
    }
}

public struct SQLiteConfiguration {
    public enum Storage {
        case memory
        case file(path: String)
        case connection(SQLiteConnection.Storage)
    }

    public var storage: Storage
    
    public init(file: String) {
        self.init(storage: .file(path: file))
    }

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
