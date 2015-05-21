//
//  FeedOperation.swift
//  MyReader
//
//  Created by GoldRatio on 3/21/15.
//  Copyright (c) 2015 GoldRatio. All rights reserved.
//

import Foundation
import Alamofire

public typealias OperationCompletedHandler = (NSURLRequest, NSHTTPURLResponse?, String?, NSError?) -> Void

class FeedOperation: NSOperation {
    let url: String
    var completeHandler: OperationCompletedHandler?
    
    init(url: String,
        completeHandler: OperationCompletedHandler?) {
            
            self.url = url
            self.completeHandler = completeHandler
            
            super.init()
    }
    
    override func start() {
        
        Alamofire.request(.GET, self.url)
            .responseString { (request, response, string, error) in
                if let completeHandler = self.completeHandler {
                    
                    dispatch_main_sync_safe {
                        completeHandler(request, response, string, error)
                    }
                }
        }
    }
    
    func reset() {
        self.completeHandler = nil;
    }
    
}