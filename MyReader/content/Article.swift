//
//  Article.swift
//  MyReader
//
//  Created by GoldRatio on 3/17/15.
//  Copyright (c) 2015 GoldRatio. All rights reserved.
//

import Foundation

struct NonPersistedFlags : RawOptionSetType {
    private let value: UInt = 0
    
    init(rawValue value: UInt) { self.value = value }
    init(nilLiteral: ()) {self.value = 0}
    var rawValue: UInt { return value }
    
    var boolValue: Bool { return self.value != 0 }
    
    static var allZeros: NonPersistedFlags { return self(rawValue: 0) }
    static var None: NonPersistedFlags { return self(rawValue: 0) }
    static var CheckForImage: NonPersistedFlags { return self(rawValue: 1) }
    static var Error: NonPersistedFlags { return self(rawValue: 1 << 2) }
    static var Updating: NonPersistedFlags { return self(rawValue: 1 << 3) }
    static var LoadFullHTML: NonPersistedFlags { return self(rawValue: 1 << 4) }
}

class Feed {
    var id: Int64
    var name: String
    var url: String
    var parentId: Int
    var unreadCount: Int
    var lastUpdated: NSDate
    var type: Int
    var nextSibling: Int
    var firstChild: Int
    var nonPersistedFlags: NonPersistedFlags = NonPersistedFlags.allZeros
    
    func setNonPersistedFlag(flag: NonPersistedFlags) {
        nonPersistedFlags = nonPersistedFlags | flag
    }
    
    func clearNonPersistedFlag(flag: NonPersistedFlags) {
        nonPersistedFlags = nonPersistedFlags & ~flag
    }
    
    init(id: Int64, name: String, url: String, parentId: Int = 0, unreadCount: Int = 0, lastUpdated: NSDate = NSDate(timeIntervalSince1970: 0), type: Int = 0 , nextSibling: Int = 0, firstChild: Int = 0) {
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
    
    func inUpdating() -> Bool {
        return nonPersistedFlags & NonPersistedFlags.Updating != NonPersistedFlags.allZeros
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