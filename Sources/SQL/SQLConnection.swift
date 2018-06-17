import Async

public protocol SQLConnection {
    associatedtype Output
    associatedtype Query: SQLQuery
        where Query.RowDecoder.Row == Output 
    func query(_ query: Query, _ handler: @escaping (Output) throws -> ()) -> Future<Void>
}
