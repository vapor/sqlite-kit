import Async
import Dispatch
import XCTest
@testable import SQLite

extension SQLiteConnection {
    static func makeTest() throws -> SQLiteConnection {
        let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        let sqlite = try SQLiteDatabase(storage: .memory)
        let conn = try sqlite.newConnection(on: group).wait()
        conn.logger = DatabaseLogger(database: .sqlite, handler: PrintLogHandler.init())
        return conn
    }
}
