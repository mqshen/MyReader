//
//  ViewController.swift
//  MyReader
//
//  Created by GoldRatio on 3/16/15.
//  Copyright (c) 2015 GoldRatio. All rights reserved.
//

import Cocoa

struct Constants {
    static let FolderAdd = "MR_Notify_FolderAdded"
    static let FolderUpdate = "MR_Notify_FoldersUpdated"
}

class ViewController: NSViewController, NSSplitViewDelegate, FoldersTreeDelegate, NSMenuDelegate {
    var folderTree: FoldersTree?
    var contentViewController: ContentViewController?
    
    override func loadView() {
        let view = NSView(frame: NSMakeRect(0, 0, 1024, 768))
        self.view = view
        
        NSApplication.sharedApplication().menu?.delegate = self
        
        let splitView = NSSplitView(frame: self.view.bounds)
        splitView.autoresizingMask = NSAutoresizingMaskOptions.ViewWidthSizable |  NSAutoresizingMaskOptions.ViewHeightSizable
        
//        self.view.addConstraint(NSLayoutConstraint(item: self.view, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: splitView, attribute: NSLayoutAttribute.Width, multiplier: 1, constant: 0))
//        
//        self.view.addConstraint(NSLayoutConstraint(item: self.view, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: splitView, attribute: NSLayoutAttribute.Height, multiplier: 1, constant: 0))
        
        
        splitView.dividerStyle = NSSplitViewDividerStyle.Thin
        splitView.vertical = true
        splitView.delegate = self
        
        
        let feeds = PersistenceProcessor.sharedInstance.feeds
        
        RefreshManager.sharedInstance.refresh(feeds)
        
        let rootNode = TreeNode(feeds: feeds)
        
        folderTree = FoldersTree(rootNode: rootNode, frame: NSMakeRect(0, 0, 200, 768))
        folderTree!.delegate = self
        splitView.addSubview(folderTree!)
        
        folderTree?.autoresizingMask = NSAutoresizingMaskOptions.ViewWidthSizable |  NSAutoresizingMaskOptions.ViewHeightSizable
        
        contentViewController = ContentViewController()
        splitView.addSubview(contentViewController!.view)
        splitView.setPosition(200, ofDividerAtIndex: 0)
        
        self.view.addSubview(splitView)
        
        splitView.adjustSubviews()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    func splitView(splitView: NSSplitView, constrainMinCoordinate proposedMinimumPosition: CGFloat, ofSubviewAt dividerIndex: Int) -> CGFloat {
        if(dividerIndex == 0) {
            return 20
        }
        return proposedMinimumPosition
    }

    func splitView(splitView: NSSplitView, constrainMaxCoordinate proposedMaximumPosition: CGFloat, ofSubviewAt dividerIndex: Int) -> CGFloat {
        if(dividerIndex == 0) {
            return 200
        }
        return proposedMaximumPosition
    }
    
    func splitView(splitView: NSSplitView, resizeSubviewsWithOldSize oldSize: NSSize) {
        let dividerThickness: CGFloat = 1.0
        let sv1: NSView = splitView.subviews[0] as NSView
        let sv2: NSView  = splitView.subviews[1] as NSView
        var leftFrame = sv1.frame
        var rightFrame = sv2.frame
        var newFrame = splitView.frame
        
        leftFrame.size.height = newFrame.size.height
        leftFrame.origin = NSMakePoint(0, 0)
        rightFrame.size.width = newFrame.size.width - leftFrame.size.width - dividerThickness
        rightFrame.size.height = newFrame.size.height
        rightFrame.origin.x = leftFrame.size.width + dividerThickness;
        
        
        sv1.frame = leftFrame
        sv2.frame = rightFrame
    }
    
    func didSelect(node: TreeNode) {
        contentViewController?.setNode(node)
    }
}

