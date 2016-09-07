#if os(Linux)

import XCTest
@testable import SQLiteTests

XCTMain([
    testCase(SQLite3Tests.allTests),
])

#endif
