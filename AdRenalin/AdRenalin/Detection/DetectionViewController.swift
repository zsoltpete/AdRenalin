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
    
    @IBOutlet weak var selectedPatientLabel: UILabel!
    @IBOutlet weak var queueButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var sceneView: ARSCNView!
    
    let disposeBag = DisposeBag()
    
    var planes = [OverlayPlane]()
    var flowStatus = FlowStatus.detectPlaneForRooms
    
    var chooseTextNode : SCNNode?
    var selectedRoom: Room?
    var selectedRoomIndex: Int?
    var selectedPatient: Patient?
    var selectedPatientIndex: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getRooms()
        //self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints,ARSCNDebugOptions.showWorldOrigin]
        
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
        
        registerGestureRecognizers()
        DataStore.shared.selectedQueuePatient.subscribe(onNext: { patient in
            if patient == nil {
                self.selectedPatientLabel.alpha = 0.0
            } else {
                self.selectedPatientLabel.alpha = 1.0
                self.selectedPatientLabel.text = "SelectedQueuePatient.Prefix".localized + patient!.name
            }
        }).disposed(by: disposeBag)
        
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
    
    func getRooms(firstTime: Bool = true){
        DataProvider.shared.getRooms().subscribe(onNext: { [weak self]value in
            DataStore.shared.rooms = value
            if firstTime {
                let textPosition = Constants.Positions.DefaultText
                self!.chooseTextNode = self!.addText(text: "HelpText.PlaceRooms".localized, position: textPosition)
                self!.sceneView.scene.rootNode.addChildNode(self!.chooseTextNode!)
            }
        }).disposed(by: disposeBag)
    }
    
    func nodeIfPushed(location: CGPoint) {
        
        let hitResults = sceneView.hitTest(location, options: nil)
        if hitResults.count > 0 {
            let result = hitResults[0]
            let node = result.node
            if node.name!.contains("patient") {
                var counter = 0
                for counter in 0..<DataStore.shared.roomPatients.count {
                    let patient = DataStore.shared.roomPatients[counter]
                    if patient.node!.position.around(vector: node.worldPosition) {
                        selectedPatient = patient
                        selectedPatientIndex = counter
                        break
                    }
                }
                if selectedPatient != nil {
                    selectedPatient?.isShowing = !selectedPatient!.isShowing
                    self.animate(patient: selectedPatient!)
                    
                }
            } else if node.name!.contains("cama"), DataStore.shared.selectedQueuePatient.value != nil {
                
                for counter in 0..<DataStore.shared.roomPatients.count {
                    let patient = DataStore.shared.roomPatients[counter]
                    if patient.node == nil {
                        DataProvider.shared.removeQueue(id: DataStore.shared.selectedQueuePatient.value!.id, roomId: selectedRoomIndex!, patientIndex: counter)
                        let deadManNode = self.addPatientNode(camaNode: node)
                        self.sceneView.scene.rootNode.addChildNode(deadManNode)
                        DataStore.shared.roomPatients[counter] = DataStore.shared.selectedQueuePatient.value!
                        DataStore.shared.roomPatients[counter].node = deadManNode
                        DataStore.shared.selectedQueuePatient.accept(nil)
                        
                        break
                    }
                    
                }
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
        let selectedRoom = DataStore.shared.rooms[selectedIndex]
        let positions = PatientHelper().getPositions(for: selectedRoom.patients.count, hitResult: hitResult)
        
        let numberOfCama: Float = Float(selectedRoom.patients.count)
        for i  in 0..<Int(numberOfCama) {
            let camaScene = SCNScene(named: "cama.scn")!
            
            let camaNode = camaScene.rootNode
            let depth: Float = camaNode.boundingBox.max.z - camaNode.boundingBox.min.z
            camaNode.position = positions[i]
            camaNode.name = "cama\(i)"
            
            camaNode.scale = Constants.Scales.DefaultCama
            self.sceneView.scene.rootNode.addChildNode(camaNode)
            
            //Add Patient if able
            
            let patient = selectedRoom.patients[i]
            DataStore.shared.roomPatients.append(patient)
            if patient.id > 0 {
                let deadManNode = self.addPatientNode(camaNode: camaNode)
                self.sceneView.scene.rootNode.addChildNode(deadManNode)
                
                DataStore.shared.roomPatients[i].node = deadManNode
            }
            
            
        }
    }
    
    func addPatientNode(camaNode: SCNNode) -> SCNNode{
        let deadManScene = SCNScene(named: "dead_man.scn")!
        
        let deadManNode = deadManScene.rootNode
        deadManNode.scale = SCNVector3(x: 0.12, y: 0.12, z: 0.12)
        deadManNode.worldPosition = SCNVector3(camaNode.position.x, camaNode.position.y + 0.15, camaNode.position.z  + 0.04)
        
        
        
        return deadManNode
    }
    
    func removeAllPlanes(){
        self.planes.forEach { (plane) in
            plane.removeFromParentNode()
        }
        self.sceneView.delegate = nil
    }
    
    func addbungalos(counter: Int, hitResult :ARHitTestResult){
        
        let roomHelper = RoomHelper()
        
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
            
            //Add room texts
            let textPosition = roomHelper.getPostion(of: camaNode.position)
            let textNode = self.addText(text: DataStore.shared.rooms[index].name, position: textPosition)
            textNode.scale = Constants.Scales.RoomText
            textNode.rotation = SCNVector4(-textNode.rotation.x, textNode.rotation.y, textNode.rotation.z, textNode.rotation.w)
            self.sceneView.scene.rootNode.addChildNode(textNode)
            DataStore.shared.rooms[index].textNode = textNode
        }
        
    }
    
    func removeAllBungalo(){
        DataStore.shared.rooms.forEach { (room) in
            room.node?.removeFromParentNode()
            room.textNode?.removeFromParentNode()
        }
    }
    
    func addDescPatient(patient: Patient){
        let textPosition = PatientHelper().getDescPositions(patient: patient)
        let nameTextNode = self.addText(text: patient.name, position: textPosition.0)
        nameTextNode.scale = Constants.Scales.PatientNameText
        self.sceneView.scene.rootNode.addChildNode(nameTextNode)
        DataStore.shared.roomPatients[selectedPatientIndex!].textNodes.append(nameTextNode)
        
        let diagnosesTextNode = self.addText(text: patient.diagnosis, position: textPosition.1)
        diagnosesTextNode.scale = Constants.Scales.PatientDescText
        self.sceneView.scene.rootNode.addChildNode(diagnosesTextNode)
        DataStore.shared.roomPatients[selectedPatientIndex!].textNodes.append(diagnosesTextNode)
        
        let descTextNode = self.addText(text: patient.desc, position: textPosition.2)
        descTextNode.scale = Constants.Scales.PatientDescText
        self.sceneView.scene.rootNode.addChildNode(descTextNode)
        DataStore.shared.roomPatients[selectedPatientIndex!].textNodes.append(descTextNode)
    }
    
    func removeDescPatient(){
        DataStore.shared.roomPatients[selectedPatientIndex!].textNodes.forEach { (node) in
            node.removeFromParentNode()
        }
        DataStore.shared.roomPatients[selectedPatientIndex!].textNodes.removeAll()
    }
    
    func animate(patient: Patient) {
        if patient.isShowing {
            patient.node!.addShowMeAnimation()
            self.addDescPatient(patient: patient)
            self.leftButton.alpha = 1.0
            self.rightButton.alpha = 1.0
            self.rightButton.titleLabel?.text = "LeftButton.Delete.Title".localized
        } else {
            patient.node!.addNotShowMeAnimation()
            self.selectedPatient = nil
            self.removeDescPatient()
            self.leftButton.alpha = 0.0
            self.rightButton.alpha = 0.0
        }
    }
    
    @IBAction func queueButtonPsuhed(_ sender: Any) {
        self.performSegue(withIdentifier: Constants.Segues.ShowQueue, sender: nil)
    }
    
    @IBAction func leftButtonPsuhed(_ sender: Any) {
        
    }
    
    @IBAction func rightButtonPushed(_ sender: Any) {
        if self.flowStatus == .seePatients {
            guard let index = selectedRoomIndex else {
                return
            }
            DataProvider.shared.removePatient(roomId: index, id: selectedPatient!.id)
            self.selectedPatient?.node!.removeFromParentNode()
            self.removeDescPatient()
            self.selectedPatient = nil
            self.getRooms(firstTime: false)
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
    func addNotShowMeAnimation() {
        let rotateOne = SCNAction.rotateBy(x: CGFloat(Float.pi / -2.0), y: 0.0, z: 0, duration: 1.0)
        let hoverUp = SCNAction.moveBy(x: 0, y: -0.2, z: 0, duration: 1.0)
        let scaleUp  = SCNAction.scale(by: 1.0/2.0, duration: 1.0)
        let rotateAndHover = SCNAction.group([rotateOne, hoverUp, scaleUp])
        self.runAction(rotateAndHover)
    }
    
    func addShowMeAnimation() {
        let rotateOne = SCNAction.rotateBy(x: CGFloat(Float.pi / 2.0), y: 0.0, z: 0, duration: 1.0)
        let hoverUp = SCNAction.moveBy(x: 0, y: 0.2, z: 0, duration: 1.0)
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
