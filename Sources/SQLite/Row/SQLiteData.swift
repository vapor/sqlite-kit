/// Supported SQLite data types.
public enum SQLiteData: Equatable, Encodable {
    /// `Int`.
    case integer(Int)
    
    /// `Double`.
    case float(Double)
    
    /// `String`.
    case text(String)
    
    /// `Data`.
    case blob(Foundation.Data)
    
    /// `NULL`.
    case null
    
    /// See `Encodable`.
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .integer(let value): try container.encode(value)
        case .float(let value): try container.encode(value)
        case .text(let value): try container.encode(value)
        case .blob(let value): try container.encode(value)
        case .null: try container.encodeNil()
        }
    }
}

extension SQLiteData: CustomStringConvertible {
    /// Description of data
    public var description: String {
        switch self {
        case .blob(let data): return "0x" + data.hexEncodedString()
        case .float(let float): return float.description
        case .integer(let int): return int.description
        case .null: return "null"
        case .text(let text): return "\"" + text + "\""
        }
    }
}
