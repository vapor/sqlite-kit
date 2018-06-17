public protocol SQLQuery: SQLSerializable {
    associatedtype AlterTable: SQLAlterTable
    associatedtype BinaryOperator: SQLBinaryOperator
    associatedtype Bind: SQLBind
    associatedtype CreateTable: SQLCreateTable
    associatedtype Collation: SQLCollation
    associatedtype ColumnConstraint: SQLColumnConstraint
    associatedtype ColumnConstraintAlgorithm: SQLColumnConstraintAlgorithm
    associatedtype ColumnDefinition: SQLColumnDefinition
    associatedtype ColumnIdentifier: SQLColumnIdentifier
    associatedtype ConflictResolution: SQLConflictResolution
    associatedtype DataType: SQLDataType
    associatedtype Delete: SQLDelete
    associatedtype Direction: SQLDirection
    associatedtype Distinct: SQLDistinct
    associatedtype DropTable: SQLDropTable
    associatedtype Expression: SQLExpression
    associatedtype ForeignKey: SQLForeignKey
    associatedtype Function: SQLFunction
    associatedtype FunctionArgument: SQLFunctionArgument
    associatedtype GroupBy: SQLGroupBy
    associatedtype Insert: SQLInsert
    associatedtype Join: SQLJoin
    associatedtype JoinMethod: SQLJoinMethod
    associatedtype Literal: SQLLiteral
    associatedtype OrderBy: SQLOrderBy
    associatedtype PrimaryKey: SQLPrimaryKey
    associatedtype RowDecoder: SQLRowDecoder
    associatedtype Select: SQLSelect
    associatedtype SelectExpression: SQLSelectExpression
    associatedtype TableConstraint: SQLTableConstraint
    associatedtype TableConstraintAlgorithm: SQLTableConstraintAlgorithm
    associatedtype TableIdentifier: SQLTableIdentifier
    associatedtype Update: SQLUpdate


    static func alterTable(_ alterTable: AlterTable) -> Self
    static func createTable(_ createTable: CreateTable) -> Self
    static func delete(_ delete: Delete) -> Self 
    static func dropTable(_ dropTable: DropTable) -> Self
    static func insert(_ insert: Insert) -> Self
    static func select(_ select: Select) -> Self
    static func update(_ update: Update) -> Self
    static func raw(_ sql: String, binds: [Encodable]) -> Self
}
