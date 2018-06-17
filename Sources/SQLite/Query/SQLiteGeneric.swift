/// See `SQLQuery`.
public typealias SQLiteBinaryOperator = GenericSQLBinaryOperator

/// See `SQLQuery`.
public typealias SQLiteColumnConstraintAlgorithm = GenericSQLColumnConstraintAlgorithm<
    SQLiteExpression, SQLiteCollation, SQLitePrimaryKey, SQLiteForeignKey
>

/// See `SQLQuery`.
public typealias SQLiteColumnConstraint = GenericSQLColumnConstraint<
    SQLiteIdentifier, SQLiteColumnConstraintAlgorithm
>

/// See `SQLQuery`.
public typealias SQLiteColumnDefinition = GenericSQLColumnDefinition<
    SQLiteColumnIdentifier, SQLiteDataType, SQLiteColumnConstraint
>

/// See `SQLQuery`.
public typealias SQLiteColumnIdentifier = GenericSQLColumnIdentifier<
    SQLiteTableIdentifier, SQLiteIdentifier
>

/// See `SQLQuery`.
public typealias SQLiteConflictResolution = GenericSQLConflictResolution

/// See `SQLQuery`.
public typealias SQLiteDelete = GenericSQLDelete<
    SQLiteTableIdentifier, SQLiteExpression
>

/// See `SQLQuery`.
public typealias SQLiteDirection = GenericSQLDirection

/// See `SQLQuery`.
public typealias SQLiteDistinct = GenericSQLDistinct

/// See `SQLQuery`.
public typealias SQLiteDropTable = GenericSQLDropTable<SQLiteTableIdentifier>

/// See `SQLQuery`.
public typealias SQLiteExpression = GenericSQLExpression<
    SQLiteLiteral, SQLiteBind, SQLiteColumnIdentifier, SQLiteBinaryOperator, SQLiteFunction, SQLiteQuery
>

/// See `SQLQuery`.
public typealias SQLiteForeignKey = GenericSQLForeignKey<
    SQLiteTableIdentifier, SQLiteIdentifier, SQLiteConflictResolution
>

/// See `SQLQuery`.
public typealias SQLiteGroupBy = GenericSQLGroupBy<SQLiteExpression>

/// See `SQLQuery`.
public typealias SQLiteIdentifier = GenericSQLIdentifier

/// See `SQLQuery`.
public typealias SQLiteInsert = GenericSQLInsert<
    SQLiteTableIdentifier, SQLiteColumnIdentifier, SQLiteExpression
>

/// See `SQLQuery`.
public typealias SQLiteJoin = GenericSQLJoin<
    SQLiteJoinMethod, SQLiteTableIdentifier, SQLiteExpression
>

/// See `SQLQuery`.
public typealias SQLiteJoinMethod = GenericSQLJoinMethod

/// See `SQLQuery`.
public typealias SQLiteLiteral = GenericSQLLiteral

/// See `SQLQuery`.
public typealias SQLiteOrderBy = GenericSQLOrderBy<SQLiteExpression, SQLiteDirection>

/// See `SQLQuery`.
public typealias SQLiteSelect = GenericSQLSelect<
    SQLiteDistinct, SQLiteSelectExpression, SQLiteTableIdentifier, SQLiteJoin, SQLiteExpression, SQLiteGroupBy, SQLiteOrderBy
>

/// See `SQLQuery`.
public typealias SQLiteSelectExpression = GenericSQLSelectExpression<SQLiteExpression>

/// See `SQLQuery`.
public typealias SQLiteTableConstraintAlgorithm = GenericSQLTableConstraintAlgorithm<
    SQLiteColumnIdentifier, SQLiteExpression, SQLiteCollation, SQLitePrimaryKey, SQLiteForeignKey
>

/// See `SQLQuery`.
public typealias SQLiteTableConstraint = GenericSQLTableConstraint<
    SQLiteIdentifier, SQLiteTableConstraintAlgorithm
>

/// See `SQLQuery`.
public typealias SQLiteTableIdentifier = GenericSQLTableIdentifier<SQLiteIdentifier>

/// See `SQLQuery`.
public typealias SQLiteUpdate = GenericSQLUpdate<
    SQLiteTableIdentifier, SQLiteIdentifier, SQLiteExpression
>
