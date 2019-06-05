import SQLiteKit
import SQLKitBenchmark
import XCTest

class SQLiteTests: XCTestCase {
    func testBenchmark() throws {
        try self.benchmarker.run()
    }

    var benchmarker: SQLBenchmarker<ConnectionPool<SQLiteConnectionSource>> {
        return SQLBenchmarker.init(on: self.connectionPool)
    }
    var connectionPool: ConnectionPool<SQLiteConnectionSource>!
    var threadPool: NIOThreadPool!
    var eventLoopGroup: EventLoopGroup!

    override func setUp() {
        self.eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        self.threadPool = .init(numberOfThreads: 2)
        let db = SQLiteConnectionSource(configuration: .init(storage: .memory), threadPool: self.threadPool, on: self.eventLoopGroup.next())
        self.connectionPool = ConnectionPool(config: .init(maxConnections: 8), source: db)
    }

    override func tearDown() {
        try! self.connectionPool.close().wait()
        self.connectionPool = nil
        try! self.threadPool.syncShutdownGracefully()
        self.threadPool = nil
        try! self.eventLoopGroup.syncShutdownGracefully()
        self.eventLoopGroup = nil
    }
}
