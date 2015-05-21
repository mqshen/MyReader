//
//  AppDelegate.swift
//  MyReader
//
//  Created by GoldRatio on 3/16/15.
//  Copyright (c) 2015 GoldRatio. All rights reserved.
//

import Cocoa
import SWXMLHash

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {


    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        NSApplication.sharedApplication().mainMenu?.delegate = self
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }

    override func validateMenuItem(menuItem: NSMenuItem) -> Bool {
        var mainWindow = NSApplication.sharedApplication().mainWindow
        if let isMainWindowVisible = mainWindow?.visible {
            if(!isMainWindowVisible) {
                return false
            }
            else {
                return true
            }
        }
        return true
    }
    
    @IBAction func importSubscription(sender: AnyObject) {
        if var mainWindow = NSApplication.sharedApplication().mainWindow {
            let panel = NSOpenPanel()
            panel.beginSheetModalForWindow(mainWindow) {
                (result: Int) -> Void in
                
                if result == NSOKButton {
                    if let url = panel.URL {
                        self.importFromFile(url)
                    }
                }
            }
        }
    }
    
    func importFromFile(url: NSURL) {
        if let data = NSData(contentsOfURL: url) {
            let xml = SWXMLHash.parse(data)
            let element = xml["opml"]["body"]
            parseOPML(element)
        }
    }
    
    func parseOPML(xml: XMLIndexer, feed: Feed? = nil) -> Int64 {
        var firstId: Int64 = 0
        var lastId: Int64 = 0
        for element in xml["outline"] {
            let node = element.element
            if("rss" == node?.attributes["type"]) {
                let name = node?.attributes["title"]
                let url = node?.attributes["xmlUrl"]
                let htmlUrl = node?.attributes["htmlUrl"]
                var parentId: Int64 = 0
                if feed != nil {
                    parentId = feed!.id
                }
                let feed = Feed(id: 0, name: name!, url: url!, homePage: htmlUrl, parentId: parentId, unreadCount: 0, lastUpdated: NSDate(timeIntervalSince1970: 0), type: 1, nextSibling: lastId, firstChild: firstId)
                lastId = PersistenceProcessor.sharedInstance.importFeed(feed)
                firstId = lastId
            }
            else {
                let name = node?.attributes["title"]
                var feed = Feed(id: 0, name: name!, url: "", homePage: nil, parentId: 0, unreadCount: 0, lastUpdated: NSDate(timeIntervalSince1970: 0), type: 0, nextSibling: lastId, firstChild: firstId)
                lastId = PersistenceProcessor.sharedInstance.importFeed(feed)
                feed.id = lastId
                firstId = parseOPML(element, feed: feed)
            }
        }
        
        return lastId
    }
    
    @IBAction func newSubscriptionMenuItemClicked(sender: AnyObject) {
        if let window = NSApplication.sharedApplication().mainWindow{
            let viewController = SubscriptionViewController()
            var sheet = NSWindow(contentViewController: viewController)
            viewController.window = sheet
            NSApp.beginSheet(sheet, modalForWindow: window, modalDelegate: nil, didEndSelector: nil, contextInfo: nil)
        }
    }
    
    @IBAction func paste(sender: AnyObject) {
        NSApp.sendAction(Selector("paste:"), to:nil, from:self)
    }
    
    @IBAction func copy(sender: AnyObject) {
        NSApp.sendAction(Selector("copy:"), to:nil, from:self)
    }
    
    @IBAction func selectAll(sender: AnyObject) {
        NSApp.sendAction(Selector("selectAll:"), to:nil, from:self)
    }
    
}

