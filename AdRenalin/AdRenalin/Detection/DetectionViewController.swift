//
//  DetectionViewController.swift
//  AdRenalin
//
//  Created by Zsolt Pete on 2018. 10. 14..
//  Copyright © 2018. Zsolt Pete. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class DetectionViewController: UIViewController {
    
    @IBOutlet weak var sceneView: ARSCNView!
    
    var planes = [OverlayPlane]()
    var patientAdded = false
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints,ARSCNDebugOptions.showWorldOrigin]
        
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
        
        registerGestureRecognizers()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        configuration.planeDetection = .horizontal
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    private func registerGestureRecognizers() {
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
        self.sceneView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func tapped(recognizer :UIGestureRecognizer) {
        
        let sceneView = recognizer.view as! ARSCNView
        let touchLocation = recognizer.location(in: sceneView)
        
        if !patientAdded {
            let hitTestResult = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
            
            if !hitTestResult.isEmpty {
                
                guard let hitResult = hitTestResult.first else {
                    return
                }
                self.addPatient(hitResult :hitResult)
                self.removeAllPlanes()
            }
        } else {
            let location = recognizer.location(in: sceneView)
            self.removeNode(location: location)
        }
    }
    
    private func removeNode(location: CGPoint) {
        
        let hitResults = sceneView.hitTest(location, options: nil)
        if hitResults.count > 0 {
            let result = hitResults[0]
            let node = result.node
            node.removeFromParentNode()
            print("Patient removed")
        }
    }
    
    private func addPatient(hitResult :ARHitTestResult) {
        
        let numberOfCama: Float = 3
        
        for i  in 0..<3 {
            let modelScene = SCNScene(named: "cama.scn")!
            
            let modelNode = modelScene.rootNode
            let width: Float = modelNode.boundingBox.max.x - modelNode.boundingBox.min.x
            let offset: Float = (numberOfCama - Float(numberOfCama - Float(i) )) * width
            modelNode.position = SCNVector3(hitResult.worldTransform.columns.3.x + offset,hitResult.worldTransform.columns.3.y, hitResult.worldTransform.columns.3.z)
            modelNode.name = "dead_man"
            
            modelNode.scale = SCNVector3(x: 0.5, y: 0.5, z: 0.5)
            self.sceneView.scene.rootNode.addChildNode(modelNode)
            
        }
        
        
        self.patientAdded = true
    }
    
    private func removeAllPlanes(){
        self.planes.forEach { (plane) in
            plane.removeFromParentNode()
        }
        self.sceneView.delegate = nil
    }
    
}

extension DetectionViewController: ARSCNViewDelegate {
    
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        if !(anchor is ARPlaneAnchor) {
            return
        }
        
        let plane = OverlayPlane(anchor: anchor as! ARPlaneAnchor)
        self.planes.append(plane)
        node.addChildNode(plane)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        
        let plane = self.planes.filter { plane in
            return plane.anchor.identifier == anchor.identifier
            }.first
        
        if plane == nil {
            return
        }
        
        plane?.update(anchor: anchor as! ARPlaneAnchor)
    }
}
