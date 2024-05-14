import struct Foundation.UUID

/// Describes a configuration for an SQLite database connection.
public struct SQLiteConfiguration: Sendable {
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

    /// Create a new ``SQLiteConfiguration``.
    ///
    /// - Parameters:
    ///   - storage: The storage type to use for the database. See ``Storage-swift.enum``.
    ///   - enableForeignKeys: Whether to enable foreign key support by default for all connections.
    ///     Defaults to `true`.
    public init(storage: Storage, enableForeignKeys: Bool = true) {
        self.storage = storage
        self.enableForeignKeys = enableForeignKeys
    }
}
