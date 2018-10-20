//
//  SCNNode+Helpers.swift
//  AdRenalin
//
//  Created by Zsolt Pete on 2018. 10. 20..
//  Copyright © 2018. Zsolt Pete. All rights reserved.
//

import Foundation
import SceneKit

extension SCNNode {
    
    func contain(position: SCNVector3) -> Bool{
        let betweenX = true
        //let betweenX = self.boundingBox.min.x < position.x && self.boundingBox.max.x > position.x
        let betweenY = self.boundingBox.min.y < position.y && self.boundingBox.max.y > position.y
        let betweenZ = self.boundingBox.min.z < position.z && self.boundingBox.max.z > position.z
        
        if betweenX && betweenY && betweenZ {
            return true
        }
        return false
    }
    
}

extension SCNVector3 {
    
    static func ==(lhs: SCNVector3, rhs: SCNVector3) -> Bool{
        return lhs.x == rhs.x && lhs.y == rhs.y && lhs.z == rhs.z
    }
    
}
