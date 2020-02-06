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
            
            segmentedControl.isHidden = false
            addPortal(hitTestResult: hitTestResult.first!)
//            let soundURL = Bundle.main.url(forResource: "starscape", withExtension: "mp4" )
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
            updateEarthRiseSmoothNode()
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
    
    @IBAction func indexChanged(_ sender: Any) {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            updateEarthRiseSmoothNode()
        case 1:
            updateMilkyWayWallPaper()
        case 2:
            updateGeneralStarsWallPaper()
        default:
            break
        }
    }
    
    //MARK: Update Environment
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
    
    func updateMilkyWayWallPaper() {
        for node in PortalNodes.allCases {
            if node == .backA {
                updateMilkyWayWallPaper(node: node, with: .milkyWayBackA)
            } else if node == .backB {
                updateMilkyWayWallPaper(node: node, with: .milkyWayBackB)
            } else if node == .backC {
                updateMilkyWayWallPaper(node: node, with: .milkyWayBackC)
            } else if node == .bottom {
                updateMilkyWayWallPaper(node: node, with: .milkyWayBottom)
            } else if node == .front {
                updateMilkyWayWallPaper(node: node, with: .milkyWayFront)
            }  else if node == .left {
                updateMilkyWayWallPaper(node: node, with: .milkyWayLeft)
            } else if node == .right {
                updateMilkyWayWallPaper(node: node, with: .milkyWayRight)
            } else if node == .top {
                updateMilkyWayWallPaper(node: node, with: .milkyWayTop)
            }
        }
    }
    
    func updateGeneralStarsWallPaper() {
        for node in PortalNodes.allCases {
            if node == .backA {
                updateGeneralStarsWallPaper(node: node, with: .generalStarsBackA)
            } else if node == .backB {
                updateGeneralStarsWallPaper(node: node, with: .generalStarsBackB)
            } else if node == .backC {
                updateGeneralStarsWallPaper(node: node, with: .generalStarsBackC)
            } else if node == .bottom {
                updateGeneralStarsWallPaper(node: node, with: .generalStarsBottom)
            } else if node == .front {
                updateGeneralStarsWallPaper(node: node, with: .generalStarsFront)
            }  else if node == .left {
                updateGeneralStarsWallPaper(node: node, with: .generalStarsLeft)
            } else if node == .right {
                updateGeneralStarsWallPaper(node: node, with: .generalStarsRight)
            } else if node == .top {
                updateGeneralStarsWallPaper(node: node, with: .generalStarsTop)
            }
        }
    }
    
    func updateEarthRiseSmoothWallPaper(node: PortalNodes, with wallPaperName: EarthRiseSmooth) {
        let child = portalNode?.childNode(withName: node.rawValue, recursively: true)
        child?.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "Portal.scnassets/\(wallPaperName.rawValue).png")
        child?.renderingOrder = 200
        if let mask = child?.childNode(withName: "mask", recursively: false) {
            mask.geometry?.firstMaterial?.transparency = 0.000001
        }
    }
    
    func updateMilkyWayWallPaper(node: PortalNodes, with wallPaperName: MilkyWay) {
        let child = portalNode?.childNode(withName: node.rawValue, recursively: true)
        child?.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "Portal.scnassets/\(wallPaperName.rawValue).png")
        child?.renderingOrder = 200
        if let mask = child?.childNode(withName: "mask", recursively: false) {
            mask.geometry?.firstMaterial?.transparency = 0.000001
        }
    }
    
    func updateGeneralStarsWallPaper(node: PortalNodes, with wallPaperName: GeneralStars) {
        let child = portalNode?.childNode(withName: node.rawValue, recursively: true)
        child?.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "Portal.scnassets/\(wallPaperName.rawValue).png")
        child?.renderingOrder = 200
        if let mask = child?.childNode(withName: "mask", recursively: false) {
            mask.geometry?.firstMaterial?.transparency = 0.000001
        }
    }
}

//MARK: Environment Enums
enum Theme {
    case milkyWay
    case earthRiseSmooth
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


