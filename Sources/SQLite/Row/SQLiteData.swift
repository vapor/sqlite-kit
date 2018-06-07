public enum SQLiteData: Equatable {
    case integer(Int)
    case float(Double)
    case text(String)
    case blob(Foundation.Data)
    case null
}

extension SQLiteData: CustomStringConvertible {
    /// Description of data
    public var description: String {
        switch self {
        case .blob(let data):
            return String(data: data, encoding: .utf8) ?? data.hexDebug
        case .float(let float):
            return float.description
        case .integer(let int):
            return int.description
        case .null:
            return "<null>"
        case .text(let text):
            return text
        }
    }
}
