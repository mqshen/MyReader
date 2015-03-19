//
//  FolderView.swift
//  RssReader
//
//  Created by GoldRatio on 3/16/15.
//  Copyright (c) 2015 GoldRatio. All rights reserved.
//

import Cocoa

class TreeNode {
    var parentNode: TreeNode?
    var children: [TreeNode]
    var feed: Feed
    var progressIndicator: NSProgressIndicator?
    
    init(feeds: [Feed]) {
        self.feed = Feed(id: 0, name: "", url: "", parentId: 0, unreadCount: 0, lastUpdated: NSDate(), type: 1, nextSibling: 0, firstChild: 0)
        self.children = [TreeNode]()
        func build(treeNode: TreeNode, parendId: Int) {
            for feed in feeds {
                if(feed.parentId == parendId) {
                    let node = TreeNode(feed: feed, nodeId: feed.id)
                    self.children.append(node)
                }
            }
        }
        build(self, 0)
    }
    
    init(feed: Feed, nodeId: Int) {
        self.feed = feed
        self.children = [TreeNode]()
    }
    
    func canHaveChild() -> Bool {
        return feed.type == 1
    }
    
    func countOfChildren() -> Int {
        return children.count
    }
    
    func childByIndex(index: Int) -> TreeNode {
        return children[index]
    }
    
    func addChild(node: TreeNode) {
        self.children.append(node)
    }
}

class FolderView: NSOutlineView {
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}