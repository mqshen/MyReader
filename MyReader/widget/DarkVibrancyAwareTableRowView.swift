//
//  DarkVibrancyAwareTableRowView.swift
//  MyReader
//
//  Created by GoldRatio on 3/17/15.
//  Copyright (c) 2015 GoldRatio. All rights reserved.
//
import Foundation
import AppKit

public final class DarkVibrancyAwareTableRowView: NSTableRowView {
    var selectedBackgroundColor = NSColorFromRGB(0x484848)
    
    public override func drawSelectionInRect(dirtyRect: NSRect) {
//        if self.window!.keyWindow {
//            if let v = self.window!.firstResponder as? NSView {
//                if isSuperview(superview: v, ofSubview: self) {
//                    super.drawSelectionInRect(dirtyRect)
//                    return
//                }
//            }
//        }
//        NSColor.secondarySelectedControlColor().colorWithAlphaComponent(0.25).setFill()
//        NSRectFill(dirtyRect)
        
        if(self.selected) {
            selectedBackgroundColor.setFill()
            NSRectFill(dirtyRect)
        }
        
        
        //NSColor.alternateSelectedControlColor().setFill()
    }
    
//    public override func drawBackgroundInRect(dirtyRect: NSRect) {
//        selectedBackgroundColor.setFill()
//        NSRectFill(dirtyRect)
//    }
    
    override public func drawBackgroundInRect(dirtyRect: NSRect) {
        self.backgroundColor.set()
        NSRectFill(self.bounds)
    }
    
}

private func isSuperview(#superview:NSView?, ofSubview subview:NSView) -> Bool {
    if subview.superview === superview {
        return	true
    } else {
        if subview.superview == nil {
            return	false
        }
        return	isSuperview(superview: superview, ofSubview: subview.superview!)
    }
}