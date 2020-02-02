//
//  ViewController.swift
//  AR-Portal
//
//  Created by Ethan D'Mello on 2017-08-31.
//  Copyright © 2017 Ethan D'Mello. All rights reserved.
//

import UIKit
import ARKit
import AVFoundation

class ViewController: UIViewController, ARSCNViewDelegate, AVAudioPlayerDelegate {
    
    //MARK: Properties
    @IBOutlet weak var planeDetected: UILabel!
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    let configuration = ARWorldTrackingConfiguration()
    var audioPlayer: AVAudioPlayer!
    var grids = [Grid]()
    var portalNode: SCNNode?
    
    //MARK: LifeCycle
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
            configuration.planeDetection = []
            sceneView.debugOptions = []
            sceneView.session.run(configuration)
            
            //TODO: Unhide segmented control
            addPortal(hitTestResult: hitTestResult.first!)
            //            let soundURL = Bundle.main.url(forResource: "cranes", withExtension: "mp3" )
            //            do{
            //                audioPlayer = try AVAudioPlayer(contentsOf: soundURL!)
            //            }
            //            catch{
            //                print(error)
            //            }
            //            audioPlayer.play()
        } else {
            ////
        }
        
    }
    
    func addPortal(hitTestResult: ARHitTestResult) {
        let portalScene = SCNScene(named: "Portal.scnassets/Portal.scn")
        portalNode = portalScene!.rootNode.childNode(withName: "Portal", recursively: false)!
        let transform = hitTestResult.worldTransform
        let planeXposition = transform.columns.3.x
        let planeYposition = transform.columns.3.y
        let planeZposition = transform.columns.3.z
        portalNode?.position =  SCNVector3(planeXposition, planeYposition, planeZposition)
        
        if let portalNode = portalNode {
            self.sceneView.scene.rootNode.addChildNode(portalNode)
            
            self.addPlane(nodeName: "bottom", portalNode: portalNode, imageName: "earthRiseSmoothBottom")
            self.addPlane(nodeName: "top", portalNode: portalNode, imageName: "earthRiseSmoothTop")
            self.addWalls(nodeName: "left", portalNode: portalNode, imageName: "earthRiseSmoothLeft")
            self.addWalls(nodeName: "front", portalNode: portalNode, imageName: "earthRiseSmoothFront")
            self.addWalls(nodeName: "right", portalNode: portalNode, imageName: "earthRiseSmoothRight")
            self.addWalls(nodeName: "backA", portalNode: portalNode, imageName: "earthRiseSmoothBackA")
            self.addWalls(nodeName: "backB", portalNode: portalNode, imageName: "earthRiseSmoothBackB")
            self.addWalls(nodeName: "backC", portalNode: portalNode, imageName: "earthRiseSmoothBackC")
            
            //            self.addPlane(nodeName: "bottom", portalNode: portalNode, imageName: "MilkyWayBottom")
            //            self.addPlane(nodeName: "top", portalNode: portalNode, imageName: "MilkyWayTop")
            //
            //
            //            self.addWalls(nodeName: "left", portalNode: portalNode, imageName: "MilkyWayLeft")
            //            self.addWalls(nodeName: "front", portalNode: portalNode, imageName: "MilkyWayFront")
            //            self.addWalls(nodeName: "right", portalNode: portalNode, imageName: "MilkyWayRight")
            //            self.addWalls(nodeName: "backA", portalNode: portalNode, imageName: "MilkyWayBackA")
            //            self.addWalls(nodeName: "backB", portalNode: portalNode, imageName: "MilkyWayBackB")
            //            self.addWalls(nodeName: "backC", portalNode: portalNode, imageName: "MilkyWayBackC")
            
//            self.addPlane(nodeName: "bottom", portalNode: portalNode, imageName: "lego")
//            self.addPlane(nodeName: "top", portalNode: portalNode, imageName: "lego")
//
//
//            self.addWalls(nodeName: "left", portalNode: portalNode, imageName: "lego")
//            self.addWalls(nodeName: "front", portalNode: portalNode, imageName: "lego")
//            self.addWalls(nodeName: "right", portalNode: portalNode, imageName: "lego")
//            self.addWalls(nodeName: "backA", portalNode: portalNode, imageName: "lego")
//            self.addWalls(nodeName: "backB", portalNode: portalNode, imageName: "lego")
//            self.addWalls(nodeName: "backC", portalNode: portalNode, imageName: "lego")
        } else {
            return
        }
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
    
    func updateEarthRiseSmoothNode() {
        for node in PortalNodes.allCases {
            if node == .backA {
                updateEarthRiseSmoothWallPaper(node: node, with: .earthRiseSmoothBackA)
            } else if node == .backB {
                updateEarthRiseSmoothWallPaper(node: node, with: .earthRiseSmoothBackB)
            } else if node == .backC {
                updateEarthRiseSmoothWallPaper(node: node, with: .earthRiseSmoothBackC)
            } else if node == .bottom {
                updateEarthRiseSmoothWallPaper(node: node, with: .earthRiseSmoothBottom)
            } else if node == .front {
                updateEarthRiseSmoothWallPaper(node: node, with: .earthRiseSmoothFront)
            }  else if node == .left {
                updateEarthRiseSmoothWallPaper(node: node, with: .earthRiseSmoothLeft)
            } else if node == .right {
                updateEarthRiseSmoothWallPaper(node: node, with: .earthRiseSmoothRight)
            } else if node == .top {
                updateEarthRiseSmoothWallPaper(node: node, with: .earthRiseSmoothTop)
            }
        }
    }
    
    func updateEarthRiseSmoothWallPaper(node: PortalNodes, with wallPaperName: EarthRiseSmooth) {
        let child = portalNode?.childNode(withName: node.rawValue, recursively: true)
//        child?.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "Portal.scnassets/\(wallPaperName.rawValue).png")
        child?.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "Portal.scnassets/\(wallPaperName.rawValue).png")
        child?.renderingOrder = 200
    }
    
//    func updateWorld(theme: Theme) {
//        switch theme {
//        case .earthRiseRocky:
//            for node in PortalNodes.allCases {
//                updateEarthRiseRockyNode(node: node)
//            }
//        case .earthRiseSmooth:
//            for node in PortalNodes.allCases {
//                let child = portalNode?.childNode(withName: node.rawValue, recursively: true)
//                child?.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "Portal.scnassets/lego.png")
//                child?.renderingOrder = 200
//            }
//        case .generalStars:
//            for node in PortalNodes.allCases {
//                let child = portalNode?.childNode(withName: node.rawValue, recursively: true)
//                child?.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "Portal.scnassets/lego.png")
//                child?.renderingOrder = 200
//            }
//        case .milkyWay:
//            for node in PortalNodes.allCases {
//                let child = portalNode?.childNode(withName: node.rawValue, recursively: true)
//                child?.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "Portal.scnassets/lego.png")
//                child?.renderingOrder = 200
//            }
//        }
//    }
    
    @IBAction func indexChanged(_ sender: Any) {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            updateEarthRiseSmoothNode()
        case 1:
            updateEarthRiseSmoothNode()
        default:
            break
        }
    }
}

enum Theme {
    case milkyWay
    case earthRiseSmooth
    case earthRiseRocky
    case generalStars
}

enum MilkyWay: String, CaseIterable {
    case milkyWayBackA
    case milkyWayBackB
    case milkyWayBackC
    case milkyWayBottom
    case milkyWayFront
    case milkyWayLeft
    case milkyWayRight
    case milkyWayTop
}

enum EarthRiseSmooth: String, CaseIterable {
    case earthRiseSmoothBackA
    case earthRiseSmoothBackB
    case earthRiseSmoothBackC
    case earthRiseSmoothBottom
    case earthRiseSmoothFront
    case earthRiseSmoothLeft
    case earthRiseSmoothRight
    case earthRiseSmoothTop
}

enum EarthRiseRocky: String, CaseIterable {
    case earthRiseRockyBackA
    case earthRiseRockyBackB
    case earthRiseRockyBackC
    case earthRiseRockyBottom
    case earthRiseRockyFront
    case earthRiseRockyLeft
    case earthRiseRockyRight
    case earthRiseRockyTop
    case lego
}

enum GeneralStars: String, CaseIterable {
    case generalStarsBackA
    case generalStarsBackB
    case generalStarsBackC
    case generalStarsBottom
    case generalStarsFront
    case generalStarsLeft
    case generalStarsRight
    case generalStarsTop
}

enum PortalNodes: String, CaseIterable {
    case top
    case front
    case bottom
    case left
    case right
    case backA
    case backB
    case backC
}


