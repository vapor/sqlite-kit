import Logging
import SQLiteKit
import SQLKitBenchmark
import XCTest

class SQLiteKitTests: XCTestCase {
    func testSQLBenchmark() throws {
        try SQLBenchmarker(on: self.db).run()
    }

    func testForeignKeysEnabled() throws {
        let res = try self.connection.query("PRAGMA foreign_keys").wait()
        XCTAssertEqual(res[0].column("foreign_keys"), .integer(1))
    }

    func testJSONStringColumn() throws {
        _ = try self.connection.query("CREATE TABLE foo (bar TEXT)").wait()
        _ = try self.connection.query(#"INSERT INTO foo (bar) VALUES ('{"baz": "qux"}')"#).wait()
        let rows = try self.connection.query("SELECT * FROM foo").wait()

        struct Bar: Codable {
            var baz: String
        }
        let bar = try SQLiteDataDecoder().decode(Bar.self, from: rows[0].column("bar")!)
        XCTAssertEqual(bar.baz, "qux")
    }

    func testMultipleInMemoryDatabases() throws {
        let a = SQLiteConnectionSource(
            configuration: .init(storage: .memory, enableForeignKeys: true),
            threadPool: self.threadPool
        )
        let b = SQLiteConnectionSource(
            configuration: .init(storage: .memory, enableForeignKeys: true),
            threadPool: self.threadPool
        )

        let a1 = try a.makeConnection(logger: .init(label: "test"), on: self.eventLoopGroup.next()).wait()
        defer { try! a1.close().wait() }
        let a2 = try a.makeConnection(logger: .init(label: "test"), on: self.eventLoopGroup.next()).wait()
        defer { try! a2.close().wait() }
        let b1 = try b.makeConnection(logger: .init(label: "test"), on: self.eventLoopGroup.next()).wait()
        defer { try! b1.close().wait() }
        let b2 = try b.makeConnection(logger: .init(label: "test"), on: self.eventLoopGroup.next()).wait()
        defer { try! b2.close().wait() }

        _ = try a1.query("CREATE TABLE foo (bar INTEGER)").wait()
        _ = try a2.query("SELECT * FROM foo").wait()
        _ = try b1.query("CREATE TABLE foo (bar INTEGER)").wait()
        _ = try b2.query("SELECT * FROM foo").wait()
    }

    // https://github.com/vapor/sqlite-kit/issues/56
    func testDoubleConstraintError() throws {
        try self.db.create(table: "foo")
            .ifNotExists()
            .column("id", type: .text, .primaryKey(autoIncrement: false), .notNull)
            .run()
            .wait()
    }

    // https://github.com/vapor/sqlite-kit/issues/62
    func testEncodeNestedArray() throws {
        struct Foo: Encodable {
            var bar: [String]
        }
        let foo = Foo(bar: ["a", "b", "c"])
        _ = try SQLiteDataEncoder().encode(foo)
    }

    var db: SQLDatabase {
        self.connection.sql()
    }
    var benchmark: SQLBenchmarker {
        .init(on: self.db)
    }
    
    var eventLoopGroup: EventLoopGroup!
    var threadPool: NIOThreadPool!
    var connection: SQLiteConnection!

    override func setUp() {
        XCTAssertTrue(isLoggingConfigured)
        self.eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 2)
        self.threadPool = NIOThreadPool(numberOfThreads: 2)
        self.threadPool.start()
        self.connection = try! SQLiteConnectionSource(
            configuration: .init(storage: .memory, enableForeignKeys: true),
            threadPool: self.threadPool
        ).makeConnection(logger: .init(label: "test"), on: self.eventLoopGroup.next()).wait()
    }

    override func tearDown() {
        try! self.connection.close().wait()
        self.connection = nil
        try! self.threadPool.syncShutdownGracefully()
        self.threadPool = nil
        try! self.eventLoopGroup.syncShutdownGracefully()
        self.eventLoopGroup = nil
    }
}

func env(_ name: String) -> String? {
    getenv(name).flatMap { String(cString: $0) }
}

let isLoggingConfigured: Bool = {
    LoggingSystem.bootstrap { label in
        var handler = StreamLogHandler.standardOutput(label: label)
        handler.logLevel = env("LOG_LEVEL").flatMap { Logger.Level(rawValue: $0) } ?? .debug
        return handler
    }
    return true
}()
