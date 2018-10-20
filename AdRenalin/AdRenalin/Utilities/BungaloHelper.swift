//
//  BungaloHelper.swift
//  AdRenalin
//
//  Created by Zsolt Pete on 2018. 10. 18..
//  Copyright © 2018. Zsolt Pete. All rights reserved.
//

import Foundation
import SceneKit

class BungaloHelper {
    
    func getPositions(for counter: Int) -> [SCNVector3] {
        var positions = [SCNVector3]()
        switch counter {
        case 1:
            positions.append(self.getFirstBungaloPosition())
        case 2:
            positions.append(self.getFirstBungaloPosition())
            positions.append(self.getSecondBungaloPosition())
        case 3:
            positions.append(self.getFirstBungaloPosition())
            positions.append(self.getSecondBungaloPosition())
            positions.append(self.getThirdBungaloPosition())
        default:
            break
        }
        return positions
    }
    
    private func getFirstBungaloPosition() -> SCNVector3 {
        let position = SCNVector3(0, -0.2, -0.4)
        return position
    }
    
    private func getSecondBungaloPosition() -> SCNVector3 {
        let position = SCNVector3(0.2, -0.2, -0.4)
        return position
    }
    
    private func getThirdBungaloPosition() -> SCNVector3 {
        let position = SCNVector3(-0.2, -0.2, -0.4)
        return position
    }
    
}
