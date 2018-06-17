public protocol SQLDataType: SQLSerializable {
    associatedtype Query: SQLQuery
}
