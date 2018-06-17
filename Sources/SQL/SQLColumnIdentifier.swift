public protocol SQLColumnIdentifier: SQLSerializable {
    associatedtype Query: SQLQuery
    
    static func column(_ table: Query.TableIdentifier?, _ identifier: Query.Identifier) -> Self
    
    var table: Query.TableIdentifier? { get set }
    var identifier: Query.Identifier { get set }
}

// MARK: Convenience


extension SQLColumnIdentifier {
    public static func keyPath<T,V>(_ keyPath: KeyPath<T, V>) -> Self where T: SQLTable {
        guard let property = try! T.reflectProperty(forKey: keyPath) else {
            fatalError("Could not reflect property of type \(V.self) on \(T.self): \(keyPath)")
        }
        return .column(.table(.identifier(T.sqlTableIdentifierString)), .identifier(property.path[0]))
    }
}
extension SQLTableIdentifier {
    public static func keyPath<T,V>(_ keyPath: KeyPath<T, V>) -> Self where T: SQLTable {
        return .table(.identifier(T.sqlTableIdentifierString))
    }
}

extension SQLIdentifier {
    public static func keyPath<T,V>(_ keyPath: KeyPath<T, V>) -> Self where T: SQLTable {
        guard let property = try! T.reflectProperty(forKey: keyPath) else {
            fatalError("Could not reflect property of type \(V.self) on \(T.self): \(keyPath)")
        }
        return .identifier(property.path[0])
    }
}

// MARK: Generic

public struct GenericSQLColumnIdentifier<Query>: SQLColumnIdentifier where Query: SQLQuery {
    public typealias `Self` = GenericSQLColumnIdentifier<Query>

    /// See `SQLColumnIdentifier`.
    public static func column(_ table: Query.TableIdentifier?, _ identifier:Query. Identifier) -> Self {
        return self.init(table: table, identifier: identifier)
    }
    
    /// See `SQLColumnIdentifier`.
    public var table: Query.TableIdentifier?
    
    /// See `SQLColumnIdentifier`.
    public var identifier: Query.Identifier
    
    /// See `SQLSerializable`.
    public func serialize(_ binds: inout [Encodable]) -> String {
        switch table {
        case .some(let table): return table.serialize(&binds) + "." + identifier.serialize(&binds)
        case .none: return identifier.serialize(&binds)
        }
    }
}
