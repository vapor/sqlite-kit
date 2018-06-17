//extension SQLiteQuery {
//    /// Represents an `ALTER TABLE ...` query.
//    ///
//    /// See `SQLiteQuery.AlterTableBuilder` to build this query.
//    public struct AlterTable {
//        /// Supported `ALTER TABLE` methods.
//        public enum Value {
//            /// Renames the table.
//            case rename(Name)
//            
//            /// Adds a new column to the table.
//            case addColumn(ColumnDefinition)
//        }
//        
//        /// Name of table to alter.
//        public var table: TableName
//        
//        /// Type of `ALTER` to perform.
//        public var value: Value
//        
//        /// Creates a new `AlterTable`.
//        ///
//        /// - parameters:
//        ///     - table: Name of table to alter.
//        ///     - value: Type of `ALTER` to perform.
//        public init(table: TableName, value: Value) {
//            self.table = table
//            self.value = value
//        }
//    }
//}
//
//// MARK: Serialize
//
////extension SQLiteSerializer {
////    internal func serialize(_ alter: SQLiteQuery.AlterTable, _ binds: inout [SQLiteData]) -> String {
////        var sql: [String] = []
////        sql.append("ALTER TABLE")
////        sql.append(serialize(alter.table))
////        sql.append(serialize(alter.value, &binds))
////        return sql.joined(separator: " ")
////    }
////    
////    internal func serialize(_ value: SQLiteQuery.AlterTable.Value, _ binds: inout [SQLiteData]) -> String {
////        var sql: [String] = []
////        switch value {
////        case .rename(let name):
////            sql.append("RENAME TO")
////            sql.append(serialize(name))
////        case .addColumn(let columnDefinition):
////            sql.append("ADD")
////            sql.append(serialize(columnDefinition, &binds))
////        }
////        return sql.joined(separator: " ")
////    }
////}
