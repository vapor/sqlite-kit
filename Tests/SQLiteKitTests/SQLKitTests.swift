import Logging
import SQLiteKit
import SQLKitBenchmark
import XCTest

class SQLiteTests: XCTestCase {
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
        self.connection = try! SQLiteConnection.open(
            storage: .memory,
            threadPool: self.threadPool,
            on: self.eventLoopGroup.next()
        ).wait()
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

let isLoggingConfigured: Bool = {
    LoggingSystem.bootstrap { label in
        var handler = StreamLogHandler.standardOutput(label: label)
        handler.logLevel = .trace
        return handler
    }
    return true
}()
