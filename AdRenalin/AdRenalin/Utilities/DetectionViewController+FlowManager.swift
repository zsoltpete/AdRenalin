//
//  DetectionViewController+FlowManager.swift
//  AdRenalin
//
//  Created by Zsolt Pete on 2018. 10. 20..
//  Copyright © 2018. Zsolt Pete. All rights reserved.
//

import Foundation
import UIKit

extension DetectionViewController {
    
    func tapActions(for flowStatus: FlowStatus, touchLocation: CGPoint, recognizer: UIGestureRecognizer){
        switch flowStatus {
        case .chooseRoom:
            self.chooseRoomTapAction(recognizer: recognizer, touchLocation: touchLocation)
        case .detectPlane:
            self.detectPlaneTapAction(touchLocation: touchLocation)
        case .seePatients:
            self.seePatientsTapAction(recognizer: recognizer)
        case .detectPlaneForRooms:
            self.detectPlaneForRoomsTapAction(touchLocation: touchLocation)
        }
    }
    
    private func detectPlaneTapAction(touchLocation: CGPoint) {
        let hitTestResult = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
        
        if !hitTestResult.isEmpty {
            
            guard let hitResult = hitTestResult.first else {
                return
            }
            self.addPatient(hitResult: hitResult, selectedIndex: selectedRoomIndex!)
            self.removeAllPlanes()
        }
    }
    
    private func seePatientsTapAction(recognizer: UIGestureRecognizer){
        let location = recognizer.location(in: sceneView)
        self.nodeIfPushed(location: location)
    }
    
    private func detectPlaneForRoomsTapAction(touchLocation: CGPoint) {
        let hitTestResult = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
        
        if !hitTestResult.isEmpty {
            
            guard let hitResult = hitTestResult.first else {
                return
            }
            self.addbungalos(counter: DataStore.shared.rooms.count, hitResult: hitResult)
            self.removeAllPlanes()
            self.flowStatus = .chooseRoom
        }
    }
    
    private func chooseRoomTapAction(recognizer: UIGestureRecognizer, touchLocation: CGPoint) {
        let hitTestResult = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
        
        if !hitTestResult.isEmpty {
            
            guard let hitResult = hitTestResult.first else {
                return
            }
            let location = recognizer.location(in: sceneView)
            if self.roomIfPushed(location: location) {
                self.addPatient(hitResult: hitResult, selectedIndex: selectedRoomIndex!)
            } 
        }
        
        
    }
    
}
