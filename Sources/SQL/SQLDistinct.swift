public protocol SQLDistinct: SQLSerializable {
    associatedtype Query: SQLQuery
    static var all: Self { get }
    static var distinct: Self { get }
    var isDistinct: Bool { get }
}

// MARK: Default

extension SQLDistinct {
    public func serialize(_ binds: inout [Encodable]) -> String {
        if isDistinct {
            return "DISTINCT"
        } else {
            return "ALL"
        }
    }
}

// MARK: Generic

public enum GenericSQLDistinct<Query>: SQLDistinct where Query: SQLQuery {
    public typealias `Self` = GenericSQLDistinct<Query>

    /// See `SQLDistinct`.
    public static var all: Self {
        return ._all
    }
    
    /// See `SQLDistinct`.
    public static var distinct: Self {
        return ._distinct
    }
    
    /// See `SQLDistinct`.
    public var isDistinct: Bool {
        switch self {
        case ._all: return false
        case ._distinct: return true
        }
    }
    
    case _distinct
    case _all
}
