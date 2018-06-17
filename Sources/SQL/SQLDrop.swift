public protocol SQLDropTable: SQLSerializable {
    associatedtype Query: SQLQuery
    
    /// Creates a new `SQLDropTable`.
    static func dropTable(_ table: Query.TableIdentifier, ifExists: Bool) -> Self
    
    /// Table to drop.
    var table: Query.TableIdentifier { get set }
    
    /// The optional IF EXISTS clause suppresses the error that would normally result if the table does not exist.
    var ifExists: Bool { get set }
}

public struct GenericSQLDropTable<Query>: SQLDropTable where Query: SQLQuery {
    public typealias `Self` = GenericSQLDropTable<Query>

    /// See `SQLDropTable`.
    public static func dropTable(_ table: Query.TableIdentifier, ifExists: Bool) -> Self {
        return .init(table: table, ifExists: ifExists)
    }
 
    /// See `SQLDropTable`.
    public var table: Query.TableIdentifier
    
    /// See `SQLDropTable`.
    public var ifExists: Bool

    /// See `SQLSerializable`.
    public func serialize(_ binds: inout [Encodable]) -> String {
        var sql: [String] = []
        sql.append("DROP TABLE")
        if ifExists {
            sql.append("IF EXISTS")
        }
        sql.append(table.serialize(&binds))
        return sql.joined(separator: " ")
    }
}
