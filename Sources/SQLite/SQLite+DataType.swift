extension SQLite {
    /**
     enumerates all possible SQLite datatypes :
     - integer
     - text
     - double
     - null
     */
    public enum DataType: Equatable {
        case integer(Int)
        case text(String)
        case double(Double)
        case null
        
        static public func ==(lhs: SQLite.DataType, rhs: SQLite.DataType) -> Bool {
            switch (lhs, rhs) {
            case (.double(let double1), .double(let double2)):
                return double1 == double2
            case (.text(let string1), .text(let string2)):
                return string1 == string2
            case (.integer(let int1), .integer(let int2)):
                return int1 == int2
            case (.null, .null):
                return true
            default:
                return false
            }
        }
    }
}
