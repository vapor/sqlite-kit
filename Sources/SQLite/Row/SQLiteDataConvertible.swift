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
        case .blob(let data):
            guard data.count == 16 else {
                 throw SQLiteError(problem: .warning, reason: "Could not convert to UUID: \(data)", source: .capture())
            }
            return UUID(uuid: (
                data[0], data[1], data[2], data[3], data[4], data[5], data[6], data[7],
                data[8], data[9], data[10], data[11], data[12], data[13], data[14], data[15]
            ))
        default: throw SQLiteError(problem: .warning, reason: "Could not convert to UUID: \(data)", source: .capture())
        }
    }
    
    /// See `convertToSQLiteData()`
    public func convertToSQLiteData() throws -> SQLiteData {
        return .blob(Data([
            uuid.0, uuid.1, uuid.2, uuid.3, uuid.4, uuid.5, uuid.6, uuid.7,
            uuid.8, uuid.9, uuid.10, uuid.11, uuid.12, uuid.13, uuid.14, uuid.15
        ]))
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

extension URL: SQLiteDataConvertible {
    /// See `SQLiteDataConvertible.convertFromSQLiteData(_:)`
    public static func convertFromSQLiteData(_ data: SQLiteData) throws -> URL {
        switch data {
        case .text(let string):
            guard let url = URL(string: string) else {
                throw SQLiteError(problem: .warning, reason: "Could not convert to URL: \(data)", source: .capture())
            }
            return url
        default: throw SQLiteError(problem: .warning, reason: "Could not convert to URL: \(data)", source: .capture())
        }
    }
    
    /// See `convertToSQLiteData()`
    public func convertToSQLiteData() throws -> SQLiteData {
        return .text(description)
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
        default: throw SQLiteError(problem: .warning, reason: "Could not convert to \(Self.self): \(data)", source: .capture())
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
extension Bool: SQLiteDataConvertible {
    
    /// See `SQLiteDataConvertible.convertFromSQLiteData(_:)`
    public static func convertFromSQLiteData(_ data: SQLiteData) throws -> Bool {
        switch data {
        case .integer(let intValue):
            let boolValue = intValue == 0 ? false : true
            return boolValue
        default: throw SQLiteError(problem: .warning, reason: "Could not convert to Bool: \(data)", source: .capture())
        }
    }
    
    /// See `convertToSQLiteData()`
    public func convertToSQLiteData() throws -> SQLiteData {
        let intValue = self ? 1 : 0
        return SQLiteData.integer(intValue)
    }
}
