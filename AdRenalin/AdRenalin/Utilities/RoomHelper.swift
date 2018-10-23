//
//  RoomHelper.swift
//  AdRenalin
//
//  Created by Zsolt Pete on 2018. 10. 23..
//  Copyright © 2018. Zsolt Pete. All rights reserved.
//

import Foundation
import SceneKit

class RoomHelper {
    
    func getPostion(of roomPosition: SCNVector3) -> SCNVector3{
        var textPosition = roomPosition
        textPosition.y += 0.1
        textPosition.x -= 0.05
        return textPosition
    }
    
}
