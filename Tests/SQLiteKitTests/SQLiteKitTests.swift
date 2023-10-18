import Logging
import SQLiteKit
import SQLKitBenchmark
import XCTest
import SQLiteNIO
import SQLKit

final class SQLiteKitTests: XCTestCase {
    func testSQLKitBenchmark() throws {
        let benchmark = SQLBenchmarker(on: self.db)
        try benchmark.run()
    }
    
    func testPlanets() async throws {
        try await self.db.drop(table: "planets")
            .ifExists()
            .run()
        try await self.db.drop(table: "galaxies")
            .ifExists()
            .run()
        try await self.db.create(table: "galaxies")
            .column("id", type: .int, .primaryKey)
            .column("name", type: .text)
            .run()
        try await self.db.create(table: "planets")
            .ifNotExists()
            .column("id", type: .int, .primaryKey)
            .column("galaxyID", type: .int, .references("galaxies", "id"))
            .run()
        try await self.db.alter(table: "planets")
            .column("name", type: .text, .default(SQLLiteral.string("Unamed Planet")))
            .run()
        try await self.db.create(index: "test_index")
            .on("planets")
            .column("id")
            .unique()
            .run()
        // INSERT INTO "galaxies" ("id", "name") VALUES (DEFAULT, $1)
        try await self.db.insert(into: "galaxies")
            .columns("id", "name")
            .values(SQLLiteral.null, SQLBind("Milky Way"))
            .values(SQLLiteral.null, SQLBind("Andromeda"))
            // .value(Galaxy(name: "Milky Way"))
            .run()
        // SELECT * FROM galaxies WHERE name != NULL AND (name == ? OR name == ?)
        _ = try await self.db.select()
            .column("*")
            .from("galaxies")
            .where("name", .notEqual, SQLLiteral.null)
            .where {
                $0.where("name", .equal, SQLBind("Milky Way"))
                    .orWhere("name", .equal, SQLBind("Andromeda"))
            }
            .all()

        _ = try await self.db.select()
            .column("*")
            .from("galaxies")
            .where(SQLColumn("name"), .equal, SQLBind("Milky Way"))
            .groupBy("id")
            .orderBy("name", .descending)
            .all()

        try await self.db.insert(into: "planets")
            .columns("id", "name")
            .values(SQLLiteral.null, SQLBind("Earth"))
            .run()

        try await self.db.insert(into: "planets")
            .columns("id", "name")
            .values(SQLLiteral.null, SQLBind("Mercury"))
            .values(SQLLiteral.null, SQLBind("Venus"))
            .values(SQLLiteral.null, SQLBind("Mars"))
            .values(SQLLiteral.null, SQLBind("Jpuiter"))
            .values(SQLLiteral.null, SQLBind("Pluto"))
            .run()

        try await self.db.select()
            .column(SQLFunction("count", args: "name"))
            .from("planets")
            .where("galaxyID", .equal, SQLBind(5))
            .run()

        try await self.db.select()
            .column(SQLFunction("count", args: SQLLiteral.all))
            .from("planets")
            .where("galaxyID", .equal, SQLBind(5))
            .run()
    }

    func testForeignKeysEnabledOnlyWhenRequested() async throws {
        let res = try await self.connection.query("PRAGMA foreign_keys").get()
        XCTAssertEqual(res[0].column("foreign_keys"), .integer(1))

        // Using `.file` storage here is a quick and dirty nod to increasing test coverage.
        let source = SQLiteConnectionSource(
            configuration: .init(storage: .file(
                path: FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID()).sqlite3", isDirectory: false).path
            ), enableForeignKeys: false),
            threadPool: self.threadPool
        )

        let conn2 = try await source.makeConnection(logger: self.connection.logger, on: self.eventLoopGroup.any()).get()
        defer { try! conn2.close().wait() }
        
        let res2 = try await conn2.query("PRAGMA foreign_keys").get()
        XCTAssertEqual(res2[0].column("foreign_keys"), .integer(0))
    }

    func testJSONStringColumn() async throws {
        _ = try await self.connection.query("CREATE TABLE foo (bar TEXT)").get()
        _ = try await self.connection.query(#"INSERT INTO foo (bar) VALUES ('{"baz": "qux"}')"#).get()
        let rows = try await self.connection.query("SELECT * FROM foo").get()

        struct Bar: Codable {
            var baz: String
        }
        let bar = try SQLiteDataDecoder().decode(Bar.self, from: rows[0].column("bar")!)
        XCTAssertEqual(bar.baz, "qux")
    }

    func testMultipleInMemoryDatabases() async throws {
        let a = SQLiteConnectionSource(
            configuration: .init(storage: .memory, enableForeignKeys: true),
            threadPool: self.threadPool
        )
        let b = SQLiteConnectionSource(
            configuration: .init(storage: .memory, enableForeignKeys: true),
            threadPool: self.threadPool
        )

        let a1 = try await a.makeConnection(logger: .init(label: "test"), on: self.eventLoopGroup.any()).get()
        defer { try! a1.close().wait() }
        let a2 = try await a.makeConnection(logger: .init(label: "test"), on: self.eventLoopGroup.any()).get()
        defer { try! a2.close().wait() }
        let b1 = try await b.makeConnection(logger: .init(label: "test"), on: self.eventLoopGroup.any()).get()
        defer { try! b1.close().wait() }
        let b2 = try await b.makeConnection(logger: .init(label: "test"), on: self.eventLoopGroup.any()).get()
        defer { try! b2.close().wait() }

        _ = try await a1.query("CREATE TABLE foo (bar INTEGER)").get()
        _ = try await a2.query("SELECT * FROM foo").get()
        _ = try await b1.query("CREATE TABLE foo (bar INTEGER)").get()
        _ = try await b2.query("SELECT * FROM foo").get()
    }

    // https://github.com/vapor/sqlite-kit/issues/56
    func testDoubleConstraintError() async throws {
        try await self.db.create(table: "foo")
            .ifNotExists()
            .column("id", type: .text, .primaryKey(autoIncrement: false), .notNull)
            .run()
    }
    
    func testRowDecoding() async throws {
        try await self.db.create(table: "foo")
            .column("id", type: .int, .primaryKey(autoIncrement: false), .notNull)
            .column("value", type: .text)
            .run()
        try await self.db.insert(into: "foo")
            .columns("id", "value")
            .values(SQLLiteral.numeric("1"), SQLBind("abc"))
            .values(SQLLiteral.numeric("2"), SQLBind(String?.none))
            .run()
        let rows = try await self.db.select()
            .column("value")
            .from("foo")
            .orderBy("id")
            .all()
        
        XCTAssertEqual(rows.count, 2)
        let row1 = try XCTUnwrap(rows.dropFirst(0).first),
            row2 = try XCTUnwrap(rows.dropFirst(1).first)
        XCTAssertTrue(row1.contains(column: "value"))
        XCTAssertFalse(try row1.decodeNil(column: "value"))
        XCTAssertEqual(try row1.decode(column: "value", as: String?.self), "abc")
        XCTAssertThrowsError(try row1.decode(column: "value", as: Int.self))
        XCTAssertThrowsError(try row1.decode(column: "nonexistent", as: String?.self))
        XCTAssertTrue(try row1.decodeNil(column: "nonexistent"))
        XCTAssertTrue(row2.contains(column: "value"))
        XCTAssertTrue(try row2.decodeNil(column: "value"))
        XCTAssertEqual(try row2.decode(column: "value", as: String?.self), nil)
        XCTAssertThrowsError(try row2.decode(column: "value", as: Int.self))
        XCTAssertThrowsError(try row2.decode(column: "nonexistent", as: String?.self))
        XCTAssertTrue(try row2.decodeNil(column: "nonexistent"))
    }
    
    func testRowEncoding() async throws {
        struct SubFoo: Codable {
            struct NestFoo: Codable { let x: Double }
            let arr: [Int]
            let val: String
            let nest: NestFoo
        }
        try await self.db.create(table: "foo")
            .column("id", type: .int, .primaryKey(autoIncrement: false), .notNull)
            .column("value", type: .custom(SQLRaw("json")))
            .run()
        try await self.db.insert(into: "foo")
            .columns("id", "value")
            .values(SQLLiteral.numeric("1"), SQLBind(SubFoo(arr: [1,2,3], val: "a", nest: .init(x: 1.1))))
            .values(SQLLiteral.numeric("2"), SQLBind(SubFoo?.none))
            .run()
        let rows = try await self.db.select()
            .column(self.db.dialect.nestedSubpathExpression(in: SQLColumn("value"), for: ["nest", "x"])!, as: "x")
            .from("foo")
            .orderBy("id")
            .all()
        
        XCTAssertEqual(rows.count, 2)
        let row1 = try XCTUnwrap(rows.dropFirst(0).first),
            row2 = try XCTUnwrap(rows.dropFirst(1).first)
        XCTAssertTrue(row1.contains(column: "x"))
        XCTAssertTrue(row2.contains(column: "x"))
        XCTAssertEqual(try row1.decode(column: "x", as: Double.self), 1.1)
        XCTAssertTrue(try row2.decodeNil(column: "x"))
    }
    
    // https://github.com/vapor/sqlite-kit/issues/62
    func testEncodeNestedArray() throws {
        struct Foo: Encodable {
            var bar: [String]
        }
        let foo = Foo(bar: ["a", "b", "c"])
        _ = try SQLiteDataEncoder().encode(foo)
    }

    var db: any SQLDatabase { self.connection.sql() }
    var benchmark: SQLBenchmarker { .init(on: self.db) }
    
    var eventLoopGroup: (any EventLoopGroup)!
    var threadPool: NIOThreadPool!
    var connection: SQLiteConnection!

    override func setUp() async throws {
        XCTAssertTrue(isLoggingConfigured)
        self.eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 2)
        self.threadPool = NIOThreadPool(numberOfThreads: 2)
        self.threadPool.start()
        self.connection = try await SQLiteConnectionSource(
            configuration: .init(storage: .memory, enableForeignKeys: true),
            threadPool: self.threadPool
        ).makeConnection(logger: .init(label: "test"), on: self.eventLoopGroup.any()).get()
    }

    override func tearDown() async throws {
        try await self.connection.close().get()
        self.connection = nil
        try await self.threadPool.shutdownGracefully()
        self.threadPool = nil
        try await self.eventLoopGroup.shutdownGracefully()
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
