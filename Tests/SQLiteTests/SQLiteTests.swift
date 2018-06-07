import SQLite
import XCTest

struct Planet: SQLiteTable {
    var id: Int?
    var name: String
    init(id: Int? = nil, name: String) {
        self.id = id
        self.name = name
    }
}

class SQLiteTests: XCTestCase {
    func testSQLQuery() throws {     
        let conn = try SQLiteConnection.makeTest()
        _ = try conn.query("DROP TABLE IF EXISTS `Planet`").wait()
        _ = try conn.query("CREATE TABLE `Planet` (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT)").wait()
        
        try conn.insert(into: Planet.self)
            .value(Planet(name: "Earth"))
            .run().wait()
        try conn.insert(into: Planet.self)
            .values([Planet(name: "Jupiter"), Planet(name: "Mars")])
            .run().wait()
        
        let res = try conn.select().columns(.all(nil))
            .from(Planet.self)
            .where {
                try $0.where(or: \Planet.name == "Mars", \Planet.name == "Jupiter", \Planet.name == "Earth")
            }
            .where(\Planet.id != 42)
            .all(Planet.self).wait()
        print(res)
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
        
        _ = try database.query("INSERT INTO `foo` VALUES(?)", [unicode.convertToSQLiteData()]).wait()
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
        _ = try database.query("INSERT INTO foo VALUES (?)", [max.convertToSQLiteData()]).wait()
        
        if let result = try! database.query("SELECT * FROM foo").wait().first {
            XCTAssertEqual(result.firstValue(forColumn: "max"), .integer(max))
        }
    }
    
    func testBlob() throws {
        let database = try SQLiteConnection.makeTest()
        let data = Data(bytes: [0, 1, 2])
        
        _ = try database.query("DROP TABLE IF EXISTS `foo`").wait()
        _ = try database.query("CREATE TABLE foo (bar BLOB(4))").wait()
        _ = try database.query("INSERT INTO foo VALUES (?)", [data.convertToSQLiteData()]).wait()
        
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
    
    static let allTests = [
        ("testTables", testTables),
        ("testUnicode", testUnicode),
        ("testBigInts", testBigInts),
        ("testBlob", testBlob),
        ("testError", testError)
    ]
}
