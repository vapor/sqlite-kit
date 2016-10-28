import XCTest
@testable import SQLite
import Node

class SQLite3Tests: XCTestCase {
    static let allTests = [("testTables", testTables),
                           ("testUnicode", testUnicode)]

    var database:SQLite!

    override func setUp() {
        self.database = SQLite.makeTestConnection()
    }

    func testTables() {
        do {
            try _ = database.execute("DROP TABLE IF EXISTS foo")
            try _ = database.execute("CREATE TABLE foo (bar INT(4), baz VARCHAR(16), biz FLOAT)")
            try _ = database.execute("INSERT INTO foo VALUES (42, 'Life', 0.44)")
            try _ = database.execute("INSERT INTO foo VALUES (1337, 'Elite', 209.234)")
            try _ = database.execute("INSERT INTO foo VALUES (9, NULL, 34.567)")

            if let resultBar = try database.execute("SELECT * FROM foo WHERE bar = 42").first {
                XCTAssertEqual(resultBar.data["bar"], 42)
                XCTAssertEqual(resultBar.data["baz"], "Life")
                XCTAssertEqual(resultBar.data["biz"], 0.44)
            } else {
                XCTFail("Could not get bar result")
            }


            if let resultBaz = try database.execute("SELECT * FROM foo where baz = 'Elite'").first {
                XCTAssertEqual(resultBaz.data["bar"], 1337)
                XCTAssertEqual(resultBaz.data["baz"], "Elite")
            } else {
                XCTFail("Could not get baz result")
            }

            if let resultBaz = try database.execute("SELECT * FROM foo where bar = 9").first {
                XCTAssertEqual(resultBaz.data["bar"], 9)
                XCTAssertEqual(resultBaz.data["baz"], .null)
            } else {
                XCTFail("Could not get null result")
            }
        } catch {
            XCTFail("Testing tables failed: \(error)")
        }
    }

    func testUnicode() {

        do {

            /**
                This string includes characters from most Unicode categories
                such as Latin, Latin-Extended-A/B, Cyrrilic, Greek etc.
            */
            let unicode = "®¿ÐØ×ĞƋƢǂǊǕǮȐȘȢȱȵẀˍΔῴЖ♆"
            try _ = database.execute("DROP TABLE IF EXISTS `foo`")
            try _ = database.execute("CREATE TABLE `foo` (bar TEXT)")
            try _ = database.execute("INSERT INTO `foo` VALUES(?)") { statement in
                try statement.bind(unicode)
            }
            
            let selectAllResults = try database.execute("SELECT * FROM `foo`").first
            XCTAssertNotNil(selectAllResults)
            XCTAssertEqual(selectAllResults!.data["bar"]?.string, unicode)
            
            let selectWhereResults = try database.execute("SELECT * FROM `foo` WHERE bar = '\(unicode)'").first
            XCTAssertNotNil(selectWhereResults)
            XCTAssertEqual(selectWhereResults!.data["bar"]?.string, unicode)
            
        } catch {
            XCTFail(error.localizedDescription)
        }

    }

}
