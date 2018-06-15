/// - warning: Deprecated.
@available(*, deprecated, renamed: "SQLiteDataType")
public typealias SQLiteFieldType = SQLiteDataType

extension SQLiteStorage {
    /// - warning: Deprecated
    @available(*, deprecated, renamed: "temporary")
    public static var memory: SQLiteStorage {
        return .temporary
    }
}
