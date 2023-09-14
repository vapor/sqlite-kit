import Foundation
import Logging
import AsyncKit
import NIOPosix
import SQLiteNIO
import NIOCore

public struct SQLiteConnectionSource: ConnectionPoolSource {
    private let configuration: SQLiteConfiguration
    private let actualPath: URL
    private let threadPool: NIOThreadPool

    private var connectionStorage: SQLiteConnection.Storage {
        .file(path: self.actualPath.absoluteString)
    }
    
    public init(
        configuration: SQLiteConfiguration,
        threadPool: NIOThreadPool
    ) {
        self.configuration = configuration
        switch configuration.storage {
        case .memory(identifier: let identifier):
            let filenameSafeIdentifer = String(identifier.map { $0 == ":" ? "_" : ($0 == "\\" ? "+" : ($0 == "/" ? "-" : $0)) })
            let tempFilename = "sqlite-kit_memorydb-\(ProcessInfo.processInfo.processIdentifier)-\(filenameSafeIdentifer).sqlite3"
            self.actualPath = FileManager.default.temporaryDirectory.appendingPathComponent(tempFilename, isDirectory: false)
        case .file(path: let path):
            self.actualPath = URL(fileURLWithPath: path, isDirectory: false)
        }
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
