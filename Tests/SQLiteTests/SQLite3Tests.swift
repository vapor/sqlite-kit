import XCTest
@testable import SQLite

class SQLite3Tests: XCTestCase {
    static let allTests = [""]

    var database:SQLite!
    
    override func setUp() {
        self.database = SQLite.makeTestConnection()
    }
    
    func testTables() {
        do {
            try _ = database.execute("DROP TABLE IF EXISTS foo")
            try _ = database.execute("CREATE TABLE foo (bar INT(4), baz VARCHAR(16))")
            try _ = database.execute("INSERT INTO foo VALUES (42, 'Life')")
            try _ = database.execute("INSERT INTO foo VALUES (1337, 'Elite')")
            try _ = database.execute("INSERT INTO foo VALUES (9, NULL)")
            
            if let resultBar = try database.execute("SELECT * FROM foo WHERE bar = 42").first {
                XCTAssertEqual(resultBar.data["bar"], "42")
                XCTAssertEqual(resultBar.data["baz"], "Life")
            } else {
                XCTFail("Could not get bar result")
            }
            
            
            if let resultBaz = try database.execute("SELECT * FROM foo where baz = 'Elite'").first {
                XCTAssertEqual(resultBaz.data["bar"], "1337")
                XCTAssertEqual(resultBaz.data["baz"], "Elite")
            } else {
                XCTFail("Could not get baz result")
            }
            
            if let resultBaz = try database.execute("SELECT * FROM foo where bar = 9").first {
                XCTAssertEqual(resultBaz.data["bar"], "9")
                XCTAssertEqual(resultBaz.data["baz"], nil)
            } else {
                XCTFail("Could not get null result")
            }
        } catch {
            XCTFail("Testing tables failed: \(error)")
        }
    }
    
    func testUnicodeStrings() {
        
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
            
            if let results = try database.execute("SELECT * FROM `foo`").first {
                XCTAssertEqual(results.data["bar"], unicode)
            }
        } catch {
            XCTFail(error.localizedDescription)
        }

    }
    
}
