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
    var textNode: SCNNode?
    
    init(referenceId: String, name: String, patients: [Patient]){
        self.name = name
        self.patients = patients
        super.init(referenceId: referenceId)
        
    }
    
    override init(snapshot: [String: AnyObject], for referenceId: String) {
        name = snapshot["id"] as! String
        self.patients = [Patient]()
        guard let patientShanpshot = snapshot["patients"] as? [AnyObject] else {
            super.init(referenceId: referenceId)
            return
        }
        for patient in patientShanpshot {
            if let dict = patient as? [String: AnyObject]  {
                self.patients.append(Patient(snapshot: dict , for: referenceId))
            }
            
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
