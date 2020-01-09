//
//  ViewController.swift
//  AR-Portal
//
//  Created by Rayan Slim on 2017-08-31.
//  Copyright © 2017 Rayan Slim. All rights reserved.
//

import UIKit
import ARKit
import AVFoundation

class ViewController: UIViewController, ARSCNViewDelegate, AVAudioPlayerDelegate {

    @IBOutlet weak var planeDetected: UILabel!
    @IBOutlet weak var sceneView: ARSCNView!
    let configuration = ARWorldTrackingConfiguration()
    var audioPlayer: AVAudioPlayer!
    var grids = [Grid]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sceneView.debugOptions = [SCNDebugOptions.showWorldOrigin, SCNDebugOptions.showFeaturePoints]
        self.configuration.planeDetection = .horizontal
        self.sceneView.session.run(configuration)
        self.sceneView.delegate = self
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.sceneView.addGestureRecognizer(tapGestureRecognizer)
    }
  
    @objc func handleTap(sender: UITapGestureRecognizer) {
        guard let sceneView = sender.view as? ARSCNView else {return}
        let touchLocation = sender.location(in: sceneView)
        let hitTestResult = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
        if !hitTestResult.isEmpty {
            self.configuration.planeDetection = []
            self.sceneView.debugOptions = []
            self.sceneView.session.run(configuration)

            self.addPortal(hitTestResult: hitTestResult.first!)
            let soundURL = Bundle.main.url(forResource: "cranes", withExtension: "mp3" )
            do{
                audioPlayer = try AVAudioPlayer(contentsOf: soundURL!)
            }
            catch{
                print(error)
            }
            audioPlayer.play()
        } else {
            ////
        }
        
    }
    
    func addPortal(hitTestResult: ARHitTestResult) {
        let portalScene = SCNScene(named: "Portal.scnassets/Portal.scn")
        let portalNode = portalScene!.rootNode.childNode(withName: "Portal", recursively: false)!
        let transform = hitTestResult.worldTransform
        let planeXposition = transform.columns.3.x
        let planeYposition = transform.columns.3.y
        let planeZposition = transform.columns.3.z
        portalNode.position =  SCNVector3(planeXposition, planeYposition, planeZposition)
        self.sceneView.scene.rootNode.addChildNode(portalNode)
        self.addPlane(nodeName: "roof", portalNode: portalNode, imageName: "realSky")
        self.addPlane(nodeName: "floor", portalNode: portalNode, imageName: "flower")
        self.addWalls(nodeName: "backWall", portalNode: portalNode, imageName: "grad")
        self.addWalls(nodeName: "sideWallA", portalNode: portalNode, imageName: "rightSide")
        self.addWalls(nodeName: "sideWallB", portalNode: portalNode, imageName: "leftSide")
        self.addWalls(nodeName: "sideDoorA", portalNode: portalNode, imageName: "farmDork")
        self.addWalls(nodeName: "sideDoorB", portalNode: portalNode, imageName: "rainDork")
        self.addWalls(nodeName: "headBoard", portalNode: portalNode, imageName: "title")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
//        guard anchor is ARPlaneAnchor else {return}
//        let grid = Grid(anchor: anchor as! ARPlaneAnchor)
//        self.grids.append(grid)
//        DispatchQueue.main.async {
//            //self.planeDetected.isHidden = false
//            node.addChildNode(grid)
//        }
//        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
//            //self.planeDetected.isHidden = true
//            node.removeFromParentNode()
//        }
        
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        let grid = Grid(anchor: planeAnchor)
        self.grids.append(grid)
        node.addChildNode(grid)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            node.removeFromParentNode()
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        let grid = self.grids.filter { grid in
            return grid.anchor.identifier == planeAnchor.identifier
            }.first
        
        guard let foundGrid = grid else {
            return
        }
        
        foundGrid.update(anchor: planeAnchor)
    }
    
    
    func addWalls(nodeName: String, portalNode: SCNNode, imageName: String) {
        let child = portalNode.childNode(withName: nodeName, recursively: true)
        child?.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "Portal.scnassets/\(imageName).png")
        child?.renderingOrder = 200
        if let mask = child?.childNode(withName: "mask", recursively: false) {
            mask.geometry?.firstMaterial?.transparency = 0.000001
        }
    }

    
    func addPlane(nodeName: String, portalNode: SCNNode, imageName: String) {
        let child = portalNode.childNode(withName: nodeName, recursively: true)
        child?.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "Portal.scnassets/\(imageName).png")
        child?.renderingOrder = 200
    }
    
}

