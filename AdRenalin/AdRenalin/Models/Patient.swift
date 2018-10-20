//
//  Patient.swift
//  AdRenalin
//
//  Created by Zsolt Pete on 2018. 10. 18..
//  Copyright © 2018. Zsolt Pete. All rights reserved.
//

import Foundation

class Patient: BaseResponse {

    let name: String
    
    init(referenceId: String, name: String){
        self.name = name
        super.init(referenceId: referenceId)
        
    }
    
    override init(snapshot: [String: AnyObject], for referenceId: String) {
        name = snapshot["name"] as! String
        super.init(referenceId: referenceId)
    }
    
    func toAnyObject() -> Any {
        return [
            "name": name,
        ]
    }
    
}
