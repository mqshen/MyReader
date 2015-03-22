//
//  RefreshManager.swift
//  MyReader
//
//  Created by GoldRatio on 3/17/15.
//  Copyright (c) 2015 GoldRatio. All rights reserved.
//

import Foundation
import Alamofire
import SWXMLHash

class RefreshManager {
    
    class var sharedInstance: RefreshManager {
        struct Singleton {
            static let instance = RefreshManager()
        }
        return Singleton.instance
    }
    
    var maximumConnections = 5
    var countOfNewArticles = 0
    var operations = HashSet<String>()
    private let networkQueue: NSOperationQueue
    
    init() {
        networkQueue = NSOperationQueue()
        networkQueue.maxConcurrentOperationCount = 5
    }
    
    func isRefreshingFolder(feed: Feed) -> Bool {
        return operations.contains(feed.url)
    }
    
    func refresh(feeds: [Feed]) {
        for feed in feeds {
            if(feed.type == 1) {
                if(!isRefreshingFolder(feed)) {
                    operations.add(feed.url)
                    self.setFolderUpdatingFlag(feed, flag: true)
                    self.pumpSubscriptionRefresh(feed)
                }
            }
        }
        operations.removeAll()
    }
    
    func pumpSubscriptionRefresh(feed: Feed) {
        if let url = NSURL(string: feed.url)? {
            
            var request = NSMutableURLRequest(URL: url)
            request.addValue("\(feed.lastUpdated.timeIntervalSince1970)", forHTTPHeaderField: "If-Modified-Since")
            
            let operation = FeedRefreshOperation(request: request,
                progressHandler: nil,
                completeHandler: { (data: NSData?, error: NSError?, finish: Bool) -> Void in
                    if let data = data? {
                        let xml = SWXMLHash.parse(data)
                        
                        if let rootNode = xml["rss"].element {
                            if(feed.name.isEmpty) {
                                if let name = xml["rss"]["channel"]["title"].element?.text {
                                    for link in xml["rss"]["channel"]["link"] {
                                        feed.homePage = link.element?.text
                                    }
                                    feed.name = name
                                }
                            }
                            for elem in xml["rss"]["channel"]["item"] {
                                let title = elem["title"].element?.text
                                let time = elem["pubDate"].element?.text
                                let date = self.formatDate(time)
                                
                                let url = elem["link"].element?.text
                                var description = elem["description"].element?.text
                                if let content = elem["content:encoded"].element? {
                                    description = content.text
                                }
                                let article = Article(title: title!, feed: feed, time: date, description: description!, url: url!)
                                PersistenceProcessor.sharedInstance.insertAndUpdateArticle(article)
                            }
                        }
                        else if let rootNode = xml["feed"].element {
                            if(feed.name.isEmpty) {
                                if let name = xml["feed"]["title"].element?.text {
                                    for link in xml["feed"]["link"] {
                                        feed.homePage = link.element?.text
                                    }
                                    feed.name = name
                                }
                            }
                            for elem in xml["feed"]["entry"] {
                                let title = elem["title"].element?.text
                                let time = elem["updated"].element?.text
                                let date = self.formatDate(time)
                                
                                if let url = elem["link"].element?.attributes["href"]? {
                                    let description = elem["content"].element?.text
                                    let article = Article(title: title!, feed: feed, time: date, description: description!, url: url)
                                    PersistenceProcessor.sharedInstance.insertAndUpdateArticle(article)
                                    
                                }
                            }
                        }
                    }
                    self.setFolderUpdatingFlag(feed, flag: false)
                    PersistenceProcessor.sharedInstance.updateFeed(feed)
                },
                cancelHandler: nil)
            self.networkQueue.addOperation(operation)
            
        }
//        Alamofire.request(.GET, feed.url)
//            .responseString { (request, response, string, _) in
//                if let xmlToParse = string? {
//                    let xml = SWXMLHash.parse(xmlToParse)
//                    if let rootNode = xml["rss"].element {
//                        if(feed.name.isEmpty) {
//                            if let name = xml["rss"]["channel"]["title"].element?.text {
//                                for link in xml["rss"]["channel"]["link"] {
//                                    feed.homePage = link.element?.text
//                                }
//                                feed.name = name
//                            }
//                        }
//                        for elem in xml["rss"]["channel"]["item"] {
//                            let title = elem["title"].element?.text
//                            let time = elem["pubDate"].element?.text
//                            let date = self.formatDate(time)
//                            
//                            let url = elem["link"].element?.text
//                            let description = elem["description"].element?.text
//                            let article = Article(title: title!, feed: feed, time: date, description: description!, url: url!)
//                            PersistenceProcessor.sharedInstance.insertAndUpdateArticle(article)
//                        }
//                    }
//                    else if let rootNode = xml["feed"].element {
//                        if(feed.name.isEmpty) {
//                            if let name = xml["feed"]["title"].element?.text {
//                                for link in xml["feed"]["link"] {
//                                    feed.homePage = link.element?.text
//                                }
//                                feed.name = name
//                            }
//                        }
//                        for elem in xml["feed"]["entry"] {
//                            let title = elem["title"].element?.text
//                            let time = elem["updated"].element?.text
//                            let date = self.formatDate(time)
//                            
//                            if let url = elem["link"].element?.attributes["href"]? {
//                                let description = elem["content"].element?.text
//                                let article = Article(title: title!, feed: feed, time: date, description: description!, url: url)
//                                PersistenceProcessor.sharedInstance.insertAndUpdateArticle(article)
//                                
//                            }
//                        }
//                    }
//                    self.setFolderUpdatingFlag(feed, flag: false)
//                    println("sss")
//                }
//            PersistenceProcessor.sharedInstance.updateFeed(feed)
//        }
    }
    
    func setFolderUpdatingFlag(feed: Feed, flag: Bool) {
        if (flag) {
            feed.setNonPersistedFlag(NonPersistedFlags.Updating)
        }
        else {
            feed.clearNonPersistedFlag(NonPersistedFlags.Updating)
        }
        NSNotificationCenter.defaultCenter().postNotificationName(Constants.FolderUpdate, object: feed)
    }
    
    func refreshFolderIconCacheForSubscriptions(node: TreeNode) {
        if(node.canHaveChild()) {
            for node in node.children {
                self.refreshFolderIconCacheForSubscriptions(node)
            }
        }
        else {
            self.refreshFavIconForFolder(node.feed)
        }
    }
    
    func refreshFavIconForFolder(feed: Feed) {
        if(!feed.inFreshingIcon()) {
            self.pumpFolderIconRefresh(feed)
        }
    }
    
    func pumpFolderIconRefresh(feed: Feed) {
        if let homePage = feed.homePage? {
            let favIconPath = String(format: "%@/favicon.ico", homePage.baseURL())
            if let url = NSURL(string: favIconPath)? {
                let operation = FeedRefreshOperation(request: NSURLRequest(URL: url),
                    progressHandler: nil,
                    completeHandler: { (data: NSData?, error: NSError?, finish: Bool) -> Void in
                        if let e = error? {
                            println("icon not found")
                        }
                        else {
                            if let iconData = data? {
                                if let iconImage = NSImage(data: iconData) {
                                    if(iconImage.valid) {
                                        iconImage.size = Constants.IconSize
                                        feed.icon = iconImage
                                        NSNotificationCenter.defaultCenter().postNotificationOnMainThreadWithName(Constants.FolderUpdate, object: feed)
                                    }
                                }
                            }
                        }
                    },
                    cancelHandler: nil)
                networkQueue.addOperation(operation)
            }
//
//            Alamofire.request(.GET, favIconPath)
//                .response { (request, response, data, error) in
//                    if let e = error? {
//                        println("icon not found")
//                    }
//                    else {
//                        if(response?.statusCode == 200) {
//                            if let iconData = data as? NSData {
//                                if let iconImage = NSImage(data: iconData) {
//                                    if(iconImage.valid) {
//                                        iconImage.size = Constants.IconSize
//                                        feed.icon = iconImage
//                                        NSNotificationCenter.defaultCenter().postNotificationOnMainThreadWithName(Constants.FolderUpdate, object: feed)
//                                    }
//                                }
//                            }
//                        }
//                    }
//            }
        }
    }
    
    func formatDate(time: String?) -> NSDate {
        var date = NSDate()
        if let time = time? {
            let dateFormatter = NSDateFormatter()
            if(time.subString(0, end: 2) == "20" || time.subString(0, end: 2) == "19" ) {
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss+SSS"
            }
            else {
                dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss +SSS"
            }
            if let temp = dateFormatter.dateFromString(time)? {
                date = temp
            }
        }
        return date
    }
}