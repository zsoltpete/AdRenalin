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
import RxCocoa
import RxSwift
import MBProgressHUD

class DetectionViewController: UIViewController {
    
    @IBOutlet weak var sceneView: ARSCNView!
    
    let disposeBag = DisposeBag()
    
    var planes = [OverlayPlane]()
    var patientAdded = false
    
    var chooseTextNode : SCNNode?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MBProgressHUD.showAdded(to: AppDelegate.shared.window!, animated: true)
        DataProvider.shared.getRooms().subscribe(onNext: { [weak self]value in
            self!.addbungalos(counter: 3)
            let textPosition = Constants.Positions.DefaultText
            self!.chooseTextNode = self!.addText(text: "Choose room", position: textPosition)
            self!.sceneView.scene.rootNode.addChildNode(self!.chooseTextNode!)
            MBProgressHUD.hide(for: AppDelegate.shared.window!, animated: true)
        }).disposed(by: disposeBag)
        //self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints,ARSCNDebugOptions.showWorldOrigin]
        
        
        // Set the view's delegate
        sceneView.delegate = nil
        
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
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
            self.nodeIfPushed(location: location)
        }
    }
    
    private func nodeIfPushed(location: CGPoint) {
        
        let hitResults = sceneView.hitTest(location, options: nil)
        if hitResults.count > 0 {
            let result = hitResults[0]
            let node = result.node
            if node.name!.contains("patient") {
                node.addShowMeAnimation()
            }
            print("Patient tapped")
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
            let camaScene = SCNScene(named: "cama.scn")!
            
            let camaNode = camaScene.rootNode
            let width: Float = camaNode.boundingBox.max.x - camaNode.boundingBox.min.x
            let depth: Float = camaNode.boundingBox.max.z - camaNode.boundingBox.min.z
            let xOffset: Float = (numberOfCama - Float(numberOfCama - Float(i) )) * width
            camaNode.position = SCNVector3(hitResult.worldTransform.columns.3.x + xOffset,hitResult.worldTransform.columns.3.y, hitResult.worldTransform.columns.3.z)
            camaNode.name = "cama\(i)"
            
            camaNode.scale = SCNVector3(x: 0.5, y: 0.5, z: 0.5)
            self.sceneView.scene.rootNode.addChildNode(camaNode)
            
            let deadManScene = SCNScene(named: "dead_man.scn")!
            
            let deadManNode = deadManScene.rootNode
            deadManNode.position = SCNVector3(camaNode.position.x, camaNode.position.y, camaNode.position.z  + depth / 10.0)
            deadManNode.name = "dead_man\(i)"
            
            deadManNode.scale = SCNVector3(x: 0.1, y: 0.1, z: 0.1)
            
            self.sceneView.scene.rootNode.addChildNode(deadManNode)
            
        }
        
        
        self.patientAdded = true
    }
    
    private func removeAllPlanes(){
        self.planes.forEach { (plane) in
            plane.removeFromParentNode()
        }
        self.sceneView.delegate = nil
    }
    
    func addbungalos(counter: Int){
       
        
        let positions = BungaloHelper().getPositions(for: counter)
        
        for index in 0...2 {
            let bungaloScene = SCNScene(named: "cama.scn")!
            let node = bungaloScene.rootNode
            node.scale = SCNVector3(0.5, 0.5, 0.5)
            node.position = positions[index]
            
            self.sceneView.scene.rootNode.addChildNode(node)
        }
        
        
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


extension SCNNode {
    func addShowMeAnimation() {
        let rotateOne = SCNAction.rotateBy(x: CGFloat(Float.pi / 2.0), y: 0.0, z: 0, duration: 1.0)
        let hoverUp = SCNAction.moveBy(x: 0, y: 2.0, z: 0, duration: 1.0)
        let scaleUp  = SCNAction.scale(by: 2.0, duration: 1.0)
        let rotateAndHover = SCNAction.group([rotateOne, hoverUp, scaleUp])
        self.runAction(rotateAndHover)
    }
}
