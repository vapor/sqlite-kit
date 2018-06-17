public protocol SQLCollation: SQLSerializable {
    associatedtype Query: SQLQuery
}
