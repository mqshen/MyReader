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
}