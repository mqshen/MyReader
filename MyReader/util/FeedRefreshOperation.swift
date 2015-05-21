//
//  FeedRefreshOperation.swift
//  MyReader
//
//  Created by GoldRatio on 3/21/15.
//  Copyright (c) 2015 GoldRatio. All rights reserved.
//

import Foundation
import Alamofire

public typealias ProgressHandler = (Int, Int) -> Void
public typealias CompletedHandler = (NSData?, NSError?, Bool) -> Void
public typealias NoParamsHandler = () -> Void

func synced(lock: AnyObject, closure: () -> ()) {
    objc_sync_enter(lock)
    closure()
    objc_sync_exit(lock)
}

func dispatch_main_sync_safe(closure: () -> ()) {
    if NSThread.isMainThread() {
        closure()
    }
    else {
        dispatch_sync(dispatch_get_main_queue(), closure)
    }
}

class FeedRefreshOperation: NSOperation {
    
    let request: NSURLRequest
    var connection: NSURLConnection?
    var thread: NSThread?
    
    var expectedSize: Int
    
    var responseData: NSMutableData?
    
    var progressHandler: ProgressHandler?
    var completeHandler: CompletedHandler?
    var cancelHandler: NoParamsHandler?
    
    var _isExecuting: Bool = false
    var _isFinished: Bool = false
    
    override var executing: Bool {
        get {
            return _isExecuting
        }
        set {
            if executing == newValue {
                return
            }
            willChangeValueForKey("isExecuting")
            self._isExecuting = newValue
            didChangeValueForKey("isExecuting")
        }
    }
    
    override var finished: Bool {
        get {
            return _isFinished
        }
        set {
            if self._isFinished == newValue {
                return
            }
            willChangeValueForKey("isFinished")
            self._isFinished = newValue
            didChangeValueForKey("isFinished")
        }
    }
    
    init(request: NSURLRequest,
        progressHandler: ProgressHandler?,
        completeHandler: CompletedHandler?,
        cancelHandler: NoParamsHandler?) {
            
            self.request = request
            self.progressHandler = progressHandler
            self.completeHandler = completeHandler
            self.cancelHandler = cancelHandler
            self.expectedSize = 0
            
            super.init()
    }
    
    
    override func start() {
        synced(self) {
            if self.cancelled {
                self.finished = true
                self.reset()
                return
            }
            self.executing = true
            self.connection = NSURLConnection(request: self.request, delegate: self, startImmediately: false)
            self.thread = NSThread.currentThread()
        }
        if let connection = self.connection {
            connection.start()
            
            if let progressHandler = self.progressHandler {
                progressHandler(0, -1)
            }
           
            CFRunLoopRun()
            
            if !self.finished {
                connection.cancel()
//                if let responseData = self.responseData {
//                    if let completeHandler = self.completeHandler? {
//                        dispatch_main_sync_safe {
//                            completeHandler(responseData, nil, false)
//                        }
//                    }
//                    CFRunLoopStop(CFRunLoopGetCurrent())
//                    self.done()
//                }
//                else {
                    self.connect(self.connection, error: NSError(domain: NSURLErrorDomain , code: NSURLErrorTimedOut, userInfo: [NSURLErrorFailingURLErrorKey: self.request.URL!]))
                //}
            }
        }
        else {
            if let completeHandler = self.completeHandler {
                dispatch_main_sync_safe {
                    completeHandler(nil, NSError(domain: NSURLErrorDomain, code: 0, userInfo: [NSLocalizedDescriptionKey : "Connection can't be initialized"]), true)
                }
            }
            
        }
    }
    
    func connection(connection: NSURLConnection!, didReceiveResponse response: NSURLResponse!) {
        var statue = 0
        if let httpResponse = response as? NSHTTPURLResponse {
            if httpResponse.statusCode < 400 {
                let expected = response.expectedContentLength > 0 ? response.expectedContentLength : 0
                self.expectedSize = Int(expected)
                if let progressHandler = self.progressHandler {
                    progressHandler(0, self.expectedSize)
                }
                self.responseData = NSMutableData(capacity: self.expectedSize)
                return
            }
            statue = httpResponse.statusCode
        }
        
        //println(self.request.URL.absoluteURL)
        
        self.connection?.cancel()
        
        if let completeHandler = self.completeHandler {
            dispatch_main_sync_safe {
                completeHandler(nil, NSError(domain: NSURLErrorDomain, code: statue, userInfo: nil), true)
            }
        }
        CFRunLoopStop(CFRunLoopGetCurrent())
        self.done()
        
    }
    
    func connection(connection: NSURLConnection!, didReceiveData data: NSData!) {
        if let responseData = self.responseData {
            responseData.appendData(data)
            let totalSize = responseData.length
            if (self.expectedSize > 0) {
                if let completeHandler = self.completeHandler {
                    if (totalSize >= self.expectedSize) {
                        dispatch_main_sync_safe {
                            completeHandler(responseData, nil, false)
                        }
                    }
                }
            }
            if let progressHandler = self.progressHandler {
                progressHandler(responseData.length, self.expectedSize)
            }
        }
        
    }
    
    
    func connectionDidFinishLoading(connection: NSURLConnection!) {
        synced(self) {
            CFRunLoopStop(CFRunLoopGetCurrent())
            self.thread = nil
            self.connection = nil
        }
        
        if let completeHandler = self.completeHandler {
            dispatch_main_sync_safe {
                completeHandler(self.responseData, nil, true)
            }
        }
        self.completeHandler = nil
        self.done()
    }
    
    func connect(connection: NSURLConnection?, error: NSError) {
        if let completeHandler = self.completeHandler {
            dispatch_main_sync_safe {
                completeHandler(nil, error, true)
            }
        }
        self.done()
    }
    
    func done() {
        self.finished = true
        self.executing = false
        self.reset()
    }
    
    func reset() {
        self.cancelHandler = nil;
        self.completeHandler = nil;
        self.progressHandler = nil;
        self.connection = nil;
        self.thread = nil;
    }
}