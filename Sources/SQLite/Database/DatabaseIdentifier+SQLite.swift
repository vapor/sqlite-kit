extension DatabaseIdentifier {
    /// Default `DatabaseIdentifier` for SQLite databases.
    public static var sqlite: DatabaseIdentifier<SQLiteDatabase> {
        return "sqlite"
    }
}
