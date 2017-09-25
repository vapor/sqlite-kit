import CSQLite
import typealias Core.Bytes

extension SQLite {
    /**
     Represents a single database statement.
     The statement is used to bind prepared
     values and contains a pointer to the
     underlying SQLite statement memory.
     */
    public class Statement {
        public typealias Pointer = OpaquePointer
        
        public var pointer: Pointer
        public var database: Database
        
        var bindPosition: Int32
        var nextBindPosition: Int32 {
            bindPosition += 1
            return bindPosition
        }
        
        public init(pointer: Pointer, database: Database) {
            self.pointer = pointer
            self.database = database
            bindPosition = 0
        }
        
        public func reset(_ statementPointer: OpaquePointer) {
            sqlite3_reset(statementPointer)
            sqlite3_clear_bindings(statementPointer)
        }
        
        public func bind(_ value: Double) throws {
            let status = sqlite3_bind_double(pointer, nextBindPosition, value)

            try StatusError.check(with: status, msg: database.errorMessage)
        }
        
        public func bind(_ value: Int) throws {
            let status = sqlite3_bind_int64(pointer, nextBindPosition, Int64(value))

            try StatusError.check(with: status, msg: database.errorMessage)

        }
        
        public func bind(_ value: String) throws {
            let strlen = Int32(value.utf8.count)

            let status = sqlite3_bind_text(pointer, nextBindPosition, value, strlen, SQLITE_TRANSIENT)

            try StatusError.check(with: status, msg: database.errorMessage)
        }
        
        public func bind(_ value: Bytes) throws {
            let count = Int32(value.count)

            let status = sqlite3_bind_blob(pointer, nextBindPosition, value, count, SQLITE_TRANSIENT)

            try StatusError.check(with: status, msg: database.errorMessage)
        }
        
        public func bind(_ value: Bool) throws {
            try bind(value ? 1 : 0)
        }

        public func null()  throws {
            let status = sqlite3_bind_null(pointer, nextBindPosition)

            try StatusError.check(with: status, msg: database.errorMessage)
        }
    }

}
