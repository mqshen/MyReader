//
//  ImageAndTextView.swift
//  MyReader
//
//  Created by GoldRatio on 3/17/15.
//  Copyright (c) 2015 GoldRatio. All rights reserved.
//

import Foundation
import Cocoa

class ImageAndTextView: NSView {
    var imageSize = Constants.IconSize
    var iconImage: NSImage?
    var text: String?
    var count: Int = 0
    var leftPadding: CGFloat = 0
    private var progressIndicator: NSProgressIndicator?
    private var _inProgress: Bool = false
    
    var inProgress: Bool {
        get {
            return _inProgress
        }
        set {
            if (_inProgress != newValue) {
                _inProgress = newValue
                refreshProgress()
            }
        }
    }
    
    func refreshProgress() {
        if(_inProgress) {
            if (progressIndicator == nil) {
                progressIndicator = NSProgressIndicator(frame: CGRectMake(0, 0, imageSize.width, imageSize.height))
                progressIndicator?.controlSize = NSControlSize.SmallControlSize
                progressIndicator?.style = NSProgressIndicatorStyle.SpinningStyle
                progressIndicator?.usesThreadedAnimation = true
            }
            if let indicator = self.progressIndicator? {
                var frame = indicator.frame
                frame.origin.x = self.bounds.size.width - imageSize.width - 5
                frame.origin.y = (self.bounds.size.height - imageSize.height) / 2
                progressIndicator?.frame = frame
                if (progressIndicator!.superview != self) {
                    self.addSubview(indicator)
                }
                progressIndicator?.startAnimation(self)
            }
        }
        else {
            progressIndicator?.removeFromSuperview()
        }
    }
    
    override func drawRect(rect: CGRect) {
        // Drawing code
        
        //        var redView = UIView()
        //        redView.frame = CGRectMake(10, 10, 10, 10)
        //        self.addSubview(redView)
        if let image = iconImage {
            let padding = (rect.size.height - imageSize.height) / 2
            
            let drawRect = CGRectMake( leftPadding + padding, padding, imageSize.width, imageSize.height)
            
            image.drawInRect(drawRect)
        }
        
        refreshProgress()
        
        if var t = text {
            let textFontAttributes = [
                NSFontAttributeName : NSFont.boldSystemFontOfSize(12),
                NSForegroundColorAttributeName: NSColorFromRGB(0xDADADA, aplpha: 1)
            ]
            let string = NSAttributedString(string: t, attributes: textFontAttributes)
            let top = (CGRectGetHeight(bounds) - string.size.height - 2) / 2
            t.drawInRect(CGRectMake(leftPadding + imageSize.width + 10, top, CGRectGetWidth(bounds) - imageSize.width - 30, CGRectGetHeight(bounds) - 2 * top), withAttributes: textFontAttributes)
        }
        
        
        if (count != 0) {
            let number = NSString(format: "%i", count)
            
            // Use the current font point size as a guide for the count font size
            let pointSize = NSFont.boldSystemFontOfSize(14).pointSize
            
            
            let countAttributes = [
                NSFontAttributeName : NSFont.boldSystemFontOfSize(12),
                NSForegroundColorAttributeName: NSColorFromRGB(0xfAfAfA, aplpha: 1)
            ]
            
            let numSize = number.sizeWithAttributes(countAttributes)
            
            // Compute the dimensions of the count rectangle.
            let cellWidth = max(numSize.width + 6, numSize.height + 1) + 1;
            
            
            
            let point = NSMakePoint(self.bounds.size.width - cellWidth - 5,  (self.bounds.size.height - numSize.height) / 2 )
            number.drawAtPoint(point, withAttributes: countAttributes)
        }
    }
    
}