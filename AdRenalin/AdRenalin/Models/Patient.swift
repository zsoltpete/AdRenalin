//
//  Patient.swift
//  AdRenalin
//
//  Created by Zsolt Pete on 2018. 10. 18..
//  Copyright © 2018. Zsolt Pete. All rights reserved.
//

import Foundation
import SceneKit

class Patient: BaseResponse {

    let name: String
    let diagnosis: String
    let id: Int
    var desc: String
    
    //Locally
    var node: SCNNode?
    var textNodes: [SCNNode] = []
    var isShowing: Bool = false
    
    override init(snapshot: [String: AnyObject], for referenceId: String) {
        name = snapshot["name"] as! String
        diagnosis = snapshot["diagnosis"] as! String
        id = snapshot["id"] as! Int
        desc = snapshot["desc"] as! String
        super.init(referenceId: referenceId)
    }
    
    func toAnyObject() -> [AnyHashable : Any] {
        return [
            "name": name,
            "diagnosis": diagnosis,
            "id": id,
            "desc": desc
        ]
    }
    
}
