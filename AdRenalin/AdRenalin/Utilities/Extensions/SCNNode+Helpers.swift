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

extension SCNVector3 {
    enum Axis { case x, y, z }
    enum Direction { case clockwise, counterClockwise }
    func orthogonalVector(around axis: Axis, direction: Direction) -> SCNVector3 {
        switch axis {
        case .x: return direction == .clockwise ? SCNVector3(self.x, -self.z, self.y) : SCNVector3(self.x, self.z, -self.y)
        case .y: return direction == .clockwise ? SCNVector3(-self.z, self.y, self.x) : SCNVector3(self.z, self.y, -self.x)
        case .z: return direction == .clockwise ? SCNVector3(self.y, -self.x, self.z) : SCNVector3(-self.y, self.x, self.z)
        }
    }
}
