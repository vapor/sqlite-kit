public protocol SQLDirection: SQLSerializable {
    associatedtype Query: SQLQuery
    static var ascending: Self { get }
    static var descending: Self { get }
}

// MARK: Generic

public enum GenericSQLDirection<Query>: SQLDirection where Query: SQLQuery {
    public typealias `Self` = GenericSQLDirection<Query>

    /// See `SQLDirection`.
    public static var ascending: Self {
        return ._ascending
    }
    
    /// See `SQLDirection`.
    public static var descending: Self {
        return ._descending
    }
    
    case _ascending
    case _descending
    
    /// See `SQLSerializable`.
    public func serialize(_ binds: inout [Encodable]) -> String {
        switch self {
        case ._ascending: return "ASC"
        case ._descending: return "DESC"
        }
    }
}
