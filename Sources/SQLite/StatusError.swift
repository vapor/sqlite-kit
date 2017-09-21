import CSQLite

public enum StatusError: Error {

    public typealias StatusCode = Int32

    /**
        The definitions of these error codes
        is in sqlite3.h.
    */
    init?(with status: StatusCode, msg: String) {
        switch status {
        case SQLITE_OK:
            return nil
        case SQLITE_ERROR:
            self = .error(msg)
        case SQLITE_INTERNAL:
            self = .intern(msg)
        case SQLITE_PERM:
            self = .permission(msg)
        case SQLITE_ABORT:
            self = .abort(msg)
        case SQLITE_BUSY:
            self = .busy(msg)
        case SQLITE_LOCKED:
            self = .locked(msg)
        case SQLITE_NOMEM:
            self = .noMemory(msg)
        case SQLITE_READONLY:
            self = .readOnly(msg)
        case SQLITE_INTERRUPT:
            self = .interrupt(msg)
        case SQLITE_IOERR:
            self = .ioError(msg)
        case SQLITE_CORRUPT:
            self = .corrupt(msg)
        case SQLITE_NOTFOUND:
            self = .notFound(msg)
        case SQLITE_FULL:
            self = .full(msg)
        case SQLITE_CANTOPEN:
            self = .cantOpen(msg)
        case SQLITE_PROTOCOL:
            self = .proto(msg)
        case SQLITE_EMPTY:
            self = .empty(msg)
        case SQLITE_SCHEMA:
            self = .schema(msg)
        case SQLITE_TOOBIG:
            self = .tooBig(msg)
        case SQLITE_CONSTRAINT:
            self = .constraint(msg)
        case SQLITE_MISMATCH:
            self = .mismatch(msg)
        case SQLITE_MISUSE:
            self = .misuse(msg)
        case SQLITE_NOLFS:
            self = .noLFS(msg)
        case SQLITE_AUTH:
            self = .auth(msg)
        case SQLITE_FORMAT:
            self = .format(msg)
        case SQLITE_RANGE:
            self = .range(msg)
        case SQLITE_NOTADB:
            self = .notADatabase(msg)
        case SQLITE_NOTICE:
            self = .notice(msg)
        case SQLITE_WARNING:
            self = .warning(msg)
        case SQLITE_ROW:
            self = .row(msg)
        case SQLITE_DONE:
            self = .done(msg)
        default:
            self = .error(msg)
        }
    }
    /**
        Helper function that checks if
        the status passed is an error.
    */
    public static func check(with status: StatusCode, msg: String) throws {
        if let error = StatusError(with: status, msg: msg) {
            throw error
        }
    }

    case error(String)
    case intern(String)
    case permission(String)
    case abort(String)
    case busy(String)
    case locked(String)
    case noMemory(String)
    case readOnly(String)
    case interrupt(String)
    case ioError(String)
    case corrupt(String)
    case notFound(String)
    case full(String)
    case cantOpen(String)
    case proto(String)
    case empty(String)
    case schema(String)
    case tooBig(String)
    case constraint(String)
    case mismatch(String)
    case misuse(String)
    case noLFS(String)
    case auth(String)
    case format(String)
    case range(String)
    case notADatabase(String)
    case notice(String)
    case warning(String)
    case row(String)
    case done(String)
}
