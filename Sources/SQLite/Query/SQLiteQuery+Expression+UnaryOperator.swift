extension SQLiteQuery.Expression {
    public enum UnaryOperator {
        /// `-`
        case negative
        /// `+`
        case noop
        /// `~`
        case collate
        /// `NOT`
        case not
    }
}


extension SQLiteSerializer {
    func serialize(_ expr: SQLiteQuery.Expression.UnaryOperator) -> String {
        switch expr {
        case .negative: return "-"
        case .noop: return "+"
        case .collate: return "~"
        case .not: return "!"
        }
    }
}
