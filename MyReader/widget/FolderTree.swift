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

class FoldersTree: NSView, NSOutlineViewDataSource, NSOutlineViewDelegate {
    
    struct Static {
        static let cellIdentify = "folderCell"
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
        
        scrollView.backgroundColor = NSColor.clearColor()
        scrollView.contentView.backgroundColor = NSColor.redColor()
        
        
        outlineView?.backgroundColor = Static.backgroundColor
        outlineView!.setDataSource(self)
        outlineView!.setDelegate(self)
        
        scrollView.contentView.addSubview(self.outlineView!)
        self.addSubview(scrollView)
        outlineView?.reloadData()
//        let top = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: outlineView!, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0)
//        
//        let bottom = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: outlineView!, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0)
//        
//        let left = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: outlineView!, attribute: NSLayoutAttribute.Left, multiplier: 1, constant: 0)
//        
//        let right = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: outlineView!, attribute: NSLayoutAttribute.Right, multiplier: 1, constant: 0)
//        outlineView?.addConstraints([top, bottom, left, right])
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
            println("cell display")
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
            var result = ImageAndTextView()
            let test = NSImage(named: "statusBarIconUnread.png")
            result.iconImage = test
            result.text = node.feed.fullName()
            return result
        }
        return nil
    }
    
    func outlineView(outlineView: NSOutlineView, rowViewForItem item: AnyObject) -> NSTableRowView? {
        var rowView = outlineView.makeViewWithIdentifier(Static.cellIdentify, owner: self) as? DarkVibrancyAwareTableRowView
        if(rowView == nil) {
            rowView = DarkVibrancyAwareTableRowView()
            rowView?.identifier = Static.cellIdentify
        }
        return rowView
    }
    
    func outlineView(outlineView: NSOutlineView, isGroupItem item: AnyObject) -> Bool {
        return true
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

    
}