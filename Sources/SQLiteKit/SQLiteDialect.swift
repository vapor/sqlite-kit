import SQLKit

/// The ``SQLDialect`` defintions for SQLite.
///
/// - Note: There is only ever one SQLite library in use by SQLiteNIO in any given process (even if there are
///   other versions of the library being used by other things). As such, there is no need for the dialect to
///   concern itself with what version the connection using it "connected" to - it can always just look up the
///   global "runtime version".
public struct SQLiteDialect: SQLDialect {
    public var name: String { "sqlite" }
    
    public var identifierQuote: SQLExpression { SQLRaw("\"") }
    public var literalStringQuote: SQLExpression { SQLRaw("'") }
    public func bindPlaceholder(at position: Int) -> SQLExpression { SQLRaw("?\(position)") }
    public func literalBoolean(_ value: Bool) -> SQLExpression { SQLRaw(value ? "TRUE" : "FALSE") }
    public var literalDefault: SQLExpression { SQLLiteral.null }

    public var supportsAutoIncrement: Bool { false }
    public var autoIncrementClause: SQLExpression { SQLRaw("AUTOINCREMENT") }

    public var enumSyntax: SQLEnumSyntax { .unsupported }
    public var triggerSyntax: SQLTriggerSyntax { .init(create: [.supportsBody, .supportsCondition]) }
    public var alterTableSyntax: SQLAlterTableSyntax { .init(allowsBatch: false) }
    public var upsertSyntax: SQLUpsertSyntax { self.isAtLeastVersion(3, 24, 0) ? .standard : .unsupported } // `UPSERT` was added to SQLite in 3.24.0.
    public var supportsReturning: Bool { self.isAtLeastVersion(3, 35, 0) } // `RETURNING` was added to SQLite in 3.35.0.
    public var unionFeatures: SQLUnionFeatures { [.union, .unionAll, .intersect, .except] }
    
    public func customDataType(for dataType: SQLDataType) -> SQLExpression? {
        if case .bigint = dataType {
            // Translate requests for bigint to requests for SQLite's plain integer type. This yields the autoincrement
            // primary key behavior when a 64-bit integer is requested from a higher layer.
            return SQLDataType.int
        }
        return nil
    }

    public func nestedSubpathExpression(in column: any SQLExpression, for path: [String]) -> (any SQLExpression)? {
        guard !path.isEmpty else { return nil }
        
        return SQLFunction("json_extract", args: [
            column,
            SQLLiteral.string("$.\(path.joined(separator: "."))")
        ])
    }

    public init() { }
    
    private func isAtLeastVersion(_ major: Int, _ minor: Int, _ patch: Int) -> Bool {
        _SQLiteDatabaseVersion.runtimeVersion.isNotOlder(than: _SQLiteDatabaseVersion(major: major, minor: minor, patch: patch))
    }
}
