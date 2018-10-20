//
//  BaseResponse.swift
//  AdRenalin
//
//  Created by Zsolt Pete on 2018. 10. 18..
//  Copyright © 2018. Zsolt Pete. All rights reserved.
//

import Foundation

class BaseResponse: NSObject {
    
    var referenceId: String
    
    init(referenceId: String){
        self.referenceId = referenceId
    }
    
    init(snapshot: [String: AnyObject], for referenceId: String) {
        self.referenceId = referenceId
        
    }
    
}

