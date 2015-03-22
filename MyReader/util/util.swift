//
//  util.swift
//  MyReader
//
//  Created by GoldRatio on 3/17/15.
//  Copyright (c) 2015 GoldRatio. All rights reserved.
//

import Foundation
import Cocoa

func NSColorFromRGB(rgbValue: UInt, aplpha: CGFloat = 1.0) -> NSColor {
    return NSColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
        alpha: aplpha
    )
}

extension String {
    func positionOf(sub:String)->Int {
        var pos = -1
        if let range = self.rangeOfString(sub) {
            if !range.isEmpty {
                pos = distance(self.startIndex, range.startIndex)
            }
        }
        return pos
    }
    
    
    func subString(start: Int, end: Int) -> String {
        let start = advance(self.startIndex, start)
        let end = advance(self.startIndex, end)
        let range = start..<end
        let substr = self[range]
        return substr
    }
    
    func subStringFrom(pos:Int)->String {
        let start = advance(self.startIndex, pos)
        let end = self.endIndex
        let range = start..<end
        let substr = self[range]
        return substr
    }
    
    func subStringTo(pos:Int)->String {
        let end = advance(self.startIndex, pos-1)
        let range = self.startIndex...end
        let substr = self[range]
        return substr
    }
    func baseURL() -> String {
        if var url = NSURL(string: self) {
            return String(format: "%@://%@", url.scheme!, url.host!)
        }
        return self
    }
}

extension NSMutableString {
    func fixupRelativeImgTags(baseURL: String, length: Int? = nil, start:Int = 0) {
        if let url = baseURL.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding) {
            let imgBaseURL = NSURL(string: url)
            var textLength = self.length
            var srchRange = NSMakeRange(start, textLength - start)
            
            srchRange = self.rangeOfString("<img", options: NSStringCompareOptions.LiteralSearch, range: srchRange)
            srchRange.length = textLength - srchRange.location
            
            if ( srchRange.location != NSNotFound) {
                var srcRange = self.rangeOfString("src=\"", options:NSStringCompareOptions.LiteralSearch, range:srchRange)
                if (srcRange.location != NSNotFound) {
                    // Find the src parameter range.
                    var index = srcRange.location + srcRange.length
                    srcRange.location += srcRange.length
                    srcRange.length = 0
                    while (index < textLength && self.characterAtIndex(index) != 34) {
                        index = index + 1
                        srcRange.length += 1
                    }
                    
                    // Now extract the source parameter
                    var srcPath = self.substringWithRange(srcRange)
                    if (!srcPath.hasPrefix("http:") && !srcPath.hasPrefix("https:") && !srcPath.hasPrefix("data:")) {
                        var imgURL = NSURL(string:srcPath, relativeToURL:imgBaseURL)
                        if let imgURL = imgURL {
                            srcPath = imgURL.absoluteString!
                            self.replaceCharactersInRange(srcRange, withString:srcPath)
                            textLength = self.length
                        }
                    }
                    
                    // Start searching again from beyond the URL
                    srchRange.location = srcRange.location + countElements(srcPath)
                }
                else {
                    srchRange.location = srchRange.location + 1
                }
                self.fixupRelativeImgTags(baseURL, length: textLength - srchRange.location, start: srchRange.location )
            }
        }
    }
}

extension NSNotificationCenter {
    
    func postNotificationOnMainThreadWithName(name: String, object: AnyObject?) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.postNotificationName(name, object: object)
        })
    }
    
}

extension Array {
    mutating func removeObject<U: Equatable>(object: U) {
        var index: Int?
        for (idx, objectToCompare) in enumerate(self) {
            if let to = objectToCompare as? U {
                if object == to {
                    index = idx
                }
            }
        }
        
        if(index != nil) {
            self.removeAtIndex(index!)
        }
    }
}