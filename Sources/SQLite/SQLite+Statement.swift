import CSQLite

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
            if sqlite3_bind_double(pointer, nextBindPosition, value) != SQLITE_OK {
                throw SQLiteError.bind(database.errorMessage)
            }
        }
        
        public func bind(_ value: Int) throws {
            if sqlite3_bind_int(pointer, nextBindPosition, Int32(value)) != SQLITE_OK {
                throw SQLiteError.bind(database.errorMessage)
            }
        }
        
        public func bind(_ value: String) throws {
            let strlen = Int32(value.utf8.count)
            if sqlite3_bind_text(pointer, nextBindPosition, value, strlen, SQLITE_TRANSIENT) != SQLITE_OK {
                throw SQLiteError.bind(database.errorMessage)
            }
        }
        
        public func bind(_ value: Bool) throws {
            try bind(value ? 1 : 0)
        }
        
        
        public func null()  throws {
            if sqlite3_bind_null(pointer, nextBindPosition) != SQLITE_OK {
                throw SQLiteError.bind(database.errorMessage)
            }
        }
    }
}
