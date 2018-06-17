/// Types conforming to this protocol can implement custom logic for converting to
/// a `SQLiteQuery.Expression`. Conformance to this protocol will be checked when using
/// `SQLiteQueryExpressionEncoder` and `SQLiteQueryEncoder`.
///
/// By default, types will encode to `SQLiteQuery.Expression.data(...)`.
public protocol SQLiteQueryExpressionRepresentable {
    /// Custom `SQLiteQuery.Expression` to encode to. 
    var sqliteQueryExpression: SQLiteExpression { get }
}
