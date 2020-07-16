import struct Foundation.UUID

public struct SQLiteConfiguration {
    public enum Storage {
        /// Stores the SQLite database in memory.
        /// 
        /// Uses a randomly generated identifier. See `memory(identifier:)`.
        public static var memory: Self {
            .memory(identifier: UUID().uuidString)
        }

        /// Stores the SQLite database in memory.
        /// - parameters:
        ///     - identifier: Uniquely identifies the in-memory storage.
        ///                   Connections using the same identifier share data.
        case memory(identifier: String)

        /// Uses the SQLite database file at the specified path.
        ///
        /// Non-absolute paths will check the current working directory.
        case file(path: String)
    }

    public var storage: Storage

    /// If `true`, foreign keys will be enabled automatically on new connections.
    public var enableForeignKeys: Bool

    /// Creates a new `SQLiteConfiguration`.
    public init(storage: Storage, enableForeignKeys: Bool = true) {
        self.storage = storage
        self.enableForeignKeys = enableForeignKeys
    }
}
