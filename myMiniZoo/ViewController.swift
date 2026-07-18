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
    var goat: Entity!
    var wolf: Entity!
    
    var didPlaceAnimals = false
    
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
            lioness.scale = [0.005,0.005,0.005]
            
            goat = try ModelEntity.load(named: "goat")
            print("goat loaded")
            goat.scale = [0.005,0.005,0.005]
            
            wolf = try ModelEntity.load(named: "wolf")
            print("wolf loaded")
            wolf.scale = [0.005,0.005,0.005]
                        
        } catch {
            fatalError("Failed to load assets: \(error)")
        }
    }
    
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        tryPlaceAnimals(with: anchors)
    }
    
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        tryPlaceAnimals(with: anchors)
    }
    
    func tryPlaceAnimals(with anchors: [ARAnchor]) {
        guard !didPlaceAnimals else { return }
        
        for anchor in anchors {
            guard let planeAnchor = anchor as? ARPlaneAnchor,
                  planeAnchor.alignment == .horizontal,
                  planeAnchor.classification == .floor
            else { continue }
            
            let width = planeAnchor.planeExtent.width
            let depth = planeAnchor.planeExtent.height
            
            let rectangleMesh = MeshResource.generatePlane(width: width, depth: depth)
            var material = SimpleMaterial()
            material.color = .init(tint: .green.withAlphaComponent(0.5))
            
            let rectangleEntity = ModelEntity(mesh: rectangleMesh, materials: [material])
            
            let realWorldAnchor = AnchorEntity(anchor: planeAnchor)
            realWorldAnchor.addChild(rectangleEntity)
            
            
            placeAnimal(lioness, at: [-0.5, 0, 1], on: rectangleEntity)
            placeAnimal(goat, at: [0, 0, 0], on: rectangleEntity)
            placeAnimal(wolf, at: [0.5, 0, -1], on: rectangleEntity)

            rectangleEntity.addChild(lioness)
            print("realWorldAnchor world position: \(realWorldAnchor.position(relativeTo: nil))")
            print("rectangleEntity world position: \(rectangleEntity.position(relativeTo: nil))")
            
            arView.scene.addAnchor(realWorldAnchor)
            didPlaceAnimals = true
            break
            
        }
    }
    
    func placeAnimal(_ animal: Entity, at offset: SIMD3<Float>, on parent: Entity) {
        let bounds = animal.visualBounds(relativeTo: parent)
        animal.position = [offset.x, offset.y, offset.z]
        parent.addChild(animal)
        
        print("")
        print("\(animal.name) world position: \(animal.position(relativeTo: nil))")
        print("\(animal.name) local position: \(animal.position)")
        print("\(animal.name) bounds: \(bounds)")
    }
    
    
    
    
}
