extension SQLiteQuery {
    public enum ConflictResolution {
        case replace
        case rollback
        case abort
        case fail
        case ignore
    }
}

extension SQLiteSerializer {
    func serialize(_ conflictResolution: SQLiteQuery.ConflictResolution) -> String {
        switch conflictResolution {
        case .abort: return "ABORT"
        case .fail: return "FAIL"
        case .ignore: return "IGNORE"
        case .replace: return "REPLACE"
        case .rollback: return "ROLLBACK"
        }
    }
}
