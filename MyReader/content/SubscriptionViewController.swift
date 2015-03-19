//
//  SubscriptionViewController.swift
//  MyReader
//
//  Created by GoldRatio on 3/17/15.
//  Copyright (c) 2015 GoldRatio. All rights reserved.
//

import Foundation
import Cocoa

class SubscriptionViewController: NSViewController {
    var window: NSWindow?
    var urlInput: NSTextField?
    
    override func loadView() {
        let view = NSView(frame: NSMakeRect(0, 0, 420, 290))
        self.view = view
        
        let urlLabel = NSTextField(frame: CGRectMake(10, 250, 400, 30))
        urlLabel.bordered = false
        urlLabel.backgroundColor = NSColor.clearColor()
        urlLabel.stringValue = "URL："
        urlLabel.editable = false
        self.view.addSubview(urlLabel)
        
        urlInput = NSTextField(frame: CGRectMake(10, 160, 400, 90))
        self.view.addSubview(urlInput!)
        
        let confirmButton = NSButton(frame: CGRectMake(330, 10, 80, 40))
        confirmButton.bezelStyle = NSBezelStyle.RoundedBezelStyle
        confirmButton.target = self
        confirmButton.action = "newSubscription:"
        confirmButton.keyEquivalent = "\r"
        confirmButton.title = "确定"
        self.view.addSubview(confirmButton)
        
        let cancelButton = NSButton(frame: CGRectMake(250, 10, 80, 40))
        cancelButton.bezelStyle = NSBezelStyle.RoundedBezelStyle
        cancelButton.target = self
        cancelButton.action = "hideWindow:"
        cancelButton.title = "取消"
        self.view.addSubview(cancelButton)
    }
    
    func newSubscription(obj: AnyObject?) {
        if let url = self.urlInput?.stringValue {
            if(!url.isEmpty) {
                PersistenceProcessor.sharedInstance.addSubscription(url)
                self.hideWindow(nil)
            }
        }
    }
    
    func hideWindow(obj: AnyObject?) {
        if let window = self.window {
            NSApp.endSheet(window)
            window.orderOut(self)
        }
    }
}