#if canImport(Darwin)
import Foundation
#else
@preconcurrency import Foundation
#endif
import Logging
import AsyncKit
import NIOPosix
import SQLiteNIO
import NIOCore

/// A `ConnectionPoolSource` providing SQLite database connections for a given ``SQLiteConfiguration``.
public struct SQLiteConnectionSource: ConnectionPoolSource, Sendable {
    private let configuration: SQLiteConfiguration
    private let actualURL: URL
    private let threadPool: NIOThreadPool

    private var connectionStorage: SQLiteConnection.Storage {
        .file(path: self.actualURL.absoluteString)
    }
    
    /// Create a new ``SQLiteConnectionSource``.
    ///
    /// > Important: If the caller provides a thread pool other than the default, they are responsible for starting
    /// > the pool before any connections are made and shutting it down only after all connections are closed. It is
    /// > strongly recommended that all callers use the default.
    ///
    /// - Parameters:
    ///   - configuration: The configuration for new connections.
    ///   - threadPool: The thread pool used by connections. Defaults to the global singleton.
    public init(
        configuration: SQLiteConfiguration,
        threadPool: NIOThreadPool = .singleton
    ) {
        self.configuration = configuration
        self.actualURL = configuration.storage.urlForSQLite
        self.threadPool = threadPool
    }

    // See `ConnectionPoolSource.makeConnection(logger:on:)`.
    public func makeConnection(
        logger: Logger,
        on eventLoop: any EventLoop
    ) -> EventLoopFuture<SQLiteConnection> {
        SQLiteConnection.open(
            storage: self.connectionStorage,
            threadPool: self.threadPool,
            logger: logger,
            on: eventLoop
        ).flatMap { conn in
            if self.configuration.enableForeignKeys {
                return conn.query("PRAGMA foreign_keys = ON").map { _ in conn }
            } else {
                return eventLoop.makeSucceededFuture(conn)
            }
        }
    }
}

extension SQLiteNIO.SQLiteConnection: AsyncKit.ConnectionPoolItem {}

fileprivate extension String {
    /// Attempt to "sanitize" a string for use as a filename. This is quick and dirty and probably not 100% correct.
    var asSafeFilename: String {
        #if os(Windows)
        self.replacingOccurrences(of: ":", with: "_").replacingOccurrences(of: "\\", with: "-")
        #else
        self.replacingOccurrences(of: "/", with: "-")
        #endif
    }
}

fileprivate extension SQLiteConfiguration.Storage {
    /// Because SQLiteNIO specifies the recommended `SQLITE_OMIT_SHARED_CACHE` build flag, we cannot implement our
    /// claimed support for multiple connections to in-memory databases using actual in-memory databases.
    /// Unfortunately, Fluent relies on having this support, and it had been public API since long before the change
    /// in build flags. Therefore, we work around it by using temporary files to fake in-memory databases.
    ///
    /// This has the unfortunate side effect of violating the "when the last connection to an in-memory database is
    /// closed, it is immediately deleted" semantics, but fortunately no one seems to have relied on that behavior.
    ///
    /// We include both the user-provided identifer and the current process ID in the filename for the temporary
    /// file because in-memory databases are expected to be process-specific.
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
