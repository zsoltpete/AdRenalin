//
//  Room.swift
//  AdRenalin
//
//  Created by Zsolt Pete on 2018. 10. 18..
//  Copyright © 2018. Zsolt Pete. All rights reserved.
//

import Foundation

class Room: BaseResponse {
    let patients: [Patient]
    let name: String
    
    init(referenceId: String, name: String, patients: [Patient]){
        self.name = name
        self.patients = patients
        super.init(referenceId: referenceId)
        
    }
    
    override init(snapshot: [String: AnyObject], for referenceId: String) {
        name = snapshot["name"] as! String
        patients = snapshot["patients"] as! [Patient]
        super.init(referenceId: referenceId)
    }
    
    func toAnyObject() -> Any {
        return [
            "name": name,
            "patients": patients
        ]
    }
    
}
