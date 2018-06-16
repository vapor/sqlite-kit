extension SQLiteQuery.Expression {
    public struct Function {
        public enum Parameters {
            case all
            case expressions(distinct: Bool, [SQLiteQuery.Expression])
        }
        
        public var name: String
        public var parameters: Parameters?
        
        public init(name: String, parameters: Parameters? = nil) {
            self.name = name
            self.parameters = parameters
        }
    }
}
