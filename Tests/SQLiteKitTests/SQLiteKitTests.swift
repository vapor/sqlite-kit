import Logging
import SQLiteKit
import SQLKitBenchmark
import XCTest

class SQLiteKitTests: XCTestCase {
    func testSQLKitBenchmark() throws {
        let benchmark = SQLBenchmarker(on: db)
        try benchmark.run()
    }
    
    func testEnum() throws {
        try self.benchmark.testEnum()
    }

    func testPlanets() throws {
        try self.db.drop(table: "planets")
            .ifExists()
            .run().wait()
        try self.db.drop(table: "galaxies")
            .ifExists()
            .run().wait()
        try self.db.create(table: "galaxies")
            .column("id", type: .int, .primaryKey)
            .column("name", type: .text)
            .run().wait()
        try self.db.create(table: "planets")
            .ifNotExists()
            .column("id", type: .int, .primaryKey)
            .column("galaxyID", type: .int, .references("galaxies", "id"))
            .run().wait()
        try self.db.alter(table: "planets")
            .column("name", type: .text, .default(SQLLiteral.string("Unamed Planet")))
            .run().wait()
        try self.db.create(index: "test_index")
            .on("planets")
            .column("id")
            .unique()
            .run().wait()
        // INSERT INTO "galaxies" ("id", "name") VALUES (DEFAULT, $1)
        try self.db.insert(into: "galaxies")
            .columns("id", "name")
            .values(SQLLiteral.null, SQLBind("Milky Way"))
            .values(SQLLiteral.null, SQLBind("Andromeda"))
            // .value(Galaxy(name: "Milky Way"))
            .run().wait()
        // SELECT * FROM galaxies WHERE name != NULL AND (name == ? OR name == ?)
        _ = try self.db.select()
            .column("*")
            .from("galaxies")
            .where("name", .notEqual, SQLLiteral.null)
            .where {
                $0.where("name", .equal, SQLBind("Milky Way"))
                    .orWhere("name", .equal, SQLBind("Andromeda"))
            }
            .all().wait()

        _ = try self.db.select()
            .column("*")
            .from("galaxies")
            .where(SQLColumn("name"), .equal, SQLBind("Milky Way"))
            .groupBy("id")
            .orderBy("name", .descending)
            .all().wait()

        try self.db.insert(into: "planets")
            .columns("id", "name")
            .values(SQLLiteral.null, SQLBind("Earth"))
            .run().wait()

        try self.db.insert(into: "planets")
            .columns("id", "name")
            .values(SQLLiteral.null, SQLBind("Mercury"))
            .values(SQLLiteral.null, SQLBind("Venus"))
            .values(SQLLiteral.null, SQLBind("Mars"))
            .values(SQLLiteral.null, SQLBind("Jpuiter"))
            .values(SQLLiteral.null, SQLBind("Pluto"))
            .run().wait()

        try self.db.select()
            .column(SQLFunction("count", args: "name"))
            .from("planets")
            .where("galaxyID", .equal, SQLBind(5))
            .run().wait()

        try self.db.select()
            .column(SQLFunction("count", args: SQLLiteral.all))
            .from("planets")
            .where("galaxyID", .equal, SQLBind(5))
            .run().wait()
    }

    func testForeignKeysEnabled() throws {
        let res = try self.connection.query("PRAGMA foreign_keys").wait()
        XCTAssertEqual(res[0].column("foreign_keys"), .integer(1))
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
