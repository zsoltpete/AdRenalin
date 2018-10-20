//
//  Enums.swift
//  AdRenalin
//
//  Created by Zsolt Pete on 2018. 10. 14..
//  Copyright © 2018. Zsolt Pete. All rights reserved.
//

import Foundation

enum BodyType : Int {
    case box = 1
    case plane = 2
    case car = 3
}

enum FlowStatus {
    case detectPlaneForRooms
    case chooseRoom
    case detectPlane
    case seePatients
}
