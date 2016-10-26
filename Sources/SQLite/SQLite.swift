#if os(Linux)
    import CSQLiteLinux
#else
    import CSQLiteMac
#endif

let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)

public class SQLite {
    /**
        The prepare closure is used
        to bind values to the SQLite statement
        in a safe, escaped manner.
    */
    public typealias PrepareClosure = ((Statement) throws -> ())

    /**
        Provides more useful type
        information for the Database pointer.
    */
    public typealias Database = OpaquePointer

    /**
        An optional pointer to the
        connection to the SQLite database.
    */
    public var database: Database?

    /**
        Opens a connection to the SQLite
        database at a given path.
     
        If the database does not already exist,
        it will be created.
    */
    public init(path: String) throws {
        let options = SQLITE_OPEN_CREATE | SQLITE_OPEN_READWRITE | SQLITE_OPEN_FULLMUTEX
        if sqlite3_open_v2(path, &database, options, nil) != SQLITE_OK {
            throw SQLiteError.connection(database?.errorMessage ?? "")
        }
    }

    /**
        Closes a connetion to the database.
    */
    public func close() {
        sqlite3_close(database)
    }

    /**
        Closes the database when deinitialized.
    */
    deinit {
        self.close()
    }

    /**
        Executes a statement query string
        and calls the prepare closure to bind
        any prepared values.
     
        The resulting rows are returned if
        no errors occur.
    */
    public func execute(_ queryString: String, prepareClosure: PrepareClosure = { _ in }) throws -> [Result.Row] {
        guard let database = self.database else {
            throw SQLiteError.execute("No database")
        }

        let statementContainer = UnsafeMutablePointer<OpaquePointer?>.allocate(capacity: 1)
        defer {
            statementContainer.deallocate(capacity: 1)
        }

        if sqlite3_prepare_v2(database, queryString, -1, statementContainer, nil) != SQLITE_OK {
            throw SQLiteError.prepare(database.errorMessage)
        }

        guard let statementPointer = statementContainer.pointee else {
            throw SQLiteError.execute("Statement pointer errror")
        }

        let statement = Statement(pointer: statementPointer, database: database)
        try prepareClosure(statement)

        var result = Result()
        while sqlite3_step(statement.pointer) == SQLITE_ROW {
            
            var row = Result.Row()
            let count = sqlite3_column_count(statement.pointer)

            for i in 0..<count {
                let name = sqlite3_column_name(statement.pointer, i)
                
                let column: String
                if let name = name {
                    column = String(cString: name)
                } else {
                    column = ""
                }
                
                switch sqlite3_column_type(statement.pointer, i) {
                case SQLITE_TEXT:
                    let text = sqlite3_column_text(statement.pointer, i)
                    
                    var value: String = ""
                    if let text = text {
                        value = String(cString: text)
                    
                    }
                    
                    row.data[column] = .text(value)
                    
                case SQLITE_INTEGER:
                    let integer = sqlite3_column_int(statement.pointer, i)
                    row.data[column] = .integer(Int(integer))
                    
                case SQLITE_FLOAT:
                    let double = Double(sqlite3_column_double(statement.pointer, i))
                    row.data[column] = .double(double)
                case SQLITE_NULL:
                    row.data[column] = .null
                    
                default:
                    throw SQLiteError.execute("unsupported type")
                }

            }

            result.rows.append(row)
        }
        
        if sqlite3_finalize(statement.pointer) != SQLITE_OK {
            throw SQLiteError.execute(database.errorMessage)
        }
        
        return result.rows
    }

    /**
        Returns an identifier for the last
        inserted row.
    */
    public var lastId: Int? {
        guard let database = database else {
            return nil
        }

        let id = sqlite3_last_insert_rowid(database)
        return Int(id)
    }

    //MARK: Error
    public enum SQLiteError: Error {
        case connection(String)
        case close(String)
        case prepare(String)
        case bind(String)
        case execute(String)
    }
}

extension SQLite {
    /**
        Represents a row of data from
        a SQLite table.
    */
    public struct Result {
        
        public enum DataType {
            case integer(Int)
            case text(String)
            case double(Double)
            case null
        }
        
        public struct Row {
            public var data: [String: DataType]

            init() {
                data = [:]
            }
            
        }

        var rows: [Row]

        init() {
            rows = []
        }
    }
}

extension SQLite.Database {
    /**
        Returns the last error message
        for the current database connection.
    */
    var errorMessage: String {
        if let raw = sqlite3_errmsg(self) {
            return String(cString: raw)
        } else {
            return "Unknown"
        }
    }

}

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
            let strlen = Int32(value.utf8CString.count)
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

