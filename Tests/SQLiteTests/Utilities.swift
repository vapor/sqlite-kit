import XCTest
@testable import SQLite

extension SQLite {
    static func makeTestConnection() -> SQLite? {
        do {
            let sqlite = try SQLite(path:"test_database.sqlite")
            return sqlite
            
        } catch {
            XCTFail()
        }
        return nil
    }
}
