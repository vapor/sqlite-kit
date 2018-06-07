import SQLite

let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
let sqlite = try SQLiteDatabase(storage: .memory)
let conn = try sqlite.newConnection(on: group).wait()
conn.logger = DatabaseLogger(database: .sqlite, handler: PrintLogHandler.init())


struct Planet: SQLiteTable {
    var id: Int?
    var name: String
    init(id: Int? = nil, name: String) {
        self.id = id
        self.name = name
    }
}

try conn.create(table: Planet.self)
    .column(for: \Planet.id, .integer, .primaryKey(), .notNull)
    .column(for: \Planet.name, .text, .notNull)
    .run().wait()

for _ in 0..<1_000 {
    try conn.insert(into: Planet.self)
        .value(Planet(name: "Earth"))
        .run().wait()
}
