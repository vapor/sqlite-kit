public protocol SQLAlterTable: SQLSerializable {
    associatedtype Query: SQLQuery

    static func alterTable(_ table: Query.TableIdentifier) -> Self
}

// No generic ALTER table is offered since they differ too much
// between SQL dialects
