#if os(Linux)
import CSQLite
#else
import SQLite3
#endif

internal struct SQLiteStatement {
    internal let connection: SQLiteConnection
    internal let c: OpaquePointer

    internal init(query: String, on connection: SQLiteConnection) throws {
        var handle: OpaquePointer?
        let ret = sqlite3_prepare_v2(connection.database.handle, query, -1, &handle, nil)
        guard ret == SQLITE_OK, let c = handle else {
            throw SQLiteError(statusCode: ret, connection: connection, source: .capture())
        }
        self.connection = connection
        self.c = c
    }
    
    internal func bind(_ binds: [SQLiteData]) throws {
        for (i, bind) in binds.enumerated() {
            let i = Int32(i + 1)
            switch bind {
            case .blob(let value):
                let count = Int32(value.count)
                let pointer: UnsafePointer<UInt8> = value.withUnsafeBytes { $0 }
                let ret = sqlite3_bind_blob(c, i, UnsafeRawPointer(pointer), count, SQLITE_TRANSIENT)
                guard ret == SQLITE_OK else {
                    throw SQLiteError(statusCode: ret, connection: connection, source: .capture())
                }
            case .float(let value):
                let ret = sqlite3_bind_double(c, i, value)
                guard ret == SQLITE_OK else {
                    throw SQLiteError(statusCode: ret, connection: connection, source: .capture())
                }
            case .integer(let value):
                let ret = sqlite3_bind_int64(c, i, Int64(value))
                guard ret == SQLITE_OK else {
                    throw SQLiteError(statusCode: ret, connection: connection, source: .capture())
                }
            case .null:
                let ret = sqlite3_bind_null(c, i)
                if ret != SQLITE_OK {
                    throw SQLiteError(statusCode: ret, connection: connection, source: .capture())
                }
            case .text(let value):
                let strlen = Int32(value.utf8.count)
                let ret = sqlite3_bind_text(c, i, value, strlen, SQLITE_TRANSIENT)
                guard ret == SQLITE_OK else {
                    throw SQLiteError(statusCode: ret, connection: connection, source: .capture())
                }
            }
        }

    }

    internal func getColumns() throws -> [SQLiteColumn]? {
        var columns: [SQLiteColumn] = []

        let count = sqlite3_column_count(c)
        columns.reserveCapacity(Int(count))

        // iterate over column count and intialize columns once
        // we will then re-use the columns for each row
        for i in 0..<count {
            try columns.append(column(at: i))
        }

        return columns
    }
    
    internal func nextRow(for columns: [SQLiteColumn]) throws -> [SQLiteColumn: SQLiteData]? {
        // step over the query, this will continue to return SQLITE_ROW
        // for as long as there are new rows to be fetched
        let step = sqlite3_step(c)
        switch step {
        case SQLITE_DONE:
            // no results left
            let ret = sqlite3_finalize(c)
            guard ret == SQLITE_OK else {
                throw SQLiteError(statusCode: ret, connection: connection, source: .capture())
            }
            return nil
        case SQLITE_ROW: break
        default: throw SQLiteError(statusCode: step, connection: connection, source: .capture())
        }

        
        var row: [SQLiteColumn: SQLiteData] = [:]
        
        // iterator over column count again and create a field
        // for each column. Use the column we have already initialized.
        for i in 0..<Int32(columns.count) {
            let col = columns[Int(i)]
            row[col] = try data(at: i)
        }
        
        // return to event loop
        return row
    }
    
    // MARK: Private
    
    private func data(at offset: Int32) throws -> SQLiteData {
        let type = try dataType(at: offset)
        switch type {
        case .integer:
            let val = sqlite3_column_int64(c, offset)
            let integer = Int(val)
            return .integer(integer)
        case .real:
            let val = sqlite3_column_double(c, offset)
            let double = Double(val)
            return .float(double)
        case .text:
            guard let val = sqlite3_column_text(c, offset) else {
                throw SQLiteError(problem: .error, reason: "Unexpected nil column text.", source: .capture())
            }
            let string = String(cString: val)
            return .text(string)
        case .blob:
            let blobPointer = sqlite3_column_blob(c, offset)
            let length = Int(sqlite3_column_bytes(c, offset))
            
            let buffer = UnsafeBufferPointer(
                start: blobPointer?.assumingMemoryBound(to: UInt8.self),
                count: length
            )
            return .blob(Foundation.Data(buffer: buffer))
        case .null: return .null
        }
    }
    
    private func dataType(at offset: Int32) throws -> SQLiteDataType {
        switch sqlite3_column_type(c, offset) {
        case SQLITE_INTEGER: return .integer
        case SQLITE_FLOAT: return .real
        case SQLITE_TEXT: return .text
        case SQLITE_BLOB: return .blob
        case SQLITE_NULL: return .null
        default: throw SQLiteError(problem: .error, reason: "Unexpected column type.", source: .capture())
        }
    }
    
    private func column(at offset: Int32) throws -> SQLiteColumn {
        guard let nameRaw = sqlite3_column_name(c, offset) else {
            throw SQLiteError(problem: .error, reason: "Unexpected nil column name", source: .capture())
        }
        let table: String?
        if let tableNameRaw = sqlite3_column_table_name(c, offset) {
            table = String(cString: tableNameRaw)
        } else {
            table = nil
        }
        let name = String(cString: nameRaw)
        return .init(table: table, name: name)
    }
}

private let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
