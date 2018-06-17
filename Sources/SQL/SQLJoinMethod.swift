public protocol SQLJoinMethod: SQLSerializable {
    associatedtype Query: SQLQuery
    static var `default`: Self { get }
}

public enum GenericSQLJoinMethod<Query>: SQLJoinMethod where Query: SQLQuery {
    public typealias `Self` = GenericSQLJoinMethod<Query>

    /// See `SQLJoinMethod`.
    public static var `default`: Self {
        return .inner
    }
    
    case inner
    case left
    case right
    case full
    
    public func serialize(_ binds: inout [Encodable]) -> String {
        switch self {
        case .inner: return "INNER"
        case .left: return "LEFT"
        case .right: return "RIGHT"
        case .full: return "FULL"
        }
    }
}
