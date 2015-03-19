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
    var imageSize = CGSizeMake(18, 18)
    var iconImage: NSImage?
    var text: String?
    
    override func drawRect(rect: CGRect) {
        // Drawing code
        
        //        var redView = UIView()
        //        redView.frame = CGRectMake(10, 10, 10, 10)
        //        self.addSubview(redView)
        if let image = iconImage {
            let padding = (rect.size.height - imageSize.height) / 2
            
            let drawRect = CGRectMake(0, padding, imageSize.width, imageSize.height)
            
            image.drawInRect(drawRect)
        }
        
//        let colorSpace = CGColorSpaceCreateDeviceRGB()
//        let componentCount : UInt = 2
//        
//        let components : [CGFloat] = [
//            0,   0,   0,   0,
//            0.0, 0.0, 0.0, 1.0,
//        ]
//        
//        let locations : [CGFloat] = [0, 1.0]
//        
//        let gradient = CGGradientCreateWithColorComponents(colorSpace, components, locations, componentCount)
//        
//        let startPoint = CGPoint(x: 0, y: CGRectGetHeight(bounds)/2)
//        let endPoint = CGPoint(x: 0, y: CGRectGetHeight(bounds))
//        
//        let unsafeContextPointer = NSGraphicsContext.currentContext()?.graphicsPort
//        
//        if let contextPointer = unsafeContextPointer {
            //CGContextDrawLinearGradient(contextPointer, gradient, startPoint, endPoint, 0)
            if var t = text {
                let textFontAttributes = [
                    NSFontAttributeName : NSFont.boldSystemFontOfSize(14),
                    NSForegroundColorAttributeName: NSColorFromRGB(0xDADADA, aplpha: 1),
                ]
                let string = NSAttributedString(string: t, attributes: textFontAttributes)
                let top = (CGRectGetHeight(bounds) - string.size.height - 2) / 2
                t.drawInRect(CGRectMake(20, top, CGRectGetWidth(bounds) - 20, CGRectGetHeight(bounds) - 2 * top), withAttributes: textFontAttributes)
            }
//        }
    }
    
}