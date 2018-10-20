//
//  Room.swift
//  AdRenalin
//
//  Created by Zsolt Pete on 2018. 10. 18..
//  Copyright © 2018. Zsolt Pete. All rights reserved.
//

import Foundation
import SceneKit

class Room: BaseResponse {
    var patients: [Patient]
    let name: String
    
   //Locally
    var node: SCNNode?
    
    init(referenceId: String, name: String, patients: [Patient]){
        self.name = name
        self.patients = patients
        super.init(referenceId: referenceId)
        
    }
    
    override init(snapshot: [String: AnyObject], for referenceId: String) {
        name = snapshot["id"] as! String
        let patientShanpshot = snapshot["patients"] as! [AnyObject]
        self.patients = [Patient]()
        for patient in patientShanpshot {
            self.patients.append(Patient(snapshot: patient as! [String: AnyObject] , for: referenceId))
        }
        super.init(referenceId: referenceId)
    }
    
    func toAnyObject() -> Any {
        return [
            "id": name,
            "patients": patients
        ]
    }
    
}
