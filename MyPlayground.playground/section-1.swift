// Playground - noun: a place where people can play

import Cocoa
import SQLite

let database = Database("wetalk.sqlite3")

let feedQuery = database["feeds"]

struct FeedTable {
    static let id = Expression<Int64>("id")
    static let name = Expression<String?>("name")
    static let url = Expression<String>("url")
    static let parentId = Expression<Int>("parentId")
    static let unreadCount = Expression<Int>("unreadCount")
    static let lastUpdated = Expression<Int>("lastUpdated")
    static let type = Expression<Int>("type")
    static let nextSibling = Expression<Int>("nextSibling")
    static let firstChild = Expression<Int>("firstChile")
}

database.create(table: feedQuery) { t in
    t.column(FeedTable.id, primaryKey: true)
    t.column(FeedTable.name)
    t.column(FeedTable.url, unique: true)
    t.column(FeedTable.parentId)
    t.column(FeedTable.unreadCount)
    t.column(FeedTable.lastUpdated)
    t.column(FeedTable.type)
    t.column(FeedTable.nextSibling)
    t.column(FeedTable.firstChild)
}
if let insertId = feedQuery.insert(FeedTable.name <- "Ali1ce", FeedTable.url <- "alic21e@mac.com", FeedTable.parentId <- 2, FeedTable.unreadCount <- 2, FeedTable.lastUpdated <- 2, FeedTable.type <- 2, FeedTable.nextSibling <- 2, FeedTable.firstChild <- 2) {
}

for feedQuery in feedQuery {
    // id: 1, name: Optional("Alice"), email: alice@mac.com
    let test: Int64 = feedQuery[FeedTable.id]
}
