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
    var flowStatus = FlowStatus.detectPlaneForRooms
    
    var chooseTextNode : SCNNode?
    var selectedRoom: Room?
    var selectedRoomIndex: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MBProgressHUD.showAdded(to: AppDelegate.shared.window!, animated: true)
        DataProvider.shared.getRooms().subscribe(onNext: { [weak self]value in
            DataStore.shared.rooms = value
            let textPosition = Constants.Positions.DefaultText
            self!.chooseTextNode = self!.addText(text: "HelpText.PlaceRooms".localized, position: textPosition)
            self!.sceneView.scene.rootNode.addChildNode(self!.chooseTextNode!)
            MBProgressHUD.hide(for: AppDelegate.shared.window!, animated: true)
        }).disposed(by: disposeBag)
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
        
        self.tapActions(for: self.flowStatus, touchLocation: touchLocation, recognizer: recognizer)
    }
    
    func nodeIfPushed(location: CGPoint) {
        
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
    
    func roomIfPushed(location: CGPoint) -> Bool{
        
        let hitResults = sceneView.hitTest(location, options: nil)
        if hitResults.count > 0 {
            let result = hitResults[0]
            let node = result.node
            if node.name!.contains("cama") {
                var counter = 0
                for counter in 0..<DataStore.shared.rooms.count {
                    let room = DataStore.shared.rooms[counter]
                    if SCNVector3EqualToVector3(room.node!.position, node.worldPosition) {
                        selectedRoom = room
                        selectedRoomIndex = counter
                        break
                    }
                }
                if selectedRoom != nil {
                    self.removeAllPlanes()
                    self.removeAllBungalo()
                    self.flowStatus = .seePatients
                    self.sceneView.delegate = self
                    DataStore.shared.selectedRoom = self.selectedRoom
                    return true
                }
            }
            print("Patient tapped")
        }
        return false
    }
    
    func removeNode(location: CGPoint) {
        
        let hitResults = sceneView.hitTest(location, options: nil)
        if hitResults.count > 0 {
            let result = hitResults[0]
            let node = result.node
            node.removeFromParentNode()
            print("Patient removed")
        }
    }
    
    func addPatient(hitResult: ARHitTestResult, selectedIndex: Int) {
        
        let positions = PatientHelper().getPositions(for: DataStore.shared.rooms[selectedIndex].patients.count, hitResult: hitResult)
        
        let numberOfCama: Float = Float(DataStore.shared.rooms[selectedIndex].patients.count)
        
        for i  in 0..<Int(numberOfCama) {
            let camaScene = SCNScene(named: "cama.scn")!
            
            let camaNode = camaScene.rootNode
            let depth: Float = camaNode.boundingBox.max.z - camaNode.boundingBox.min.z
            camaNode.position = positions[i]
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
    }
    
    func removeAllPlanes(){
        self.planes.forEach { (plane) in
            plane.removeFromParentNode()
        }
        self.sceneView.delegate = nil
    }
    
    func addbungalos(counter: Int, hitResult :ARHitTestResult){
       
        
        let positions = BungaloHelper().getPositions(for: counter)
        
        for index in 0..<counter {
            let camaScene = SCNScene(named: "cama.scn")!
            
            let camaNode = camaScene.rootNode
            let width: Float = camaNode.boundingBox.max.x - camaNode.boundingBox.min.x
            let depth: Float = camaNode.boundingBox.max.z - camaNode.boundingBox.min.z
            let xOffset: Float = Float((counter - counter - index)) * width
            camaNode.position = SCNVector3(hitResult.worldTransform.columns.3.x + xOffset,hitResult.worldTransform.columns.3.y, hitResult.worldTransform.columns.3.z)
            
            camaNode.scale = SCNVector3(x: 0.5, y: 0.5, z: 0.5)
            self.sceneView.scene.rootNode.addChildNode(camaNode)
            DataStore.shared.rooms[index].node = camaNode
        }
        
    }
    
    func removeAllBungalo(){
        DataStore.shared.rooms.forEach { (room) in
            room.node?.removeFromParentNode()
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

extension SCNVector3 {
    
    func convertPrimitive() -> (Float, Float, Float) {
        return (self.x, self.y, self.z)
    }
    
}
