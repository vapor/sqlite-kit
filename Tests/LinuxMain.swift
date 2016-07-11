#if os(Linux)

import XCTest
@testable import SQLiteTestSuite

XCTMain([
    testCase(SQLite3Tests.allTests),
])

#endif