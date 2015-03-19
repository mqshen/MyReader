//
//  Article.swift
//  MyReader
//
//  Created by GoldRatio on 3/17/15.
//  Copyright (c) 2015 GoldRatio. All rights reserved.
//

import Foundation

class Feed {
    var id: Int
    var name: String
    var url: String
    var parentId: Int
    var unreadCount: Int
    var lastUpdated: NSDate
    var type: Int
    var nextSibling: Int
    var firstChild: Int
    
    init(id: Int, name: String, url: String, parentId: Int, unreadCount: Int , lastUpdated: NSDate , type: Int , nextSibling: Int , firstChild: Int) {
        self.id = id
        self.name = name
        self.url = url
        self.parentId = parentId
        self.unreadCount = unreadCount
        self.lastUpdated = lastUpdated
        self.type = type
        self.nextSibling = nextSibling
        self.firstChild = firstChild
    }
    
    init(name: String, feed: Feed) {
        self.id = feed.id
        self.name = name
        self.url = feed.url
        self.parentId = feed.parentId
        self.unreadCount = feed.unreadCount
        self.lastUpdated = feed.lastUpdated
        self.type = feed.type
        self.nextSibling = feed.nextSibling
        self.firstChild = feed.firstChild
    }
    
    func fullName() -> String {
        if(name.isEmpty) {
            return "未命名"
        }
        return name
    }
}

class Article {
    var title: String
    var feed: Feed
    var time: NSDate
    var description: String
    var url: String
    var readed: Bool
    
    init(title: String, feed: Feed, time: NSDate, description: String, url: String, readed: Bool = false) {
        self.title = title
        self.feed = feed
        self.time = time
        self.description = description
        self.url = url
        self.readed = readed
    }
}