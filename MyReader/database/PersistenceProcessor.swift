//
//  PersistenceProcessor.swift
//  Campfire
//
//  Created by GoldRatio on 9/3/14.
//  Copyright (c) 2014 GoldRatio. All rights reserved.
//

import Foundation

class PersistenceProcessor
{
    
    class var sharedInstance: PersistenceProcessor {
        struct Singleton {
            static let instance = PersistenceProcessor()
        }
        return Singleton.instance
    }
    
    let database: SQLiteDB
    
    init() {
        
        database = SQLiteDB(name: "wetalk") { (db: COpaquePointer) -> Void in
            
            let sql_stmt = "CREATE TABLE IF NOT EXISTS FEEDS(ID INTEGER PRIMARY KEY , Name TEXT DEFAULT '', Url TEXT, ParentId INTEGER DEFAULT 0, UnreadCount Integer DEFAULT 0, LastUpdated REAL DEFAULT 0, Type Integet DEFAULT 0, NextSibling INTEGER DEFAULT 0, FirstChild INTEGET DEFAULT 0)"
            if sqlite3_exec(db, sql_stmt, nil, nil, nil) != SQLITE_OK {
                println("create table FEEDS failed")
            }
            
            let article_stmt = "CREATE TABLE IF NOT EXISTS ARTICLES(Url TEXT PRIMARY KEY, Title TEXT DEFAULT '', Description TEXT DEFAULT '', FeedId INTEGER DEFAULT 0, PubDate REAL DEFAULT 0, Read INTEGER DEFAULT 0)"
            if sqlite3_exec(db, article_stmt, nil, nil, nil) != SQLITE_OK {
                println("create table article failed")
            }
            
        }
        feeds = self.getFeeds()
    }
    
    var feeds: [Feed] = [Feed]()
    
    func getFeeds() -> [Feed] {
        let data = database.query("SELECT ID, Name, Url, ParentId, UnreadCount, LastUpdated, Type, NextSibling, FirstChild FROM FEEDS")
        
        var feeds = [Feed]()
        for row in data {
            let id = row["ID"]?.asInt()
            let name = row["Name"]?.asString()
            let url = row["Url"]?.asString()
            let parentId = row["ParentId"]?.asInt()
            let unreadCount = row["UnreadCount"]?.asInt()
            let lastUpdated = row["LastUpdated"]?.asDouble()
            let type = row["Type"]?.asInt()
            let nextSibling = row["NextSibling"]?.asInt()
            let firstChild = row["FirstChild"]?.asInt()
            
            let feed = Feed(id: id!, name: name!, url: url!, parentId: parentId!, unreadCount: unreadCount!,
                lastUpdated: NSDate(timeIntervalSince1970: lastUpdated!), type: type!,
                nextSibling: nextSibling!, firstChild: firstChild!)
            feeds.append( feed )
        }
        return feeds
    }
    
    func updateFeed(feed: Feed) {
        database.execute("UPDATE FEEDS SET Name = '\(feed.name)', Url = '\(feed.url)' , ParentId = \(feed.parentId), UnreadCount = \(feed.unreadCount), LastUpdated = \(feed.lastUpdated.timeIntervalSince1970), NextSibling = \(feed.nextSibling), FirstChild = \(feed.firstChild)  where ID = \(feed.id) ")
    }
    
    func addSubscription(url: String) {
        database.execute("INSERT INTO FEEDS(Url) VALUES ('\(url)')")
    }
    
    func findArticle(url: String) -> Article? {
            let data = database.query("SELECT Url, Title, Description, FeedId, PubDate, Read FROM Articles WHERE Url = '\(url)'")
            
            for row in data {
                let url = row["Url"]?.asString()
                let title = row["Title"]?.asString()
                let description = row["Description"]?.asString()
                let feedId = row["FeedId"]?.asInt()
                let pubDate = row["PubDate"]?.asDouble()
                let read = row["Read"]?.asInt()
                
                var currentFeed: Feed? = nil
                for feed in feeds {
                    if(feed.id == feedId!) {
                        currentFeed = feed
                    }
                }
                if let feed = currentFeed {
                    let article = Article(title: title!, feed: feed, time: NSDate(timeIntervalSince1970: pubDate!), description: description!, url: url!)
                    return article
                }
            }
            return nil
    }
    
    func getArticles(feed: Feed) -> [Article] {
        let data = database.query("SELECT Url, Title, Description, FeedId, PubDate, Read FROM Articles Where feedId = \(feed.id) Order By PubDate Desc")
        
        var articles = [Article]()
        for row in data {
            let url = row["Url"]?.asString()
            let title = row["Title"]?.asString()
            let description = row["Description"]?.asString()
            let feedId = row["FeedId"]?.asInt()
            let pubDate = row["PubDate"]?.asDouble()
            let read = row["Read"]?.asInt()
            
            let article = Article(title: title!, feed: feed, time: NSDate(timeIntervalSince1970: pubDate!), description: description!, url: url!)
            articles.append(article)
        }
        return articles
    }
    
    func insertArticle(article: Article) {
        database.execute("INSERT INTO Articles(Url, Title, Description, FeedId, PubDate) Values('\(article.url)', '\(article.title)','\(article.description)',\(article.feed.id),'\(article.time.timeIntervalSince1970)')")
    }
    
    func updateArticle(article: Article) {
        database.execute("UPDATE Articles SET Title = '\(article.title)', Description = '\(article.description)' , PubDate = \(article.time.timeIntervalSince1970) where Url = '\(article.url)' ")
    }
    
    func insertAndUpdateArticle(article: Article) {
        if let oldArticle = findArticle(article.url) {
            updateArticle(article)
        }
        else {
            insertArticle(article)
        }
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
