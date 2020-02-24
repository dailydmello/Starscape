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
    var audioPlayer: AVAudioPlayer?
    var grids = [Grid]()
    var portalNode: SCNNode?
    
    //MARK: LifeCycle & Initialization
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        sceneView.debugOptions = [SCNDebugOptions.showFeaturePoints]
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration)
        sceneView.delegate = self
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
        sceneView.addGestureRecognizer(tapGestureRecognizer)
    }
            
    @objc func tapped(sender: UITapGestureRecognizer) {
        // Get 2D position of touch event on screen
        guard let sceneView = sender.view as? ARSCNView else {return}
        let touchLocation = sender.location(in: sceneView)
        
        // Translate those 2D points to 3D points using hitTest (existing plane)
        let hitTestResults = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
        
        
        if !hitTestResults.isEmpty {
            // Get hitTest results and ensure that the hitTest corresponds to a grid that has been placed on a wall
            guard let hitTest = hitTestResults.first, let anchor = hitTest.anchor as? ARPlaneAnchor, let _ = grids.index(where: { $0.anchor == anchor }) else {
                return
            }
            
            configuration.planeDetection = []
            sceneView.debugOptions = []
            sceneView.isUserInteractionEnabled = false
            sceneView.session.run(configuration)
            
            segmentedControl.isHidden = false
            
            //remove all grids
            _ = grids.map { $0.removeFromParentNode() }
            
            addPortal(hitTestResult: hitTest)
        } else {
            //do nothing
        }
    }
    
    //MARK: Setup View
    func setupView() {
        let normalTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        let selectedTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        segmentedControl.setTitleTextAttributes(normalTextAttributes, for: .normal)
        segmentedControl.setTitleTextAttributes(selectedTextAttributes, for: .selected)
    }
        
    //MARK: Start Music
    func startMusic() {
        let soundURL = Bundle.main.url(forResource: K.ambient, withExtension: K.mp3 )
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL!)
            audioPlayer?.numberOfLoops = -1
            audioPlayer?.play()
        }
        catch {
            print(error)
        }
    }
    
    //MARK: Portal Methods
    func addPortal(hitTestResult: ARHitTestResult) {
        let portalScene = SCNScene(named: K.portalPath)
        portalNode = portalScene!.rootNode.childNode(withName: K.portal, recursively: false)!
        let transform = hitTestResult.worldTransform
        let planeXposition = transform.columns.3.x
        let planeYposition = transform.columns.3.y
        let planeZposition = transform.columns.3.z
        portalNode?.position =  SCNVector3(planeXposition, planeYposition, planeZposition)
        
        if let portalNode = portalNode {
            sceneView.scene.rootNode.addChildNode(portalNode)
            startMusic()
            updateEarthRiseSmoothWallPaper()
        } else {
            return
        }
    }
    
    //MARK: ARSCNViewDelegate Methods
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        let grid = Grid(anchor: planeAnchor)
        grids.append(grid)
        node.addChildNode(grid)
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
            updateEarthRiseSmoothWallPaper()
        case 1:
            updateMilkyWayWallPaper()
        case 2:
            updateMoonPhasesWallPaper()
        default:
            break
        }
    }
    
    @IBAction func instructionsTapped(_ sender: Any) {
        audioPlayer?.stop()
        performSegue(withIdentifier: K.toOnboarding, sender: self)
    }
    
    //MARK: Update Environment
    func updateEarthRiseSmoothWallPaper() {
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
    
    func updateMoonPhasesWallPaper() {
        for node in PortalNodes.allCases {
            if node == .backA {
                updateMoonPhasesWallPaper(node: node, with: .moonPhasesBackA)
            } else if node == .backB {
                updateMoonPhasesWallPaper(node: node, with: .moonPhasesBackB)
            } else if node == .backC {
                updateMoonPhasesWallPaper(node: node, with: .moonPhasesBackC)
            } else if node == .bottom {
                updateMoonPhasesWallPaper(node: node, with: .moonPhasesBottom)
            } else if node == .front {
                updateMoonPhasesWallPaper(node: node, with: .moonPhasesFront)
            }  else if node == .left {
                updateMoonPhasesWallPaper(node: node, with: .moonPhasesLeft)
            } else if node == .right {
                updateMoonPhasesWallPaper(node: node, with: .moonPhasesRight)
            } else if node == .top {
                updateMoonPhasesWallPaper(node: node, with: .moonPhasesTop)
            }
        }
    }
    
    func updateEarthRiseSmoothWallPaper(node: PortalNodes, with wallPaperName: EarthRiseSmooth) {
        let child = portalNode?.childNode(withName: node.rawValue, recursively: true)
        child?.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "Portal.scnassets/\(wallPaperName.rawValue).png")
        child?.renderingOrder = 200
        if let mask = child?.childNode(withName: K.mask, recursively: false) {
            mask.geometry?.firstMaterial?.transparency = 0.000001
        }
    }
    
    func updateMilkyWayWallPaper(node: PortalNodes, with wallPaperName: MilkyWay) {
        let child = portalNode?.childNode(withName: node.rawValue, recursively: true)
        child?.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "Portal.scnassets/\(wallPaperName.rawValue).png")
        child?.renderingOrder = 200
        if let mask = child?.childNode(withName: K.mask, recursively: false) {
            mask.geometry?.firstMaterial?.transparency = 0.000001
        }
    }
    
    func updateMoonPhasesWallPaper(node: PortalNodes, with wallPaperName: MoonPhases) {
        let child = portalNode?.childNode(withName: node.rawValue, recursively: true)
        child?.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "Portal.scnassets/\(wallPaperName.rawValue).png")
        child?.renderingOrder = 200
        if let mask = child?.childNode(withName: K.mask, recursively: false) {
            mask.geometry?.firstMaterial?.transparency = 0.000001
        }
    }
}

//MARK: Environment Enums
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

enum MoonPhases: String, CaseIterable {
    case moonPhasesBackA
    case moonPhasesBackB
    case moonPhasesBackC
    case moonPhasesBottom
    case moonPhasesFront
    case moonPhasesLeft
    case moonPhasesRight
    case moonPhasesTop
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
