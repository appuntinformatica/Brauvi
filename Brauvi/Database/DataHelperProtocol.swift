import UIKit

protocol DataHelperProtocol {
    associatedtype T
    static func createTable()   -> Void
    static func insert(item: T) -> Int64
    static func delete(item: T) -> Void
    static func update(item: T) -> Void
    static func findAll()       -> [T]
    static func find(id: Int64) -> T?
}
