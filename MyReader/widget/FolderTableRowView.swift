//
//  FolderTableRowView.swift
//  MyReader
//
//  Created by GoldRatio on 3/17/15.
//  Copyright (c) 2015 GoldRatio. All rights reserved.
//

import Foundation
import Cocoa

class FolderTableRowView: NSTableRowView {
    
    override func drawBackgroundInRect(dirtyRect: NSRect) {
        NSColor.redColor().set()
        NSRectFill(self.bounds)
    }
    
}