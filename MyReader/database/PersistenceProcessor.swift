//
//  PersistenceProcessor.swift
//  Campfire
//
//  Created by GoldRatio on 9/3/14.
//  Copyright (c) 2014 GoldRatio. All rights reserved.
//

import Foundation
import SQLite

class PersistenceProcessor
{
    
    class var sharedInstance: PersistenceProcessor {
        struct Singleton {
            static let instance = PersistenceProcessor()
        }
        return Singleton.instance
    }
    
    let database: Database
    var feeds: [Feed] = [Feed]()
    var feedsQuery: SQLite.Query
    var articlesQuery: SQLite.Query
    
    struct FeedTable {
        static let id = Expression<Int64>("id")
        static let name = Expression<String>("name")
        static let url = Expression<String>("url")
        static let homePage = Expression<String?>("homePage")
        static let parentId = Expression<Int64>("parentId")
        static let unreadCount = Expression<Int>("unreadCount")
        static let lastUpdated = Expression<Double>("lastUpdated")
        static let type = Expression<Int>("type")
        static let nextSibling = Expression<Int64>("nextSibling")
        static let firstChild = Expression<Int64>("firstChile")
    }
    
    struct ArticleTable {
        static let url = Expression<String>("url")
        static let title = Expression<String>("title")
        static let description = Expression<String>("description")
        static let feedId = Expression<Int64>("feedId")
        static let pubDate = Expression<Double>("pubDate")
        static let Read = Expression<Int>("Read")
    }
    
    init() {
        if let file = NSBundle.mainBundle().pathForResource("wetalk.sqlite3", ofType: nil) {
            database = Database(file)
        }
        else {
            database = Database("wetalk.sqlite3")
        }
        
        feedsQuery = database["feeds"]
        
        database.create(table: feedsQuery, ifNotExists: true) { t in
            t.column(FeedTable.id, primaryKey: true)
            t.column(FeedTable.name, defaultValue: "")
            t.column(FeedTable.url)
            t.column(FeedTable.homePage)
            t.column(FeedTable.parentId, defaultValue: 0)
            t.column(FeedTable.unreadCount, defaultValue: 0)
            t.column(FeedTable.lastUpdated, defaultValue: 0)
            t.column(FeedTable.type, defaultValue: 0)
            t.column(FeedTable.nextSibling, defaultValue: 0)
            t.column(FeedTable.firstChild, defaultValue: 0)
        }
        
        articlesQuery = database["articles"]
        
        database.create(table: articlesQuery, ifNotExists: true) { t in
            
            t.column(ArticleTable.url, primaryKey: true)
            t.column(ArticleTable.title)
            t.column(ArticleTable.description)
            t.column(ArticleTable.feedId)
            t.column(ArticleTable.pubDate)
            t.column(ArticleTable.Read, defaultValue: 0)
        }
        
        feeds = self.getFeeds()
    }
    
    
    func getFeeds() -> [Feed] {
        var feeds = [Feed]()
        for feedQuery in feedsQuery.order(FeedTable.type) {
            // id: 1, name: Optional("Alice"), email: alice@mac.com
            let id: Int64 = feedQuery[FeedTable.id]
            let name: String = feedQuery[FeedTable.name]
            let url = feedQuery[FeedTable.url]
            let parentId = feedQuery[FeedTable.parentId]
            let unreadCount = feedQuery[FeedTable.unreadCount]
            let type = feedQuery[FeedTable.type]
            let nextSibling = feedQuery[FeedTable.nextSibling]
            let lastUpdated = feedQuery[FeedTable.lastUpdated]
            let firstChild = feedQuery[FeedTable.firstChild]
            let homePage = feedQuery[FeedTable.homePage]
            let feed = Feed(id: id,
                name: name,
                url: url,
                homePage: homePage,
                parentId: parentId,
                unreadCount: feedQuery[FeedTable.unreadCount],
                lastUpdated: NSDate(timeIntervalSince1970: feedQuery[FeedTable.lastUpdated]),
                type: feedQuery[FeedTable.type],
                nextSibling: feedQuery[FeedTable.nextSibling],
                firstChild: feedQuery[FeedTable.firstChild])
            feeds.append( feed )
        }
        return feeds
    }
    
    func updateFeed(feed: Feed) {
        let updates = feedsQuery.filter(FeedTable.id == feed.id)
        updates.update(FeedTable.name <- feed.name,
            FeedTable.url <- feed.url,
            FeedTable.homePage <- feed.homePage,
            FeedTable.parentId <- feed.parentId,
            FeedTable.unreadCount <- feed.unreadCount,
            FeedTable.lastUpdated <- feed.lastUpdated.timeIntervalSince1970,
            FeedTable.nextSibling <- feed.nextSibling,
            FeedTable.firstChild <- feed.firstChild)
        NSNotificationCenter.defaultCenter().postNotificationName(Constants.FolderUpdate, object: feed)
    }
    
    func addSubscription(url: String) {
        if let insertId = feedsQuery.insert(FeedTable.url <- url, FeedTable.type <- 1).rowid {
            println("inserted id: \(insertId)")
            let feed = Feed(id: insertId, name: "", url: url, type: 1)
            NSNotificationCenter.defaultCenter().postNotificationName(Constants.FolderAdd, object: feed)
        }
    }
    
    func importFeed(feed: Feed) -> Int64 {
        if let insertId = feedsQuery.insert(FeedTable.name <- feed.name,
            FeedTable.url <- feed.url,
            FeedTable.homePage <- feed.homePage,
            FeedTable.parentId <- feed.parentId,
            FeedTable.unreadCount <- feed.unreadCount,
            FeedTable.lastUpdated <- feed.lastUpdated.timeIntervalSince1970,
            FeedTable.nextSibling <- feed.nextSibling,
            FeedTable.type <- feed.type,
            FeedTable.firstChild <- feed.firstChild).rowid {
                feed.id = insertId
                NSNotificationCenter.defaultCenter().postNotificationName(Constants.FolderAdd, object: feed)
                return insertId
        }
        return 0
    }
    
    func deleteFeed(feed: Feed) -> Int {
        let deleteStatement = feedsQuery.filter(FeedTable.id == feed.id)
        if let result = deleteStatement.delete().changes {
            NSNotificationCenter.defaultCenter().postNotificationName(Constants.FolderDelete, object: feed)
            return result
        }
        return 0
    }
    
    func findArticle(url: String) -> Article? {
        let query = articlesQuery.filter(ArticleTable.url == url)
        if let articleQuery = query.first {
            
            let feedId = articleQuery[ArticleTable.feedId]
            var currentFeed: Feed? = nil
            for feed in feeds {
                if(feed.id == feedId) {
                    currentFeed = feed
                }
            }
            if let feed = currentFeed {
            let article = Article(title: articleQuery[ArticleTable.title],
                feed: feed,
                time: NSDate(timeIntervalSince1970: articleQuery[ArticleTable.pubDate]),
                description: articleQuery[ArticleTable.description],
                url: articleQuery[ArticleTable.url])
            return article
            }
        }
        return nil
    }
    
    
    func getArticles(feed: Feed) -> [Article] {
        var articles = [Article]()
        let feedArticle = articlesQuery.filter(ArticleTable.feedId == feed.id)
        for articleQuery in feedArticle {
            // id: 1, name: Optional("Alice"), email: alice@mac.com
            let article = Article(title: articleQuery[ArticleTable.title],
                feed: feed,
                time: NSDate(timeIntervalSince1970: articleQuery[ArticleTable.pubDate]),
                description: articleQuery[ArticleTable.description],
                url: articleQuery[ArticleTable.url],
                readed: articleQuery[ArticleTable.Read] == 1)
            articles.append( article )
        }
        return articles
    }
    
    
    func insertArticle(article: Article) {
        
        if let insertId = articlesQuery.insert(ArticleTable.url <- article.url,
            ArticleTable.title <- article.title,
            ArticleTable.description <- article.description,
            ArticleTable.feedId <- article.feed.id,
            ArticleTable.pubDate <- article.time.timeIntervalSince1970
            ).rowid {
                println("inserted article id: \(insertId)")
                article.feed.unreadCount = article.feed.unreadCount  + 1
        }
    }
    
    func updateArticle(article: Article) {
        let updates = articlesQuery.filter(ArticleTable.url == article.url)
        updates.update(ArticleTable.title <- article.title,
            ArticleTable.description <- article.description,
            ArticleTable.pubDate <- article.time.timeIntervalSince1970)
    }
    
    func insertAndUpdateArticle(article: Article) {
        if let oldArticle = findArticle(article.url) {
            updateArticle(article)
        }
        else {
            insertArticle(article)
        }
    }
    
    
    func setReaded(article: Article) {
        let updates = articlesQuery.filter(ArticleTable.url == article.url)
        updates.update(ArticleTable.Read <- 1)
        article.feed.unreadCount = article.feed.unreadCount - 1
        
        updateFeed(article.feed)
    }
    
//    
//    func addRequestFriend(user: User, greeting: String) {
//        database.execute("INSERT INTO REQUESTFRIEND(id, UserName, NickName, Avatar, Greeting, Type, Accept) VALUES ('\(user.id)',  '\(user.name)',  '\(user.nick)', '\(user.avatar)', '\(greeting)', '\(user.userType.rawValue)', 0)")
//    }
//    
//    func updateRequestFriend(user: User, accept: Int) {
//        database.execute("UPDATE REQUESTFRIEND SET Accept = \(accept) where Id = '\(user.id)' ")
//    }
}
