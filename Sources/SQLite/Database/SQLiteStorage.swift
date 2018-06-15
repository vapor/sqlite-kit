/// Available SQLite storage methods.
public enum SQLiteStorage {
    case temporary
    case file(path: String)

    var path: String {
        switch self {
        case .temporary: return "/tmp/_swift-tmp.sqlite"
        case .file(let path): return path
        }
    }
}
