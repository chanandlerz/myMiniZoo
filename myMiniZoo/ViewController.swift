//
//  ViewController.swift
//  myMiniZoo
//
//  Created by Nadia Putri Natali Lubis on 18/07/26.
//

import Foundation
import RealityKit
import ARKit

class ViewController: UIViewController, ARSessionDelegate {
    
    var arView: ARView!
    var lioness: Entity!
    var didPlaceLioness = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        arView = ARView(frame: .zero)
        arView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(arView)
        arView.debugOptions.insert(.showSceneUnderstanding)
        arView.session.delegate = self
        
        NSLayoutConstraint.activate([
            arView.topAnchor.constraint(equalTo: view.topAnchor),
            arView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            arView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            arView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal]
        arView.session.run(configuration)
        
        do {
            lioness = try ModelEntity.load(named: "lioness")
            print("lioness loaded")
            
            lioness.scale = [0.01,0.01,0.01]
                        
        } catch {
            fatalError("Failed to load assets: \(error)")
        }
    }
    
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        tryPlaceLioness(with: anchors)
    }
    
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        tryPlaceLioness(with: anchors)
    }
    
    func tryPlaceLioness(with anchors: [ARAnchor]) {
        guard !didPlaceLioness else { return }
        
        for anchor in anchors {
            guard let planeAnchor = anchor as? ARPlaneAnchor,
                  planeAnchor.alignment == .horizontal,
                  planeAnchor.classification == .floor
            else { continue }
            
            let width = planeAnchor.planeExtent.width
            let depth = planeAnchor.planeExtent.height
            
            let rectangleMesh = MeshResource.generatePlane(width: width, depth: depth)
            var material = SimpleMaterial()
            material.color = .init(tint: .systemIndigo.withAlphaComponent(0.5))
            
            let rectangleEntity = ModelEntity(mesh: rectangleMesh, materials: [material])
            
            let realWorldAnchor = AnchorEntity(anchor: planeAnchor)
            realWorldAnchor.addChild(rectangleEntity)
            
            let bounds = lioness.visualBounds(relativeTo: nil)
            print("min.y: \(bounds.min.y), max.y: \(bounds.max.y)")
            lioness.position = [0, 0, 0]
//            lioness.position = [0,0,0]
            rectangleEntity.addChild(lioness)
            print("realWorldAnchor world position: \(realWorldAnchor.position(relativeTo: nil))")
            print("rectangleEntity world position: \(rectangleEntity.position(relativeTo: nil))")
            print("lioness world position: \(lioness.position(relativeTo: nil))")
            print("lioness local position: \(lioness.position)")
            
            arView.scene.addAnchor(realWorldAnchor)
            didPlaceLioness = true
            break
            
        }
    }
    
    
    
    
}
