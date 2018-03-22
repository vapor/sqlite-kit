import Async
import Core
import Foundation

/// All possibles cases for SQLite data.
public enum SQLiteData {
    case integer(Int)
    case float(Double)
    case text(String)
    case blob(Foundation.Data)
    case null
}

extension SQLiteData {
    /// Returns an Int if the data is case .integer
    public var integer: Int? {
        switch self {
        case .integer(let int):
            return int
        default:
            return nil
        }
    }

    /// Returns a String if the data is case .text
    public var text: String? {
        switch self {
        case .text(let string):
            return string
        default:
            return nil
        }
    }

    /// Returns a float if the data is case .double
    public var float: Double? {
        switch self {
        case .float(let double):
            return double
        default:
            return nil
        }
    }

    /// Returns Foundation.Data if the data is case .blob
    public var blob: Foundation.Data? {
        switch self {
        case .blob(let data):
            return data
        default:
            return nil
        }
    }

    /// Returns true if the data == .null
    public var isNull: Bool {
        switch self {
        case .null:
            return true
        default:
            return false
        }
    }
}

extension SQLiteData: CustomStringConvertible {
    /// Description of data
    public var description: String {
        switch self {
        case .blob(let data):
            return data.description
        case .float(let float):
            return float.description
        case .integer(let int):
            return int.description
        case .null:
            return "<null>"
        case .text(let text):
            return text
        }
    }
}

public protocol SQLiteDataConvertible {
    static func convertFromSQLiteData(_ data: SQLiteData) throws -> Self
    func convertToSQLiteData() throws -> SQLiteData
}

extension SQLiteData: SQLiteDataConvertible {
    /// See `SQLiteDataConvertible.convertFromSQLiteData(_:)`
    public static func convertFromSQLiteData(_ data: SQLiteData) throws -> SQLiteData {
        return data
    }

    /// See `convertToSQLiteData()`
    public func convertToSQLiteData() throws -> SQLiteData {
        return self
    }
}

extension Data: SQLiteDataConvertible {
    /// See `SQLiteDataConvertible.convertFromSQLiteData(_:)`
    public static func convertFromSQLiteData(_ data: SQLiteData) throws -> Data {
        switch data {
        case .blob(let data): return data
        default: throw SQLiteError(problem: .warning, reason: "Could not convert to Data: \(data)", source: .capture())
        }
    }

    /// See `convertToSQLiteData()`
    public func convertToSQLiteData() throws -> SQLiteData {
        return .blob(self)
    }
}

extension UUID: SQLiteDataConvertible {
    /// See `SQLiteDataConvertible.convertFromSQLiteData(_:)`
    public static func convertFromSQLiteData(_ data: SQLiteData) throws -> UUID {
        switch data {
        case .text(let string):
            guard let uuid = UUID(uuidString: string) else {
                throw SQLiteError(problem: .warning, reason: "Could not convert string to UUID: \(string)", source: .capture())
            }
            return uuid
        default: throw SQLiteError(problem: .warning, reason: "Could not convert to UUID: \(data)", source: .capture())
        }
    }

    /// See `convertToSQLiteData()`
    public func convertToSQLiteData() throws -> SQLiteData {
        return .text(uuidString)
    }
}

extension Date: SQLiteDataConvertible {
    /// See `SQLiteDataConvertible.convertFromSQLiteData(_:)`
    public static func convertFromSQLiteData(_ data: SQLiteData) throws -> Date {
        switch data {
        case .float(let double): return Date(timeIntervalSince1970: double)
        default: throw SQLiteError(problem: .warning, reason: "Could not convert to Date: \(data)", source: .capture())
        }
    }

    /// See `convertToSQLiteData()`
    public func convertToSQLiteData() throws -> SQLiteData {
        return .float(timeIntervalSince1970)
    }
}

extension String: SQLiteDataConvertible {
    /// See `SQLiteDataConvertible.convertFromSQLiteData(_:)`
    public static func convertFromSQLiteData(_ data: SQLiteData) throws -> String {
        switch data {
        case .text(let string): return string
        default: throw SQLiteError(problem: .warning, reason: "Could not convert to String: \(data)", source: .capture())
        }
    }

    /// See `convertToSQLiteData()`
    public func convertToSQLiteData() throws -> SQLiteData {
        return .text(self)
    }
}

extension FixedWidthInteger {
    /// See `SQLiteDataConvertible.convertFromSQLiteData(_:)`
    public static func convertFromSQLiteData(_ data: SQLiteData) throws -> Self {
        switch data {
        case .integer(let int):
            guard int <= Self.max else {
                throw SQLiteError(problem: .warning, reason: "Int too large for \(Self.self): \(int)", source: .capture())
            }
            guard int >= Self.min else {
                throw SQLiteError(problem: .warning, reason: "Int too small for \(Self.self): \(int)", source: .capture())
            }
            return numericCast(int)
        default: throw SQLiteError(problem: .warning, reason: "Could not convert to String: \(data)", source: .capture())
        }
    }

    /// See `convertToSQLiteData()`
    public func convertToSQLiteData() throws -> SQLiteData {
        return .integer(numericCast(self))
    }
}

extension Int8: SQLiteDataConvertible { }
extension Int16: SQLiteDataConvertible { }
extension Int32: SQLiteDataConvertible { }
extension Int64: SQLiteDataConvertible { }
extension Int: SQLiteDataConvertible { }
extension UInt8: SQLiteDataConvertible { }
extension UInt16: SQLiteDataConvertible { }
extension UInt32: SQLiteDataConvertible { }
extension UInt64: SQLiteDataConvertible { }
extension UInt: SQLiteDataConvertible { }

extension BinaryFloatingPoint {
    /// See `SQLiteDataConvertible.convertFromSQLiteData(_:)`
    public static func convertFromSQLiteData(_ data: SQLiteData) throws -> Self {
        switch data {
        case .integer(let int): return .init(int)
        case .float(let double): return .init(double)
        default: throw SQLiteError(problem: .warning, reason: "Could not convert to String: \(data)", source: .capture())
        }
    }

    /// See `convertToSQLiteData()`
    public func convertToSQLiteData() throws -> SQLiteData {
        switch self {
        case let double as Double: return .float(double)
        case let float as Float: return .float(.init(float))
        default: throw SQLiteError(problem: .warning, reason: "Could not convert to SQLiteData: \(Self.self)", source: .capture())
        }

    }
}

extension Double: SQLiteDataConvertible { }
extension Float: SQLiteDataConvertible { }

extension OptionalType {
    /// See `SQLiteDataConvertible.convertFromSQLiteData(_:)`
    public static func convertFromSQLiteData(_ data: SQLiteData) throws -> Self {
        let wrapped = try requireDataCustomConvertible(WrappedType.self).convertFromSQLiteData(data)
        return Self.makeOptionalType(wrapped as? WrappedType)
    }

    /// See `convertToSQLiteData()`
    public func convertToSQLiteData() throws -> SQLiteData {
        if let wrapped = self.wrapped {
            return try requireDataCustomConvertible(wrapped).convertToSQLiteData()
        } else {
            return .null
        }
    }
}

extension Optional: SQLiteDataConvertible { }

func requireDataCustomConvertible<T>(_ type: T) -> SQLiteDataConvertible {
    guard let custom = type as? SQLiteDataConvertible else {
        fatalError("`\(T.self)` does not conform to `SQLiteDataConvertible`")
    }
    return custom
}

func requireDataCustomConvertible<T>(_ type: T.Type) -> SQLiteDataConvertible.Type {
    guard let custom = T.self as? SQLiteDataConvertible.Type else {
        fatalError("`\(T.self)` does not conform to `SQLiteDataConvertible`")
    }
    return custom
}
