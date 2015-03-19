//
//  FeedListController.swift
//  RssReader
//
//  Created by GoldRatio on 3/16/15.
//  Copyright (c) 2015 GoldRatio. All rights reserved.
//

import Cocoa

class FeedListController: NSViewController, NSOutlineViewDataSource, NSOutlineViewDelegate {
    var feedView: FolderView?
    
    override func loadView() {
        let view = NSView(frame: NSMakeRect(0, 0, 100,100))
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.redColor().CGColor
        self.view = view
        
        self.feedView = FolderView(frame: NSMakeRect(0, 0, 100,100))
        self.feedView?.backgroundColor = NSColor.redColor()
        
        self.view.addSubview(self.feedView!)
    }
   
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return 1
    }
   
}