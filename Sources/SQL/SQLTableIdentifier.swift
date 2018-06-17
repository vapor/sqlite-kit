public protocol SQLTableIdentifier: SQLSerializable {
    associatedtype Identifier: SQLIdentifier
    
    static func table(_ identifier: Identifier) -> Self
    var identifier: Identifier { get set }
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

public struct GenericSQLTableIdentifier<Identifier>: SQLTableIdentifier
    where Identifier: SQLIdentifier
{
    /// See `SQLTableIdentifier`.
    public static func table(_ identifier: Identifier) -> GenericSQLTableIdentifier<Identifier> {
        return .init(identifier: identifier)
    }
    
    /// See `SQLTableIdentifier`.
    public var identifier: Identifier
    
    /// See `SQLSerializable`.
    public func serialize(_ binds: inout [Encodable]) -> String {
        return identifier.serialize(&binds)
    }
}
