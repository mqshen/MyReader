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
    
    init() {
        
    }
    
    func isRefreshingFolder(feed: Feed) -> Bool {
        return operations.contains(feed.url)
    }
    
    func refresh(feeds: [Feed]) {
        for feed in feeds {
            if(!isRefreshingFolder(feed)) {
                operations.add(feed.url)
                self.pumpSubscriptionRefresh(feed)
            }
        }
        operations.removeAll()
    }
    
    func pumpSubscriptionRefresh(feed: Feed) {
        Alamofire.request(.GET, feed.url)
            .responseString { (request, response, string, _) in
                if let xmlToParse = string? {
                    let xml = SWXMLHash.parse(xmlToParse)
                    if let rootNode = xml["rss"].element {
                        if(feed.name.isEmpty) {
                            if let name = xml["rss"]["channel"]["title"].element?.text {
                                var feed = Feed(name: name, feed: feed)
                                PersistenceProcessor.sharedInstance.updateFeed(feed)
                            }
                        }
                        for elem in xml["rss"]["channel"]["item"] {
                            let title = elem["title"].element?.text
                            let time = elem["pubDate"].element?.text?.subString(0, end: 10)
                            let dateFormatter = NSDateFormatter()
                            dateFormatter.dateFormat = "YYYY-MM-DD"
                            let date = dateFormatter.dateFromString(time!)
                            
                            let url = elem["link"].element?.text
                            let description = elem["description"].element?.text
                            let article = Article(title: title!, feed: feed, time: date!, description: description!, url: url!)
                            PersistenceProcessor.sharedInstance.insertAndUpdateArticle(article)
                        }
                    }
                    else if let rootNode = xml["feed"].element {
                        if(feed.name.isEmpty) {
                            if let name = xml["feed"]["title"].element?.text {
                                var feed = Feed(name: name, feed: feed)
                                PersistenceProcessor.sharedInstance.updateFeed(feed)
                            }
                        }
                        for elem in xml["feed"]["entry"] {
                            let title = elem["title"].element?.text
                            let time = elem["updated"].element?.text?.subString(0, end: 10)
                            let dateFormatter = NSDateFormatter()
                            dateFormatter.dateFormat = "YYYY-MM-DD"
                            let date = dateFormatter.dateFromString(time!)
                            
                            let url = elem["link"].element?.attributes["href"]
                            let description = elem["content"].element?.text
                            let article = Article(title: title!, feed: feed, time: date!, description: description!, url: url!)
                            PersistenceProcessor.sharedInstance.insertAndUpdateArticle(article)
                        }
                    }
                    
                }
        }
    }
}