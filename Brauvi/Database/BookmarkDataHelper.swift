import UIKit
import SQLite
import XCGLogger

typealias Bookmark = (
    id:           Int64,
    parentId:     Int64,
    isFolder:     Bool,
    displayOrder: Int,
    title:        String,
    url:          String
)

class BookmarkDataHelper: DataHelperProtocol {
    static let log = XCGLogger.default
    let log = XCGLogger.default
    
    static let table        = Table("bookmark")
    static let id           = Expression<Int64>("id")
    static let parentId     = Expression<Int64>("parent_id")
    static let isFolder     = Expression<Bool>("is_folder")
    static let displayOrder = Expression<Int>("display_order")
    static let title        = Expression<String>("title")
    static let url          = Expression<String>("url")
    
    typealias T = Bookmark
    
    static func createTable() {
        do {
            let DB = SQLiteDataStore.sharedInstance.BBDB!
            
            try DB.run( table.create(ifNotExists: true) {t in
                t.column(id, primaryKey: true)
                t.column(parentId)
                t.column(isFolder)
                t.column(displayOrder)
                t.column(title)
                t.column(url)
            })
        } catch {
            self.log.error(error)
        }
    }
    
    static func insert(item: T) -> Int64 {
        var id: Int64 = 0
        do {
            let DB = SQLiteDataStore.sharedInstance.BBDB!
            
            let insert = table.insert(parentId <- item.parentId, isFolder <- item.isFolder, displayOrder <- item.displayOrder, title <- item.title, url <- item.url)
            
            id = try DB.run(insert)
        } catch {
            log.error(error)
        }
        return id
    }
    
    static func delete(item: T) {
        do {
            let DB = SQLiteDataStore.sharedInstance.BBDB!
            
            let query = table.filter(item.id == rowid)
            
            try DB.run(query.delete())
        } catch {
            log.error(error)
        }
    }
    
    static func update(item: T) {
        do {
            let DB = SQLiteDataStore.sharedInstance.BBDB!
            
            let query = table.filter(item.id == rowid)
            
            try DB.run(query.update(parentId <- item.parentId, isFolder <- item.isFolder, displayOrder <- item.displayOrder, title <- item.title, url <- item.url))
        } catch {
            log.error(error)
        }
    }
    
    static func find(id: Int64) -> T? {
        do {
            let DB = SQLiteDataStore.sharedInstance.BBDB!
            
            let query = table.filter(id == rowid)
            
            let items = try DB.prepare(query)
            
            for item in items {
                return Bookmark(id: item[BookmarkDataHelper.id], parentId: item[parentId], isFolder: item[isFolder], displayOrder: item[displayOrder], title: item[title], url: item[url])
            }
        } catch {
            log.error(error)
        }
        return nil
    }
    
    static func findAll() -> [T] {
        return findAll(byParentId: 0)
    }
    
    static func findAll(byParentId parentId: Int64) -> [T] {
        var retArray = [T]()
        do {
            let DB = SQLiteDataStore.sharedInstance.BBDB!
            
            let query = table.filter(BookmarkDataHelper.parentId == parentId).order(displayOrder)
            self.log.info(query.asSQL())
            
            let items = try DB.prepare(query)
            
            for item in items {
                retArray.append(Bookmark(id: item[BookmarkDataHelper.id], parentId: item[BookmarkDataHelper.parentId], isFolder: item[isFolder], displayOrder: item[displayOrder], title: item[title], url: item[url]))
            }
        } catch {
            log.error(error)
        }
        return retArray
    }
    
    static func findDisplayOrder(withParentId parentId: Int64, isFolder: Bool) -> Int {
        do {
            let DB = SQLiteDataStore.sharedInstance.BBDB!
            
            let query = table.count.filter(BookmarkDataHelper.parentId == parentId && BookmarkDataHelper.isFolder == isFolder)
            self.log.info(query.asSQL())
            
            let items = try DB.prepare(query)
            
            for item in items {
                let displayOrder = item[BookmarkDataHelper.displayOrder] + 1
                return displayOrder
            }
        } catch {
            log.error(error)
        }
        return 0
    }
    
    static func reorder(_ bookmarks: [Bookmark]) {
        let DB = SQLiteDataStore.sharedInstance.BBDB!
        for (index, bookmark) in bookmarks.enumerated() {
            do {
                let e = table.filter(bookmark.id == rowid)
                try DB.run(e.update(displayOrder <- index))
            } catch {
                log.error(error)
            }
        }
    }
}
