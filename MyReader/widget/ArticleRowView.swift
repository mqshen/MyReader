//
//  ArticleRowView.swift
//  MyReader
//
//  Created by GoldRatio on 3/17/15.
//  Copyright (c) 2015 GoldRatio. All rights reserved.
//

import Foundation
import Cocoa

class ArticleRowView: NSView {
    var leftPadding: CGFloat = 10
    var imageSize = CGSizeMake(18, 18)
    var article: Article?
    
//    override init() {
//        super.init()
//        self.addObserver(self, forKeyPath: "frame", options: NSKeyValueObservingOptions.New, context: nil)
//    }
//    
//    override init(frame frameRect: NSRect) {
//        super.init(frame: frameRect)
//        self.addObserver(self, forKeyPath: "frame", options: NSKeyValueObservingOptions.New, context: nil)
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
    override func drawRect(rect: CGRect) {
        if let article = self.article {
            
            let contentWidth = bounds.size.width - 2 * leftPadding
            let textFontAttributes = [
                NSFontAttributeName : NSFont.boldSystemFontOfSize(10),
                NSForegroundColorAttributeName: NSColorFromRGB(0x9B9A96, aplpha: 1),
            ]
            let string = NSAttributedString(string: article.feed.name, attributes: textFontAttributes)
            var top: CGFloat = bounds.size.height - 15
            string.drawAtPoint(CGPointMake(leftPadding, top))
            
            let time =  NSAttributedString(string: article.time.detailDateTimeUntilNow(), attributes: textFontAttributes)
            var left = CGRectGetWidth(bounds) - time.size.width - leftPadding
            time.drawAtPoint(CGPointMake(left, top))
            
            top = top - 5
            
            var font = NSFont.systemFontOfSize(14)
            if(!article.readed) {
                font = NSFont.boldSystemFontOfSize(14)
            }
            let titleFontAttributes = [
                NSFontAttributeName : font,
                NSForegroundColorAttributeName: NSColorFromRGB(0x5E5D5A, aplpha: 1),
            ]
            
            let title = NSAttributedString(string: article.title, attributes: titleFontAttributes)
            let rowNumber = min(ceil(title.size.width / contentWidth), 2)
            let height: CGFloat = rowNumber * 18
            top = top - height
            title.drawInRect(CGRectMake(leftPadding, top, contentWidth, height))
            
        }
    }
   
}