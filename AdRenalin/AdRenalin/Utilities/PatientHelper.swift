//
//  PatientHelper.swift
//  AdRenalin
//
//  Created by Zsolt Pete on 2018. 10. 20..
//  Copyright © 2018. Zsolt Pete. All rights reserved.
//

import Foundation
import SceneKit
import ARKit

class PatientHelper {
    
    var camaNode: SCNNode?
    var numberOfCama: Float = 0
    
    func getPositions(for counter: Int, hitResult: ARHitTestResult) -> [SCNVector3] {
        var positions = [SCNVector3]()
        let numberOfCama: Float = Float(counter)
        
        for i  in 0..<counter {
            let camaScene = SCNScene(named: "cama.scn")!
            
            let camaNode = camaScene.rootNode
            let width: Float = camaNode.boundingBox.max.x - camaNode.boundingBox.min.x
            let xOffset: Float = (numberOfCama - Float(numberOfCama - Float(i) )) * width * 2.0
            let position = SCNVector3(hitResult.worldTransform.columns.3.x + xOffset,hitResult.worldTransform.columns.3.y, hitResult.worldTransform.columns.3.z)
            positions.append(position)
        }
        return positions
    }
    
    func getDescPositions(patient: Patient) -> (SCNVector3, SCNVector3, SCNVector3) {
        let sleepPatientPosition = patient.node!.worldPosition
        let namePosition = SCNVector3(sleepPatientPosition.x + 0.1, sleepPatientPosition.y + 0.5, sleepPatientPosition.z)
        var diagnosisPosition = namePosition
        diagnosisPosition.y -= 0.05
        var descPosition = diagnosisPosition
        descPosition.y -= 0.2
        return (namePosition, diagnosisPosition, descPosition)
    }
    
}
