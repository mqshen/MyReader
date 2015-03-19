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
    
    public override func drawSelectionInRect(dirtyRect: NSRect) {
        if self.window!.keyWindow {
            if let v = self.window!.firstResponder as? NSView {
                if isSuperview(superview: v, ofSubview: self) {
                    super.drawSelectionInRect(dirtyRect)
                    return
                }
            }
        }
        if (self.selectionHighlightStyle != NSTableViewSelectionHighlightStyle.None) {
            NSColor.blackColor().set()
            NSRectFill(self.bounds)
        }
        else {
            NSColor.secondarySelectedControlColor().colorWithAlphaComponent(0.25).setFill()
            NSRectFill(dirtyRect)
        }
        
        //NSColor.alternateSelectedControlColor().setFill()
    }
    
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