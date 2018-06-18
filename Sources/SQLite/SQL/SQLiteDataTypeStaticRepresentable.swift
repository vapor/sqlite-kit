/// A type that is capable of being represented by a `SQLiteFieldType`.
///
/// Types conforming to this protocol can be automatically migrated by `FluentSQLite`.
///
/// See `SQLiteType` for more information.
public protocol SQLiteDataTypeStaticRepresentable {
    /// See `SQLiteDataTypeStaticRepresentable`.
    static var sqliteDataType: SQLiteDataType { get }
}

extension FixedWidthInteger {
    /// See `SQLiteDataTypeStaticRepresentable`.
    public static var sqliteDataType: SQLiteDataType { return .integer }
}

extension UInt: SQLiteDataTypeStaticRepresentable { }
extension UInt8: SQLiteDataTypeStaticRepresentable { }
extension UInt16: SQLiteDataTypeStaticRepresentable { }
extension UInt32: SQLiteDataTypeStaticRepresentable { }
extension UInt64: SQLiteDataTypeStaticRepresentable { }
extension Int: SQLiteDataTypeStaticRepresentable { }
extension Int8: SQLiteDataTypeStaticRepresentable { }
extension Int16: SQLiteDataTypeStaticRepresentable { }
extension Int32: SQLiteDataTypeStaticRepresentable { }
extension Int64: SQLiteDataTypeStaticRepresentable { }

extension Date: SQLiteDataTypeStaticRepresentable {
    /// See `SQLiteDataTypeStaticRepresentable`.
    public static var sqliteDataType: SQLiteDataType { return Double.sqliteDataType }
}

extension BinaryFloatingPoint {
    /// See `SQLiteDataTypeStaticRepresentable`.
    public static var sqliteDataType: SQLiteDataType { return .real }
}

extension Float: SQLiteDataTypeStaticRepresentable { }
extension Double: SQLiteDataTypeStaticRepresentable { }

extension Bool: SQLiteDataTypeStaticRepresentable {
    /// See `SQLiteDataTypeStaticRepresentable`.
    public static var sqliteDataType: SQLiteDataType { return Int.sqliteDataType }
}

extension UUID: SQLiteDataTypeStaticRepresentable {
    /// See `SQLiteDataTypeStaticRepresentable`.
    public static var sqliteDataType: SQLiteDataType { return .blob }
}

extension Data: SQLiteDataTypeStaticRepresentable {
    /// See `SQLiteDataTypeStaticRepresentable`.
    public static var sqliteDataType: SQLiteDataType { return .blob }
}

extension String: SQLiteDataTypeStaticRepresentable {
    /// See `SQLiteDataTypeStaticRepresentable`.
    public static var sqliteDataType: SQLiteDataType { return .text }
}

extension URL: SQLiteDataTypeStaticRepresentable {
    /// See `SQLiteDataTypeStaticRepresentable`.
    public static var sqliteDataType: SQLiteDataType { return String.sqliteDataType }
}
