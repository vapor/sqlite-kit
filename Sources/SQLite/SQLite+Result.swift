import CSQLite
import Node
import typealias Core.Bytes

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
                
                //Iterates over possible SQLite data types.
                switch sqlite3_column_type(pointer, i) {
                case SQLITE_TEXT:
                    let text = sqlite3_column_text(pointer, i)
                    
                    var value: String = ""
                    if let text = text {
                        value = String(cString: text)
                        
                    }
                    
                    data[column] = .string(value)
                    
                case SQLITE_BLOB:
                    if let blobPointer = sqlite3_column_blob(pointer, i) {
                        let length = Int(sqlite3_column_bytes(pointer, i))
                        
                        let i8bufptr = UnsafeBufferPointer(start: blobPointer.assumingMemoryBound(to: Bytes.Element.self), count: length)
                        
                        data[column] = .bytes(Bytes(i8bufptr))
                    } else {
                        // The return value from sqlite3_column_blob() for a zero-length BLOB is a NULL pointer.
                        // https://www.sqlite.org/c3ref/column_blob.html
                        data[column] = .bytes([])
                    }
                    
                case SQLITE_INTEGER:
                    let integer = Int(sqlite3_column_int64(pointer, i))
                    data[column] = .number(.int(integer))
                    
                case SQLITE_FLOAT: // as in floating point, actually returns a double.
                    let double = Double(sqlite3_column_double(pointer, i))
                    data[column] = .number(.double(double))
                case SQLITE_NULL:
                    data[column] = .null
                    
                default:
                    throw StatusError.misuse("unsupported type")
                }
            }
            
        }
        
        var rows: [Row]
        
        init() {
            rows = []
        }
    }
}
