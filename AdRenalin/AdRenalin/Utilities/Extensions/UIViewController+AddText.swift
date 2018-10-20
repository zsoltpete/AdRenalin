//
//  UIViewController+AddText.swift
//  AdRenalin
//
//  Created by Zsolt Pete on 2018. 10. 20..
//  Copyright © 2018. Zsolt Pete. All rights reserved.
//

import Foundation
import SceneKit
import UIKit
import ARKit

extension UIViewController {
    
    func addText(text: String, position: SCNVector3) -> SCNNode{
        let textGeometry = SCNText(string: text, extrusionDepth: 1.0)
        textGeometry.firstMaterial?.diffuse.contents = UIColor.white
        
        let textNode = SCNNode(geometry: textGeometry)
        textNode.scale = Constants.Scales.DefaultTextScale
        textNode.position = position
        return textNode
    }
    
}
