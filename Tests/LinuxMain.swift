#if os(Linux)

import XCTest
@testable import SQLiteTests

XCTMain([
    // SQlite
    testCase(SQLiteTests.allTests),
])

#endif
