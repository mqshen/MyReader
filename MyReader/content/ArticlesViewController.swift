//
//  ArticlesViewController.swift
//  MyReader
//
//  Created by GoldRatio on 3/17/15.
//  Copyright (c) 2015 GoldRatio. All rights reserved.
//

import Foundation
import Cocoa

protocol ArticleSelectDelegate {
    func selectedArticle(article: Article)
}

class ArticlesViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {
    var scrollView: NSScrollView?
    var tableView: NSTableView?
    var articleDelegate: ArticleSelectDelegate?
    var articles: [Article]? {
        didSet {
            self.tableView?.reloadData()
        }
    }
    
    struct Static {
        static let rowIdentify = "articleRow"
        static let cellIdentify = "articleCell"
        static let backgroundColor = NSColorFromRGB(0xDFDEDB)
    }
    
    override func loadView() {
        let view = NSView(frame: CGRectMake(0, 0, 400, 400))
        self.view = view
        
        scrollView = NSScrollView(frame: self.view.bounds)
        scrollView?.autoresizingMask = NSAutoresizingMaskOptions.ViewWidthSizable |  NSAutoresizingMaskOptions.ViewHeightSizable
        
        
        self.view.autoresizesSubviews = true
        scrollView?.autoresizesSubviews = true
        scrollView?.backgroundColor = NSColor.clearColor()
        scrollView?.hasVerticalScroller = true
        
        tableView = NSTableView(frame: self.view.bounds)
        tableView?.setDelegate(self)
        tableView?.setDataSource(self)
        tableView?.autoresizingMask = NSAutoresizingMaskOptions.ViewWidthSizable |  NSAutoresizingMaskOptions.ViewHeightSizable
        
        //scrollView?.contentView.addSubview(tableView!)
        
        tableView?.translatesAutoresizingMaskIntoConstraints = false
        scrollView?.translatesAutoresizingMaskIntoConstraints = false
        
        let column = NSTableColumn(identifier: "column")
        column.title = ""
        column.width = 200
        //column.autoresizingMask = NSAutoresizingMaskOptions.ViewWidthSizable |  NSAutoresizingMaskOptions.ViewHeightSizable
        column.resizingMask = NSTableColumnResizingOptions.AutoresizingMask
        tableView?.addTableColumn(column)
        
        tableView?.columnAutoresizingStyle = NSTableViewColumnAutoresizingStyle.FirstColumnOnlyAutoresizingStyle
        scrollView?.documentView = tableView
        self.view.addSubview(scrollView!)
        
       
        
        tableView?.reloadData()
    }
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        if let articles = self.articles {
            return articles.count
        }
        return 0
    }
   
   
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        //var result = outlineView.makeViewWithIdentifier("DataCell", owner: self) as NSTableCellView
        
        var result = tableView.makeViewWithIdentifier(Static.cellIdentify, owner: self) as? ArticleRowView
        if(result == nil) {
            result = ArticleRowView()
            result?.identifier = Static.cellIdentify
        }
        if let articles = self.articles {
            result?.article = articles[row]
        }
        return result
    }
   
    func tableView(tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        var rowView = tableView.makeViewWithIdentifier(Static.rowIdentify, owner: self) as? DarkVibrancyAwareTableRowView
        if(rowView == nil) {
            rowView = DarkVibrancyAwareTableRowView()
            rowView?.selectedBackgroundColor = Static.backgroundColor
            rowView?.identifier = Static.rowIdentify
        }
        return rowView
    }
    
    func tableView(tableView: NSTableView, willDisplayCell cell: AnyObject, forTableColumn tableColumn: NSTableColumn?, row: Int) {
        
    }
    
    func tableView(tableView: NSTableView, isGroupRow row: Int) -> Bool {
        return false
    }
    
    func tableView(tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 65
    }
    
    func tableView(tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        if let articles = self.articles {
            let article = articles[row]
            if(!article.readed) {
                article.readed = true
                let rows = NSIndexSet(index: row)
                let cols = NSIndexSet(index: 0)
                tableView.reloadDataForRowIndexes(rows, columnIndexes: cols)
                PersistenceProcessor.sharedInstance.setReaded(article)
            }
            self.articleDelegate?.selectedArticle(article)
        }
        return true
    }

}