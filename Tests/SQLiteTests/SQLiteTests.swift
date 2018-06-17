import SQL
import SQLite
import XCTest

struct Planet: SQLiteTable {
    var id: Int?
    var name: String
    var galaxyID: Int
    init(id: Int? = nil, name: String, galaxyID: Int) {
        self.id = id
        self.name = name
        self.galaxyID = galaxyID
    }
}
struct Galaxy: SQLiteTable {
    var id: Int?
    var name: String
    init(id: Int? = nil, name: String) {
        self.id = id
        self.name = name
    }
}

struct Galaxy2: SQLiteTable {
    
}

class SQLiteTests: XCTestCase {
    func testVersion() throws {
        let conn = try SQLiteConnection.makeTest()
        
        let res = try conn.query("SELECT sqlite_version();").wait()
        print(res)
    }
    
    func testVersionBuild() throws {
        let conn = try SQLiteConnection.makeTest()

        let res = try conn.select()
            .column(function: "sqlite_version", as: "version")
            .all().wait()
        print(res)
    }

    func testSQL() throws {
        let conn = try SQLiteConnection.makeTest()
        
        try conn.drop(table: Planet.self)
            .ifExists()
            .run().wait()
        try conn.drop(table: Galaxy.self)
            .ifExists()
            .run().wait()

        try conn.create(table: Galaxy.self)
            .column(for: \Galaxy.id, type: .integer, .primaryKey)
            .column(for: \Galaxy.name, type: .text, .notNull)
            .run().wait()
        try conn.create(table: Planet.self)
            .temporary()
            .ifNotExists()
            .column(for: \Planet.id, type: .integer, .primaryKey)
            .column(for: \Planet.galaxyID, type: .integer, .notNull, .references(\Galaxy.id))
            .run().wait()

        try conn.alter(table: Planet.self)
            .addColumn(for: \Planet.name, type: .text, .notNull, .default(.literal("Unamed Planet")))
            .run().wait()

        try conn.insert(into: Galaxy.self)
            .value(Galaxy(name: "Milky Way"))
            .run().wait()
        
        let a = try conn.select().all().from(Galaxy.self)
            .where(\Galaxy.name == "Milky Way")
            .groupBy(\Galaxy.name)
            .orderBy(\Galaxy.name, .descending)
            .all(decoding: Galaxy.self).wait()
        print(a)
        
        let galaxyID = conn.lastAutoincrementID.flatMap(Int.init)!
        try conn.insert(into: Planet.self)
            .value(Planet(name: "Earth", galaxyID: galaxyID))
            .run().wait()

        try conn.insert(into: Planet.self)
            .values([
                Planet(name: "Mercury", galaxyID: galaxyID),
                Planet(name: "Venus", galaxyID: galaxyID),
                Planet(name: "Mars", galaxyID: galaxyID),
                Planet(name: "Jpuiter", galaxyID: galaxyID),
                Planet(name: "Pluto", galaxyID: galaxyID)
            ])
            .run().wait()

        try conn.update(Planet.self)
            .where(\Planet.name == "Jpuiter")
            .set(["name": "Jupiter"])
            .run().wait()

        let selectC = try conn.select().all()
            .from(Planet.self)
            .join(\Planet.galaxyID, to: \Galaxy.id)
            .all(decoding: Planet.self, Galaxy.self)
            .wait()
        print(selectC)
        
        try conn.update(Galaxy.self)
            .set(\Galaxy.name, to: "Milky Way 2")
            .where(\Galaxy.name == "Milky Way")
            .run().wait()
        
        try conn.delete(from: Galaxy.self)
            .where(\Galaxy.name == "Milky Way")
            .run().wait()
        
        let b = try conn.select()
            .column(.count(as: "c"))
            .from(Galaxy.self)
            .all().wait()
        print(b)
    }


    func testTables() throws {
        let database = try SQLiteConnection.makeTest()
        _ = try database.query("DROP TABLE IF EXISTS foo").wait()
        _ = try database.query("CREATE TABLE foo (bar INT(4), baz VARCHAR(16), biz FLOAT)").wait()
        _ = try database.query("INSERT INTO foo VALUES (42, 'Life', 0.44)").wait()
        _ = try database.query("INSERT INTO foo VALUES (1337, 'Elite', 209.234)").wait()
        _ = try database.query("INSERT INTO foo VALUES (9, NULL, 34.567)").wait()

        if let resultBar = try database.query("SELECT * FROM foo WHERE bar = 42").wait().first {
            XCTAssertEqual(resultBar.firstValue(forColumn: "bar"), .integer(42))
            XCTAssertEqual(resultBar.firstValue(forColumn: "baz"), .text("Life"))
            XCTAssertEqual(resultBar.firstValue(forColumn: "biz"), .float(0.44))
        } else {
            XCTFail("Could not get bar result")
        }


        if let resultBaz = try database.query("SELECT * FROM foo where baz = 'Elite'").wait().first {
            XCTAssertEqual(resultBaz.firstValue(forColumn: "bar"), .integer(1337))
            XCTAssertEqual(resultBaz.firstValue(forColumn: "baz"), .text("Elite"))
        } else {
            XCTFail("Could not get baz result")
        }

        if let resultBaz = try database.query("SELECT * FROM foo where bar = 9").wait().first {
            XCTAssertEqual(resultBaz.firstValue(forColumn: "bar"), .integer(9))
            XCTAssertEqual(resultBaz.firstValue(forColumn: "baz"), .null)
        } else {
            XCTFail("Could not get null result")
        }
    }

    func testUnicode() throws {
        let database = try SQLiteConnection.makeTest()
        /// This string includes characters from most Unicode categories
        /// such as Latin, Latin-Extended-A/B, Cyrrilic, Greek etc.
        let unicode = "®¿ÐØ×ĞƋƢǂǊǕǮȐȘȢȱȵẀˍΔῴЖ♆"
        _ = try database.query("DROP TABLE IF EXISTS `foo`").wait()
        _ = try database.query("CREATE TABLE `foo` (bar TEXT)").wait()

        _ = try database.query("INSERT INTO `foo` VALUES(?)", [unicode]).wait()
        let selectAllResults = try database.query("SELECT * FROM `foo`").wait().first
        XCTAssertNotNil(selectAllResults)
        XCTAssertEqual(selectAllResults!.firstValue(forColumn: "bar"), .text(unicode))

        let selectWhereResults = try database.query("SELECT * FROM `foo` WHERE bar = '\(unicode)'").wait().first
        XCTAssertNotNil(selectWhereResults)
        XCTAssertEqual(selectWhereResults!.firstValue(forColumn: "bar"), .text(unicode))
    }

    func testBigInts() throws {
        let database = try SQLiteConnection.makeTest()
        let max = Int.max

        _ = try database.query("DROP TABLE IF EXISTS foo").wait()
        _ = try database.query("CREATE TABLE foo (max INT)").wait()
        _ = try database.query("INSERT INTO foo VALUES (?)", [max]).wait()

        if let result = try! database.query("SELECT * FROM foo").wait().first {
            XCTAssertEqual(result.firstValue(forColumn: "max"), .integer(max))
        }
    }

    func testBlob() throws {
        let database = try SQLiteConnection.makeTest()
        let data = Data(bytes: [0, 1, 2])

        _ = try database.query("DROP TABLE IF EXISTS `foo`").wait()
        _ = try database.query("CREATE TABLE foo (bar BLOB(4))").wait()
        _ = try database.query("INSERT INTO foo VALUES (?)", [data]).wait()

        if let result = try database.query("SELECT * FROM foo").wait().first {
            XCTAssertEqual(result.firstValue(forColumn: "bar"), .blob(data))
        } else {
            XCTFail()
        }
    }

    func testError() throws {
        let database = try SQLiteConnection.makeTest()
        do {
            _ = try database.query("asdf").wait()
            XCTFail("Should have errored")
        } catch let error as SQLiteError {
            print(error)
            XCTAssert(error.reason.contains("syntax error"))
        } catch {
            XCTFail("wrong error")
        }
    }

    // https://github.com/vapor/sqlite/issues/33
    func testDecodeSameColumnName() throws {
        let row: [SQLiteColumn: SQLiteData] = [
            SQLiteColumn(table: "foo", name: "id"): .text("foo"),
            SQLiteColumn(table: "bar", name: "id"): .text("bar"),
        ]
        struct User: Decodable {
            var id: String
        }
        try XCTAssertEqual(SQLiteRowDecoder().decode(User.self, from: row, table: "foo").id, "foo")
        try XCTAssertEqual(SQLiteRowDecoder().decode(User.self, from: row, table: "bar").id, "bar")
    }

    func testMultiThreading() throws {
        let db = try SQLiteDatabase(storage: .memory)
        let elg = MultiThreadedEventLoopGroup(numberOfThreads: 2)
        let a = elg.next()
        let b = elg.next()
        let group = DispatchGroup()
        group.enter()
        DispatchQueue.global().async {
            let conn = try! db.newConnection(on: a).wait()
            for i in 0..<100 {
                print("a \(i)")
                let res = try! conn.query("SELECT (1 + 1) as a;").wait()
                print(res)
            }
            group.leave()
        }
        group.enter()
        DispatchQueue.global().async {
            let conn = try! db.newConnection(on: b).wait()
            for i in 0..<100 {
                print("b \(i)")
                let res = try! conn.query("SELECT (1 + 1) as b;").wait()
                print(res)
            }
            group.leave()
        }
        group.wait()
    }

    static let allTests = [
        ("testVersion", testVersion),
        ("testVersionBuild", testVersionBuild),
        ("testSQL", testSQL),
        ("testTables", testTables),
        ("testUnicode", testUnicode),
        ("testBigInts", testBigInts),
        ("testBlob", testBlob),
        ("testError", testError),
        ("testDecodeSameColumnName", testDecodeSameColumnName),
        ("testMultiThreading", testMultiThreading),
    ]
}
