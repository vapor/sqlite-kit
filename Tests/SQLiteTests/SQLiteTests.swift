import Async
import Core
@testable import SQLite
import XCTest

class SQLiteTests: XCTestCase {
    func testTables() throws {
        let database = try SQLiteConnection.makeTest()
        try database.query("DROP TABLE IF EXISTS foo").run().wait()
        try database.query("CREATE TABLE foo (bar INT(4), baz VARCHAR(16), biz FLOAT)").run().wait()
        try database.query("INSERT INTO foo VALUES (42, 'Life', 0.44)").run().wait()
        try database.query("INSERT INTO foo VALUES (1337, 'Elite', 209.234)").run().wait()
        try database.query("INSERT INTO foo VALUES (9, NULL, 34.567)").run().wait()

        if let resultBar = try database.query("SELECT * FROM foo WHERE bar = 42").all().wait().first {
            XCTAssertEqual(resultBar["bar"]?.integer, 42)
            XCTAssertEqual(resultBar["baz"]?.text, "Life")
            XCTAssertEqual(resultBar["biz"]?.float, 0.44)
        } else {
            XCTFail("Could not get bar result")
        }


        if let resultBaz = try database.query("SELECT * FROM foo where baz = 'Elite'").all().wait().first {
            XCTAssertEqual(resultBaz["bar"]?.integer, 1337)
            XCTAssertEqual(resultBaz["baz"]?.text, "Elite")
        } else {
            XCTFail("Could not get baz result")
        }

        if let resultBaz = try database.query("SELECT * FROM foo where bar = 9").all().wait().first {
            XCTAssertEqual(resultBaz["bar"]?.integer, 9)
            XCTAssertEqual(resultBaz["baz"]?.isNull, true)
        } else {
            XCTFail("Could not get null result")
        }
    }

    func testUnicode() throws {
        let database = try SQLiteConnection.makeTest()
        /// This string includes characters from most Unicode categories
        /// such as Latin, Latin-Extended-A/B, Cyrrilic, Greek etc.
        let unicode = "®¿ÐØ×ĞƋƢǂǊǕǮȐȘȢȱȵẀˍΔῴЖ♆"
        try database.query("DROP TABLE IF EXISTS `foo`").run().wait()
        try database.query("CREATE TABLE `foo` (bar TEXT)").run().wait()

        try database.query("INSERT INTO `foo` VALUES(?)").bind(unicode).run().wait()
        let selectAllResults = try database.query("SELECT * FROM `foo`").all().wait().first
        XCTAssertNotNil(selectAllResults)
        XCTAssertEqual(selectAllResults!["bar"]?.text, unicode)

        let selectWhereResults = try database.query("SELECT * FROM `foo` WHERE bar = '\(unicode)'").all().wait().first
        XCTAssertNotNil(selectWhereResults)
        XCTAssertEqual(selectWhereResults!["bar"]?.text, unicode)
    }

    func testBigInts() throws {
        let database = try SQLiteConnection.makeTest()
        let max = Int.max

        try database.query("DROP TABLE IF EXISTS foo").run().wait()
        try database.query("CREATE TABLE foo (max INT)").run().wait()
        try database.query("INSERT INTO foo VALUES (?)") .bind(max).run().wait()

        if let result = try! database.query("SELECT * FROM foo").all().wait().first {
            XCTAssertEqual(result["max"]?.integer, max)
        }
    }

    func testBlob() throws {
        let database = try SQLiteConnection.makeTest()
        let data = Data(bytes: [0, 1, 2])

        try database.query("DROP TABLE IF EXISTS `foo`").run().wait()
        try database.query("CREATE TABLE foo (bar BLOB(4))").run().wait()
        try database.query("INSERT INTO foo VALUES (?)").bind(data).run().wait()

        if let result = try database.query("SELECT * FROM foo").all().wait().first {
            XCTAssertEqual(result["bar"]!.blob, data)
        } else {
            XCTFail()
        }
    }

    func testError() throws {
        let database = try SQLiteConnection.makeTest()
        do {
            try database.query("asdf").run().wait()
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

extension SQLiteConnection {
    func query(_ string: String) throws -> SQLiteQuery {
        return SQLiteQuery(string: string, connection: self)
    }
}
