#if os(Linux)
    import CSQLiteLinux
#else
    import CSQLiteMac
#endif

extension SQLite {
    /**
     Represents a row of data from
     a SQLite table.
     */
    public struct Result {
        
        public struct Row {
            public var data: [String: DataType]
            
            init() {
                data = [:]
            }
            
            public mutating func bind(at i: Int32, pointer: Statement.Pointer) throws {
                let name = sqlite3_column_name(pointer, i)
                
                let column: String
                if let name = name {
                    column = String(cString: name)
                } else {
                    column = ""
                }
                
                switch sqlite3_column_type(pointer, i) {
                case SQLITE_TEXT:
                    let text = sqlite3_column_text(pointer, i)
                    
                    var value: String = ""
                    if let text = text {
                        value = String(cString: text)
                        
                    }
                    
                    data[column] = .text(value)
                    
                case SQLITE_INTEGER:
                    let integer = sqlite3_column_int(pointer, i)
                    data[column] = .integer(Int(integer))
                    
                case SQLITE_FLOAT: // as in floating number, actually returns a double.
                    let double = Double(sqlite3_column_double(pointer, i))
                    data[column] = .double(double)
                case SQLITE_NULL:
                    data[column] = .null
                    
                default:
                    throw SQLiteError.execute("unsupported type")
                }
            }
            
        }
        
        var rows: [Row]
        
        init() {
            rows = []
        }
    }
}
