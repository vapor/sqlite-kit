import struct Foundation.UUID

/// Describes a configuration for an SQLite database connection.
public struct SQLiteConfiguration: Sendable {
    /// The possible journal modes for an SQLite database.
    public enum JournalMode: String, Sendable {
        /// The `DELETE` journaling mode is the default. In the `DELETE` mode,
        /// the rollback journal is deleted at the conclusion of each
        /// transaction.
        case delete = "DELETE"

        /// The `TRUNCATE` journaling mode commits transactions by truncating
        /// the rollback journal to zero-length instead of deleting it.
        case truncate = "TRUNCATE"

        /// The `PERSIST` journaling mode prevents the rollback journal from
        /// being deleted at the end of each transaction. Instead, the header of
        /// the journal is overwritten with zeros.
        case persist = "PERSIST"

        /// The `MEMORY` journaling mode stores the rollback journal in volatile
        /// RAM. This saves disk I/O but at the expense of database safety and
        /// integrity.
        case memory = "MEMORY"

        /// The `WAL` journaling mode uses a write-ahead log instead of a
        /// rollback journal to implement transactions. Provides better
        /// concurrency and performance.
        case wal = "WAL"

        /// The `OFF` journaling mode disables the rollback journal completely.
        /// No rollback journal is ever created and hence there is never a
        /// rollback journal to delete. The OFF journaling mode disables the
        /// atomic commit and rollback capabilities of SQLite, which is
        /// considered **dangerous**.
        case off = "OFF"
    }

    /// The possible storage types for an SQLite database.
    public enum Storage: Sendable {
        /// Specify an SQLite database stored in memory, using a randomly generated identifier.
        ///
        /// See ``memory(identifier:)``.
        public static var memory: Self {
            .memory(identifier: UUID().uuidString)
        }

        /// Specify an SQLite database stored in memory, using a given identifier string.
        ///
        /// An in-memory database persists only until the last connection to it is closed. If a new connection is
        /// opened after that point, even using the same identifier, a new, empty database is created.
        ///
        /// - Parameter identifier: Uniquely identifies the in-memory storage. Multiple connections may use this
        ///   identifier to connect to the same in-memory storage for the duration of its lifetime. The identifer
        ///   has no predefined format or restrictions on its content.
        case memory(identifier: String)

        /// Specify an SQLite database stored in a file at the specified path.
        ///
        /// If a relative path is specified, it is interpreted relative to the current working directory of the
        /// current process (e.g. `NIOFileSystem.shared.currentWorkingDirectory`). It is recommended to always use
        /// absolute paths whenever possible.
        ///
        /// - Parameter path: The filesystem path at which to store the database.
        case file(path: String)
    }
    
    /// The storage type for the database.
    ///
    /// See ``Storage-swift.enum`` for the available storage types.
    public var storage: Storage

    /// When `true`, foreign key support is automatically enabled on all connections using this configuration.
    ///
    /// Internally issues a `PRAGMA foreign_keys = ON` query when enabled.
    public var enableForeignKeys: Bool

    /// The journal mode to use for the database.
    ///
    /// Internally issues a `PRAGMA journal_mode = <mode>` query when the
    /// connection is opened.
    public var journalMode: JournalMode

    /// Create a new ``SQLiteConfiguration``.
    ///
    /// Note that the `journalMode` for an in-memory database is either `MEMORY`
    /// or `OFF` and can not be changed to a different value. An attempt to
    /// change the `journalMode` of an in-memory database to any setting other
    /// than `MEMORY` or `OFF` is ignored. Note also that the `journalMode`
    /// cannot be changed while a transaction is active.
    ///
    /// - Parameters:
    ///   - storage: The storage type to use for the database. See ``Storage-swift.enum``.
    ///   - enableForeignKeys: Whether to enable foreign key support by default for all connections.
    ///     Defaults to `true`.
    ///   - journalMode: The journal mode to use for the database.
    ///     See ``JournalMode-swift.enum``. Defaults to `.delete`.
    public init(
        storage: Storage,
        enableForeignKeys: Bool = true,
        journalMode: JournalMode = .delete
    ) {
        self.storage = storage
        self.enableForeignKeys = enableForeignKeys
        self.journalMode = journalMode
    }
}
