extension SQLiteQuery {
    /// Sort direction.
    public enum Direction {
        /// `ASC`.
        case ascending
        /// `DESC`.
        case descending
    }
}

// MARK: Serialize

extension SQLiteSerializer {
    internal func serialize(_ direction: SQLiteQuery.Direction) -> String {
        switch direction {
        case .ascending: return "ASC"
        case .descending: return "DESC"
        }
    }
}
