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
    
    var unReadCount: Int {
        get {
            var count = 0
            if(canHaveChild()) {
                for node in children {
                    count += node.unReadCount
                }
                return count
            }
            return feed.unreadCount
        }
    }
    
    func build(feeds: [Feed], treeNode: TreeNode, parendId: Int64) {
        for feed in feeds {
            if(feed.parentId == parendId) {
                let node = TreeNode(feed: feed, nodeId: feed.id)
                node.parentNode = treeNode
                treeNode.children.append(node)
                build(feeds, treeNode: node, parendId: feed.id)
            }
        }
    }
    
    init() {
        self.feed = Feed(id: 0, name: "", url: "", parentId: 0, unreadCount: 0, lastUpdated: NSDate(), type: 0, nextSibling: 0, firstChild: 0)
        self.children = [TreeNode]()
       
    }
    
    init(feed: Feed, nodeId: Int64) {
        self.feed = feed
        self.children = [TreeNode]()
    }
    
    func canHaveChild() -> Bool {
        return feed.type == 0
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
    
    func removeChild(node: TreeNode) {
        self.children.removeObject(node)
    }
    
    func removeFromParent() {
        self.parentNode?.removeChild(self)
        self.parentNode = nil
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