infix operator ~~
infix operator !~
//
//// MARK: Expression to Expression operators
//
//public func < (_ lhs: SQLiteQuery.Expression, _ rhs: SQLiteQuery.Expression) -> SQLiteQuery.Expression {
//    return .binary(lhs, .lessThan, rhs)
//}
//
//public func <= (_ lhs: SQLiteQuery.Expression, _ rhs: SQLiteQuery.Expression) -> SQLiteQuery.Expression {
//    return .binary(lhs, .lessThanOrEqual, rhs)
//}
//
//public func > (_ lhs: SQLiteQuery.Expression, _ rhs: SQLiteQuery.Expression) -> SQLiteQuery.Expression {
//    return .binary(lhs, .greaterThan, rhs)
//}
//
//public func >= (_ lhs: SQLiteQuery.Expression, _ rhs: SQLiteQuery.Expression) -> SQLiteQuery.Expression {
//    return .binary(lhs, .greaterThanOrEqual, rhs)
//}
//
//public func == (_ lhs: SQLiteQuery.Expression, _ rhs: SQLiteQuery.Expression) -> SQLiteQuery.Expression {
//    return .binary(lhs, .equal, rhs)
//}
//
//public func != (_ lhs: SQLiteQuery.Expression, _ rhs: SQLiteQuery.Expression) -> SQLiteQuery.Expression {
//    return .binary(lhs, .notEqual, rhs)
//}
//
//public func ~~ (_ lhs: SQLiteQuery.Expression, _ rhs: [SQLiteQuery.Expression]) -> SQLiteQuery.Expression {
//    return .binary(lhs, .in, .expressions(rhs))
//}
//
//public func !~ (_ lhs: SQLiteQuery.Expression, _ rhs: [SQLiteQuery.Expression]) -> SQLiteQuery.Expression {
//    return .binary(lhs, .notIn, .expressions(rhs))
//}
//
//// MARK: KeyPath to Value operators
//
//public func < <Table, Value>(_ lhs: KeyPath<Table, Value>, _ rhs: Value) throws -> SQLiteQuery.Expression
//    where Table: SQLiteTable, Value: Encodable
//{
//    return try .binary(.column(lhs.sqliteColumnName), .lessThan, .bind(rhs))
//}
//
//public func <= <Table, Value>(_ lhs: KeyPath<Table, Value>, _ rhs: Value) throws -> SQLiteQuery.Expression
//    where Table: SQLiteTable, Value: Encodable
//{
//    return try .binary(.column(lhs.sqliteColumnName), .lessThanOrEqual, .bind(rhs))
//}
//
//public func > <Table, Value>(_ lhs: KeyPath<Table, Value>, _ rhs: Value) throws -> SQLiteQuery.Expression
//    where Table: SQLiteTable, Value: Encodable
//{
//    return try .binary(.column(lhs.sqliteColumnName), .greaterThan, .bind(rhs))
//}
//
//public func >= <Table, Value>(_ lhs: KeyPath<Table, Value>, _ rhs: Value) throws -> SQLiteQuery.Expression
//    where Table: SQLiteTable, Value: Encodable
//{
//    return try .binary(.column(lhs.sqliteColumnName), .greaterThanOrEqual, .bind(rhs))
//}
//
//public func == <Table, Value>(_ lhs: KeyPath<Table, Value>, _ rhs: Value) throws -> SQLiteQuery.Expression
//    where Table: SQLiteTable, Value: Encodable
//{
//    return try .binary(.column(lhs.sqliteColumnName), .equal, .bind(rhs))
//}
//
//public func != <Table, Value>(_ lhs: KeyPath<Table, Value>, _ rhs: Value) throws -> SQLiteQuery.Expression
//    where Table: SQLiteTable, Value: Encodable
//{
//    return try .binary(.column(lhs.sqliteColumnName), .notEqual, .bind(rhs))
//}
//
//public func ~~ <Table, Value>(_ lhs: KeyPath<Table, Value>, _ rhs: Value) throws -> SQLiteQuery.Expression
//    where Table: SQLiteTable, Value: Encodable
//{
//    return try .binary(.column(lhs.sqliteColumnName), .in, .bind(rhs))
//}
//
//public func !~ <Table, Value>(_ lhs: KeyPath<Table, Value>, _ rhs: Value) throws -> SQLiteQuery.Expression
//    where Table: SQLiteTable, Value: Encodable
//{
//    return try .binary(.column(lhs.sqliteColumnName), .notIn, .bind(rhs))
//}
//
//// MARK: KeyPath to KeyPath operators
//
//public func < <TableA, ValueA, TableB, ValueB>(_ lhs: KeyPath<TableA, ValueA>, _ rhs: KeyPath<TableB, ValueB>) -> SQLiteQuery.Expression
//    where TableA: SQLiteTable, ValueA: Encodable, TableB: SQLiteTable, ValueB: Encodable
//{
//    return .binary(.column(lhs.sqliteColumnName), .lessThan, .column(rhs.sqliteColumnName))
//}
//
//public func <= <TableA, ValueA, TableB, ValueB>(_ lhs: KeyPath<TableA, ValueA>, _ rhs: KeyPath<TableB, ValueB>) -> SQLiteQuery.Expression
//    where TableA: SQLiteTable, ValueA: Encodable, TableB: SQLiteTable, ValueB: Encodable
//{
//    return .binary(.column(lhs.sqliteColumnName), .lessThanOrEqual, .column(rhs.sqliteColumnName))
//}
//
//public func > <TableA, ValueA, TableB, ValueB>(_ lhs: KeyPath<TableA, ValueA>, _ rhs: KeyPath<TableB, ValueB>) -> SQLiteQuery.Expression
//    where TableA: SQLiteTable, ValueA: Encodable, TableB: SQLiteTable, ValueB: Encodable
//{
//    return .binary(.column(lhs.sqliteColumnName), .greaterThan, .column(rhs.sqliteColumnName))
//}
//
//public func >= <TableA, ValueA, TableB, ValueB>(_ lhs: KeyPath<TableA, ValueA>, _ rhs: KeyPath<TableB, ValueB>) -> SQLiteQuery.Expression
//    where TableA: SQLiteTable, ValueA: Encodable, TableB: SQLiteTable, ValueB: Encodable
//{
//    return .binary(.column(lhs.sqliteColumnName), .greaterThanOrEqual, .column(rhs.sqliteColumnName))
//}
//
//public func == <TableA, ValueA, TableB, ValueB>(_ lhs: KeyPath<TableA, ValueA>, _ rhs: KeyPath<TableB, ValueB>) -> SQLiteQuery.Expression
//    where TableA: SQLiteTable, ValueA: Encodable, TableB: SQLiteTable, ValueB: Encodable
//{
//    return .binary(.column(lhs.sqliteColumnName), .equal, .column(rhs.sqliteColumnName))
//}
//
//public func != <TableA, ValueA, TableB, ValueB>(_ lhs: KeyPath<TableA, ValueA>, _ rhs: KeyPath<TableB, ValueB>) -> SQLiteQuery.Expression
//    where TableA: SQLiteTable, ValueA: Encodable, TableB: SQLiteTable, ValueB: Encodable
//{
//    return .binary(.column(lhs.sqliteColumnName), .notEqual, .column(rhs.sqliteColumnName))
//}
//
//public func ~~ <TableA, ValueA, TableB, ValueB>(_ lhs: KeyPath<TableA, ValueA>, _ rhs: KeyPath<TableB, ValueB>) -> SQLiteQuery.Expression
//    where TableA: SQLiteTable, ValueA: Encodable, TableB: SQLiteTable, ValueB: Encodable
//{
//    return .binary(.column(lhs.sqliteColumnName), .in, .column(rhs.sqliteColumnName))
//}
//
//public func !~ <TableA, ValueA, TableB, ValueB>(_ lhs: KeyPath<TableA, ValueA>, _ rhs: KeyPath<TableB, ValueB>) -> SQLiteQuery.Expression
//    where TableA: SQLiteTable, ValueA: Encodable, TableB: SQLiteTable, ValueB: Encodable
//{
//    return .binary(.column(lhs.sqliteColumnName), .notIn, .column(rhs.sqliteColumnName))
//}
//
//// MARK: AND / OR operators
//
