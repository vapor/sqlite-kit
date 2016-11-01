#if os(Linux)
    import CSQLiteLinux
#else
    import CSQLiteMac
#endif

import Node

extension SQLite {
    /**
     Represents a row of data from
     a SQLite table.
     */
    public struct Result {
        
        public struct Row {
            public var data: [String: Node]
            
            init() {
                data = [:]
            }
            /**
                Binds a Result.Row result at a certain position
                to a proper SQLite.DataType enum.
                - parameter i : position in current row
                - parameter pointer : the current sqlite pointer
            */
            public mutating func bind(at i: Int32, pointer: Statement.Pointer) throws {
                //Retrieve column name at i
                let name = sqlite3_column_name(pointer, i)
                let column: String
                if let name = name {
                    column = String(cString: name)
                } else {
                    column = ""
                }
                
                //Iterates over possible SQLite datatypes.
                switch sqlite3_column_type(pointer, i) {
                case SQLITE_TEXT:
                    let text = sqlite3_column_text(pointer, i)
                    
                    var value: String = ""
                    if let text = text {
                        value = String(cString: text)
                        
                    }
                    
                    data[column] = .string(value)
                    
                case SQLITE_INTEGER:
                    let integer = Int(sqlite3_column_int(pointer, i))
                    data[column] = .number(.int(integer))
                    
                case SQLITE_FLOAT: // as in floating point, actually returns a double.
                    let double = Double(sqlite3_column_double(pointer, i))
                    data[column] = .number(.double(double))
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
