//
//  Constants.swift
//  AdRenalin
//
//  Created by Zsolt Pete on 2018. 10. 16..
//  Copyright © 2018. Zsolt Pete. All rights reserved.
//

import Foundation
import SceneKit

struct Constants {

    struct Positions {
        
        static let DefaultText = SCNVector3(-0.3, 0.2, -1.0)
        
    }
    
    struct Scales {
        
        static let DefaultTextScale = SCNVector3(0.01,0.01,0.01)
        static let RoomText = SCNVector3(0.005,0.005,0.005)
        static let PatientNameText = SCNVector3(0.004,0.004,0.004)
        static let PatientDescText = SCNVector3(0.002,0.002,0.002)
        static let PatientDiagnosesText = SCNVector3(0.002,0.002,0.002)
        static let DefaultCama = SCNVector3(x: 1.5, y: 1.5, z: 1.5)
        
    }
    
}
