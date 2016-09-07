import XCTest
@testable import SQLite

class SQLite3Tests: XCTestCase {
    static let allTests = [
       ("testReality", testReality)
    ]

    func testReality() {
        XCTAssert(2 + 2 == 4, "Something is seriously wrong.")
    }
}
