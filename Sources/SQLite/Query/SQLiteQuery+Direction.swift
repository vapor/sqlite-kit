extension SQLiteQuery {
    public enum Direction {
        case ascending
        case descending
    }
}

extension SQLiteSerializer {
    func serialize(_ direction: SQLiteQuery.Direction) -> String {
        switch direction {
        case .ascending: return "ASC"
        case .descending: return "DESC"
        }
    }
}
