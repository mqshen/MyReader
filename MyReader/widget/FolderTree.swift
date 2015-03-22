//
//  FolderTree.swift
//  RssReader
//
//  Created by GoldRatio on 3/16/15.
//  Copyright (c) 2015 GoldRatio. All rights reserved.
//

import Foundation
import Cocoa

protocol FoldersTreeDelegate {
    func didSelect(node: TreeNode)
}

class FoldersTree: NSView, NSOutlineViewDataSource, NSOutlineViewDelegate, NSTableViewDelegate {
    
    struct Static {
        static let cellIdentify = "folderCell"
        static let rowIdentify = "folderRow"
        static let backgroundColor = NSColorFromRGB(0x585858, aplpha: 1)
    }
    
    var delegate: FoldersTreeDelegate?
    
    var rootNode: TreeNode
    var outlineView: NSOutlineView?
    
    init(rootNode: TreeNode, frame frameRect: NSRect) {
        self.rootNode = rootNode
        super.init(frame: frameRect)
        
        
        let scrollView = NSScrollView(frame: self.bounds)
        scrollView.autoresizingMask = NSAutoresizingMaskOptions.ViewWidthSizable |  NSAutoresizingMaskOptions.ViewHeightSizable
        
        
        self.outlineView = NSOutlineView(frame: scrollView.bounds)
        self.outlineView!.autoresizingMask = NSAutoresizingMaskOptions.ViewWidthSizable |  NSAutoresizingMaskOptions.ViewHeightSizable
        self.outlineView?.menu = buildTreeMenu()
        
        
        scrollView.backgroundColor = NSColor.clearColor()
        scrollView.contentView.backgroundColor = NSColor.redColor()
        
        
        self.outlineView?.backgroundColor = Static.backgroundColor
        self.outlineView?.setDataSource(self)
        self.outlineView?.setDelegate(self)
        self.outlineView?.action = "handleSingleClick:"
        self.outlineView?.floatsGroupRows = false
        //self.outlineView?.doubleAction = ""
        
        let column = NSTableColumn(identifier: "column")
        column.title = ""
        column.width = 200
        //column.autoresizingMask = NSAutoresizingMaskOptions.ViewWidthSizable |  NSAutoresizingMaskOptions.ViewHeightSizable
        column.resizingMask = NSTableColumnResizingOptions.AutoresizingMask
        self.outlineView?.addTableColumn(column)
        
        
        scrollView.documentView = self.outlineView
        self.addSubview(scrollView)
        self.outlineView?.reloadData()

        let nc = NSNotificationCenter.defaultCenter()
        nc.addObserver(self, selector: "handleFolderUpdate:", name: Constants.FolderUpdate, object: nil)
        nc.addObserver(self, selector: "handleFolderAdded:", name: Constants.FolderAdd, object: nil)
        nc.addObserver(self, selector: "handleFolderDelete:", name: Constants.FolderDelete, object: nil)
    }

    func buildTreeMenu() -> NSMenu {
        let treeMenu = NSMenu()
        let deleteMenu = NSMenuItem(title: "Delete", action: "deleteNode:", keyEquivalent: "")
        treeMenu.addItem(deleteMenu)
        return treeMenu
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func outlineView(outlineView: NSOutlineView, isItemExpandable item: AnyObject) -> Bool {
        if let node = item as? TreeNode {
            return node.canHaveChild()
        }
        return true//rootNode.canHaveChild
    }
    
    func outlineView(outlineView: NSOutlineView, numberOfChildrenOfItem item: AnyObject?) -> Int {
        if let node = item as? TreeNode {
            return node.countOfChildren()
        }
        return rootNode.countOfChildren()
    }
    
    func outlineView(outlineView: NSOutlineView, child index: Int, ofItem item: AnyObject?) -> AnyObject {
        if let node = item as? TreeNode {
            return node.childByIndex(index)
        }
        return rootNode.childByIndex(index)
    }
    
    
    func outlineView(outlineView: NSOutlineView, setObjectValue object: AnyObject?, forTableColumn tableColumn: NSTableColumn?, byItem item: AnyObject?) {
        if let node = item as? TreeNode {
        }
    }
    
//    func outlineView(outlineView: NSOutlineView, objectValueForTableColumn tableColumn: NSTableColumn?, byItem item: AnyObject?) -> AnyObject? {
//        if let node = item as? TreeNode {
//            let folder = node.folder
//            let rowIndex = outlineView.rowForItem(item)
//            return NSAttributedString(string: "222", attributes: ["": ""])
//        }
//        return NSAttributedString(string: "111", attributes: ["": ""])
//    }
    
    func outlineView(outlineView: NSOutlineView, willDisplayCell cell: AnyObject, forTableColumn tableColumn: NSTableColumn?, item: AnyObject) {
        if(tableColumn?.identifier ==  "folderColumns") {
            let node = item as TreeNode
            let folder = node.feed
        }
    }
    
    
    func outlineView(outlineView: NSOutlineView, dataCellForTableColumn tableColumn: NSTableColumn?, item: AnyObject) -> NSCell? {
        let node = item as TreeNode
        return NSCell(textCell: node.feed.fullName())
    }
    
    func outlineView(outlineView: NSOutlineView!, shouldShowOutlineCellForItem item: AnyObject!) -> Bool  {
        return true
    }
    
    func outlineView(outlineView: NSOutlineView, viewForTableColumn tableColumn: NSTableColumn?, item: AnyObject) -> NSView? {
        //var result = outlineView.makeViewWithIdentifier("DataCell", owner: self) as NSTableCellView
        if let node = item as? TreeNode {
            
            var cellView = outlineView.makeViewWithIdentifier(Static.cellIdentify, owner: self) as? ImageAndTextView
            if(cellView == nil) {
                cellView = ImageAndTextView()
                cellView?.identifier = Static.cellIdentify
            }
            let icon = node.feed.icon != nil ? node.feed.icon : NSImage(named: "statusBarIconUnread.png")
            cellView?.iconImage = icon
            cellView?.text = node.feed.fullName()
            cellView?.inProgress = node.feed.inUpdating()
            cellView?.count = node.unReadCount
            if(node.feed.parentId != 0 ) {
                cellView?.leftPadding = 15
            }
            else {
                cellView?.leftPadding = 0
            }
            
            return cellView
        }
        return nil
    }
    
    func outlineView(outlineView: NSOutlineView, rowViewForItem item: AnyObject) -> NSTableRowView? {
        var rowView = outlineView.makeViewWithIdentifier(Static.rowIdentify, owner: self) as? DarkVibrancyAwareTableRowView
        if(rowView == nil) {
            rowView = DarkVibrancyAwareTableRowView()
            rowView?.identifier = Static.rowIdentify
        }
        return rowView
    }
    
    func outlineView(outlineView: NSOutlineView, isGroupItem item: AnyObject) -> Bool {
        if let node = item as? TreeNode {
            if(node == rootNode) {
                return false
            }
            else if(node.canHaveChild()) {
                return true
            }
        }
        return false
    }
   
    func outlineView(outlineView: NSOutlineView, heightOfRowByItem item: AnyObject) -> CGFloat {
        return 30
    }
    
   
    
    func outlineView(outlineView: NSOutlineView, didAddRowView rowView: NSTableRowView, forRow row: Int) {
        rowView.backgroundColor = Static.backgroundColor
    }
    
    func outlineView(outlineView: NSOutlineView, shouldSelectItem item: AnyObject) -> Bool {
        if let node = item as? TreeNode {
            if let delegate = self.delegate {
                delegate.didSelect(node)
            }
        }
        return true
    }
    
    func handleSingleClick(outlineView: NSOutlineView) {
        if let node = outlineView.itemAtRow(outlineView.clickedRow) as? TreeNode {
            if(node.canHaveChild()) {
                if(outlineView.isItemExpanded(node)) {
                    outlineView.collapseItem(node)
                }
                else {
                    outlineView.expandItem(node)
                }
            }
        }
    }
    
   
    func outlineView(outlineView: NSOutlineView, shouldShowOutlineCellForItem item: AnyObject) -> Bool {
        return true
    }
    
    func handleFolderAdded(nc: NSNotification) {
        if let feed = nc.object as? Feed {
            let node = feed.parentId == 0 ? rootNode : rootNode
            let newNode = TreeNode(feed: feed, nodeId: feed.id)
            node.addChild(newNode)
            self.reloadFolderItem(node)
        }
    }
    
    func handleFolderUpdate(nc: NSNotification) {
        if let feed = nc.object as? Feed {
            if(feed.id == 0) {
                self.reloadFolderItem(rootNode)
            }
            else {
                self.updateFolder(feed.id, recurseToParents: true)
            }
        }
    }
    
    
    func handleFolderDelete(nc: NSNotification) {
        if let feed = nc.object as? Feed {
            if let node = self.rootNode.nodeFromID(feed.id) {
                if let parentNode = node.parentNode? {
                    node.removeFromParent()
                    self.reloadFolderItem(parentNode)
                }
            }
        }
    }
    
    func updateFolder(feedId: Int64, recurseToParents: Bool) {
        if var node = rootNode.nodeFromID(feedId) {
            let rows = NSIndexSet(index: outlineView!.rowForItem(node))
            let cols = NSIndexSet(index: 0)
            outlineView?.reloadDataForRowIndexes(rows, columnIndexes: cols)
            if(recurseToParents) {
                while(node.parentNode != nil && node.parentNode != rootNode) {
                    if var parentNode = node.parentNode? {
                        //outlineView?.reloadItem(parentNode)
                        outlineView?.reloadDataForRowIndexes(rows, columnIndexes: cols)
                        node = parentNode
                    }
                }
            }
        }
    }
    
    func reloadFolderItem(node: TreeNode) {
        if (node == rootNode) {
            outlineView?.reloadData()
        }
        else {
            outlineView?.reloadItem(node, reloadChildren: true)
//            let rowIndex = outlineView!.rowForItem(node)
//            var rows = NSIndexSet(index: rowIndex)
//            var cols = NSIndexSet(index: 0)
//            if(node.canHaveChild()) {
//                let range = NSMakeRange(0, 100)
//                rows = NSIndexSet(indexesInRange: range)
//                var cols = NSIndexSet(indexesInRange: NSMakeRange(0, 2))
//            }
//            outlineView?.reloadDataForRowIndexes(rows, columnIndexes: cols)
            //outlineView?.reloadItem(node, reloadChildren: true)
        }
    }
    
    func tableViewSelectionDidChange(notification: NSNotification) {
        println("row selected")
    }
    
    func deleteNode(sender: AnyObject?) -> Bool {
        if let selectedRow = self.outlineView?.selectedRow {
            if let node = self.outlineView?.itemAtRow(selectedRow) as? TreeNode {
                PersistenceProcessor.sharedInstance.deleteFeed(node.feed)
                return true
            }
        }
        return false
    }
}