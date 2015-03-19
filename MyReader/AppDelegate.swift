//
//  AppDelegate.swift
//  MyReader
//
//  Created by GoldRatio on 3/16/15.
//  Copyright (c) 2015 GoldRatio. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {



    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        println(NSApplication.sharedApplication().mainMenu?)
        NSApplication.sharedApplication().mainMenu?.delegate = self
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }

    func menuNeedsUpdate(menu: NSMenu) {
        println("update")
    }
    
    func menuWillOpen(menu: NSMenu) {
        println("open")
    }
    
    override func validateMenuItem(menuItem: NSMenuItem) -> Bool {
        return true
    }
    
    @IBAction func newSubscriptionMenuItemClicked(sender: AnyObject) {
        if let window = NSApplication.sharedApplication().mainWindow? {
            let viewController = SubscriptionViewController()
            var sheet = NSWindow(contentViewController: viewController)
            viewController.window = sheet
            NSApp.beginSheet(sheet, modalForWindow: window, modalDelegate: nil, didEndSelector: nil, contextInfo: nil)
        }
    }
    
    @IBAction func paste(sender: AnyObject) {
        NSApp.sendAction(Selector("paste:"), to:nil, from:self)
    }
    
    @IBAction func copy(sender: AnyObject) {
        
    }
}

