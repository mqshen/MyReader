//
//  FolderView.swift
//  RssReader
//
//  Created by GoldRatio on 3/16/15.
//  Copyright (c) 2015 GoldRatio. All rights reserved.
//

import Cocoa

class TreeNode : Equatable {
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
                    node.parentNode = self
                    self.children.append(node)
                }
            }
        }
        build(self, 0)
    }
    
    init(feed: Feed, nodeId: Int64) {
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
   
    func nodeFromID(n: Int64) -> TreeNode? {
        if (self.feed.id == n) {
            return self
        }
        for node in children {
            let theNode = node.nodeFromID(n)
            if (theNode != nil) {
                return theNode
            }
        }
        return nil
    }
}

func ==(lhs: TreeNode, rhs: TreeNode) -> Bool {
    return lhs.feed.id == rhs.feed.id
}

class FolderView: NSOutlineView {
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}