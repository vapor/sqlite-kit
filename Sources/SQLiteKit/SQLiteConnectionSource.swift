import Foundation
import Logging
import AsyncKit
import NIOPosix
import SQLiteNIO
import NIOCore

public struct SQLiteConnectionSource: ConnectionPoolSource {
    private let configuration: SQLiteConfiguration
    private let actualURL: URL
    private let threadPool: NIOThreadPool

    private var connectionStorage: SQLiteConnection.Storage {
        .file(path: self.actualURL.absoluteString)
    }
    
    public init(
        configuration: SQLiteConfiguration,
        threadPool: NIOThreadPool
    ) {
        self.configuration = configuration
        self.actualURL = configuration.storage.urlForSQLite
        self.threadPool = threadPool
    }

    public func makeConnection(
        logger: Logger,
        on eventLoop: any EventLoop
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

fileprivate extension String {
    var asSafeFilename: String {
        #if os(Windows)
        self.replacingOccurrences(of: ":", with: "_").replacingOccurrences(of: "\\", with: "-")
        #else
        self.replacingOccurrences(of: "/", with: "-")
        #endif
    }
}

fileprivate extension SQLiteConfiguration.Storage {
    var urlForSQLite: URL {
        switch self {
        case .memory(identifier: let identifier):
            let tempFilename = "sqlite-kit_memorydb-\(ProcessInfo.processInfo.processIdentifier)-\(identifier).sqlite3"
            
            return FileManager.default.temporaryDirectory
                .appendingPathComponent(tempFilename.asSafeFilename, isDirectory: false)
        case .file(path: let path):
            if path.starts(with: "file:"), let url = URL(string: path) {
                return url
            } else {
                return URL(fileURLWithPath: path, isDirectory: false)
            }
        }
    }
}
