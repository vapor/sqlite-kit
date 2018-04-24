import Async
import Dispatch
import XCTest
@testable import SQLite

extension SQLiteConnection {
    static func makeTest() throws -> SQLiteConnection {
        let group = MultiThreadedEventLoopGroup(numThreads: 1)
        let sqlite = try SQLiteDatabase(storage: .memory)
        return try sqlite.newConnection(on: group).wait()
    }
}
