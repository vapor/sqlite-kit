/// Available SQLite storage methods.
public enum SQLiteStorage {
    /// In-memory storage. Not persisted between application launches.
    /// Good for unit testing or caching.
    case memory
    
    /// File-based storage, persisted between application launches.
    case file(path: String)
}
