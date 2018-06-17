public protocol SQLTableIdentifier: SQLSerializable {
    associatedtype Query: SQLQuery
    
    static func table(_ identifier: Query.Identifier) -> Self
    var identifier: Query.Identifier { get set }
}

// MARK: Convenience

extension SQLTableIdentifier {
    static func table<Table>(_ table: Table.Type) -> Self
        where Table: SQLTable
    {
        return .table(.identifier(Table.sqlTableIdentifierString))
    }
}

// MARK: Generic

public struct GenericSQLTableIdentifier<Query>: where Query: SQLQuery {
    public typealias `Self` = GenericSQLTableIdentifier<Query>

    /// See `SQLTableIdentifier`.
    public static func table(_ identifier: Identifier) -> Self {
        return .init(identifier)
    }
    
    /// See `SQLTableIdentifier`.
    public var identifier: Query.Identifier

    /// Creates a new `GenericSQLTableIdentifier`.
    public init(_ identifier: Query.Identifier) {
        self.identifier = identifier
    }

    /// See `ExpressibleByStringLiteral`.
    public init(stringLiteral value: String) {
        self.identifier = .identifier(value)
    }

    /// See `SQLSerializable`.
    public func serialize(_ binds: inout [Encodable]) -> String {
        return identifier.serialize(&binds)
    }
}
