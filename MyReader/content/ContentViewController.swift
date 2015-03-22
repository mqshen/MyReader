//
//  ContentViewController.swift
//  MyReader
//
//  Created by GoldRatio on 3/17/15.
//  Copyright (c) 2015 GoldRatio. All rights reserved.
//

import Foundation
import Cocoa
import WebKit

class ContentViewController: NSViewController, NSSplitViewDelegate, ArticleSelectDelegate{
    var articlesViewController: ArticlesViewController?
    var stylePath: String?
    var webView: WebView?
    
    
    override func loadView() {
        if(stylePath == nil) {
            if let path = NSBundle.mainBundle().sharedSupportPath? {
                stylePath = "file://localhost".stringByAppendingString(path.stringByAppendingPathComponent("default.css"))
            }
        }
        let view = NSView(frame: NSMakeRect(0, 0, 1024, 768))
        self.view = view
        
        
        let splitView = NSSplitView(frame: self.view.bounds)
        splitView.dividerStyle = NSSplitViewDividerStyle.Thin
        splitView.vertical = true
        splitView.delegate = self
        
        articlesViewController = ArticlesViewController()
        
        splitView.addSubview(articlesViewController!.view)
        splitView.autoresizingMask = NSAutoresizingMaskOptions.ViewWidthSizable |  NSAutoresizingMaskOptions.ViewHeightSizable
        
        articlesViewController?.view.autoresizingMask = NSAutoresizingMaskOptions.ViewWidthSizable |  NSAutoresizingMaskOptions.ViewHeightSizable
        articlesViewController?.articleDelegate = self
        
        webView = WebView(frame: CGRectMake(0, 0, 900, 900))
        
        //webView?.autoresizingMask = NSAutoresizingMaskOptions.ViewWidthSizable |  NSAutoresizingMaskOptions.ViewHeightSizable
        splitView.addSubview(webView!)
        splitView.setPosition(200, ofDividerAtIndex: 0)
        
        self.view.addSubview(splitView)
        
        splitView.adjustSubviews()
        
    }
    
    func setNode(node: TreeNode) {
        let articles = PersistenceProcessor.sharedInstance.getArticles(node.feed)
        articlesViewController?.articles = articles
    }
    
    func splitView(splitView: NSSplitView, constrainMinCoordinate proposedMinimumPosition: CGFloat, ofSubviewAt dividerIndex: Int) -> CGFloat {
        if(dividerIndex == 0) {
            return 200
        }
        return proposedMinimumPosition
    }
    
    func splitView(splitView: NSSplitView, constrainMaxCoordinate proposedMaximumPosition: CGFloat, ofSubviewAt dividerIndex: Int) -> CGFloat {
        if(dividerIndex == 0) {
            return 400
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
    
    func selectedArticle(article: Article) {
        if let url = NSURL(string: article.url) {
            let request = NSURLRequest(URL: url)
            let html = formatHtml(article)
            webView?.mainFrame.loadHTMLString(html, baseURL: NSURL(string: "/"))
        }
    }
    
    func formatHtml(article: Article) -> String {
        var htmlText = NSMutableString(string: "<!DOCTYPE html><html><head><meta charset=\"UTF-8\" />")
        if let cssfile = self.stylePath? {
            htmlText.appendString("<link rel=\"stylesheet\" type=\"text/css\" href=\"")
            htmlText.appendString(cssfile)
            htmlText.appendString("\"/>")
        }
        
        htmlText.appendString("<meta http-equiv=\"Pragma\" content=\"no-cache\">")
        htmlText.appendString("</head><body>")
        
        htmlText.appendString("<h3 class=\"article-title\"><a href=\"")
        htmlText.appendString(article.url)
        htmlText.appendString("\" target=\"_blank\">")
        htmlText.appendString(article.title)
        htmlText.appendString("</a></h3>")
        
        
        htmlText.appendString("<div class=\"article-meta\"><span class=\"article-meta-item\">")
        htmlText.appendString(article.feed.name)
        htmlText.appendString("</span><span class=\"article-meta-item\">by")
        htmlText.appendString("</span><span class=\"article-meta-item article-timestamp\">")
        htmlText.appendString(article.time.detailDateTimeUntilNow())
        htmlText.appendString("</span></div>")
        htmlText.appendString("<div class=\"article-body\">")
        
        
        var articleBody = NSMutableString(string: article.description)
        
        articleBody.fixupRelativeImgTags(article.url)
        //[articleBody fixupRelativeIframeTags:SafeString([theArticle link])];
        //[articleBody fixupRelativeAnchorTags:SafeString([theArticle link])];
        //htmlArticle = [[NSMutableString alloc] initWithString:articleBody];
        
        htmlText.appendString(articleBody)
        htmlText.appendString("</div></body></html>")
        return htmlText
    }
   
}