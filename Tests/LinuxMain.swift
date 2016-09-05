#if os(Linux)

import XCTest
@testable import SQLite3Tests

XCTMain([
    testCase(SQLite3Tests.allTests),
])

#endif
