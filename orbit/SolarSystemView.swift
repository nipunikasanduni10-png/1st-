//
//  SolarSystemView.swift
//  orbit
//
//  Created by weerapurage nipunika sanduni fernando on 20/10/2026.
//

import Foundation
import SwiftUI
import SceneKit
import UIKit

// MARK: - Planet Information

struct PlanetInfo {
    let name: String
    let description: String
}

struct PlanetSpec {
    let name: String
    let radius: CGFloat
    let orbit: CGFloat
    let color: UIColor
    let orbitSeconds: TimeInterval
    let description: String
}

// MARK: - SwiftUI Screen

struct SolarSystemView: View {
    @State private var selected: PlanetInfo?
    @State private var isPaused = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            SolarSceneView(
                isPaused: isPaused,
                selected: $selected
            )
            .ignoresSafeArea()

            VStack {
                HStack {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("ORBITA")
                            .font(.caption.bold())
                            .tracking(4)
                            .foregroundStyle(.cyan)

                        Text("Solar System")
                            .font(.title.bold())
                            .foregroundStyle(.white)
                    }

                    Spacer()

                    Button {
                        isPaused.toggle()
                    } label: {
                        Image(systemName:
                            isPaused ? "play.fill" : "pause.fill"
                        )
                        .font(.system(size: 18))
                        .foregroundStyle(.white)
                        .frame(width: 48, height: 48)
                        .background(.white.opacity(0.14))
                        .clipShape(Circle())
                    }
                }

                Spacer()

                if let planet = selected {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text(planet.name)
                                .font(.title2.bold())

                            Spacer()

                            Button {
                                selected = nil
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.title2)
                            }
                        }

                        Text(planet.description)
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.75))
                    }
                    .foregroundStyle(.white)
                    .padding(20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                } else {
                    VStack(spacing: 8) {
                        Text("EXPLORE THE UNIVERSE")
                            .font(.caption.bold())
                            .tracking(2)

                        Text("Drag to rotate • Pinch to zoom")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.7))

                        Text("Tap a planet to discover more")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.55))
                    }
                    .foregroundStyle(.white)
                }
            }
            .padding(24)
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - 3D Scene

struct SolarSceneView: UIViewRepresentable {
    let isPaused: Bool
    @Binding var selected: PlanetInfo?
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> SCNView {
        let view = SCNView(frame: .zero)
        
        view.scene = createScene()
        view.backgroundColor = .black
        view.allowsCameraControl = true
        view.autoenablesDefaultLighting = false
        view.antialiasingMode = .multisampling4X
        view.isPlaying = true
        
        let tap = UITapGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handleTap(_:))
        )
        view.addGestureRecognizer(tap)
        
        return view
    }
    
    func updateUIView(_ view: SCNView, context: Context) {
        context.coordinator.parent = self
        view.scene?.rootNode.isPaused = isPaused
    }
    
    class Coordinator: NSObject {
        var parent: SolarSceneView
        
        init(_ parent: SolarSceneView) {
            self.parent = parent
        }
        
        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            guard let view = gesture.view as? SCNView else {
                return
            }
            
            let point = gesture.location(in: view)
            let hits = view.hitTest(point, options: nil)
            
            for hit in hits {
                var node: SCNNode? = hit.node
                
                while let current = node {
                    if let name = current.name,
                       name.hasPrefix("planet_") {
                        let planetName = String(name.dropFirst(7))
                        
                        parent.selected = PlanetInfo(
                            name: planetName,
                            description: descriptions[planetName]
                            ?? "Explore this celestial body."
                        )
                        return
                    }
                    
                    node = current.parent
                }
            }
        }
    }
    
    // MARK: - Planet Descriptions
    
    static let descriptions: [String: String] = [
        "Sun": "The star at the center of our Solar System.",
        "Mercury": "The smallest planet, closest to the Sun.",
        "Venus": "The hottest planet, with a thick atmosphere.",
        "Earth": "Our home, with oceans and abundant life.",
        "Mars": "The Red Planet, with giant volcanoes.",
        "Jupiter": "The largest planet, a gas giant with huge storms.",
        "Saturn": "A gas giant famous for its magnificent rings.",
        "Uranus": "An ice giant that rotates on its side.",
        "Neptune": "A distant blue ice giant with powerful winds."
    ]
    
    private var descriptions: [String: String] {
        Self.descriptions
    }
    
    // MARK: - Build Solar System
    
    private func createScene() -> SCNScene {
        let scene = SCNScene()
        scene.background.contents = UIImage(named : "stars") ?? UIColor.black
        
        addCamera(to: scene)
        addLighting(to: scene)
        addStars(to: scene)
        addSun(to: scene)
        
        let planets: [PlanetSpec] = [
            .init(
                name: "Mercury",
                radius: 0.10,
                orbit: 1.4,
                color: .gray,
                orbitSeconds: 12,
                description: ""
            ),
            .init(
                name: "Venus",
                radius: 0.17,
                orbit: 2.0,
                color: .systemOrange,
                orbitSeconds: 19,
                description: ""
            ),
            .init(
                name: "Earth",
                radius: 0.28,
                orbit: 2.7,
                color: .systemBlue,
                orbitSeconds: 26,
                description: ""
            ),
            .init(
                name: "Mars",
                radius: 0.14,
                orbit: 3.4,
                color: .systemRed,
                orbitSeconds: 35,
                description: ""
            ),
            .init(
                name: "Jupiter",
                radius: 0.43,
                orbit: 4.7,
                color: .brown,
                orbitSeconds: 55,
                description: ""
            ),
            .init(
                name: "Saturn",
                radius: 0.36,
                orbit: 6.1,
                color: .systemYellow,
                orbitSeconds: 75,
                description: ""
            ),
            .init(
                name: "Uranus",
                radius: 0.27,
                orbit: 7.5,
                color: .cyan,
                orbitSeconds: 95,
                description: ""
            ),
            .init(
                name: "Neptune",
                radius: 0.26,
                orbit: 8.9,
                color: .blue,
                orbitSeconds: 115,
                description: ""
            )
        ]
        
        for planet in planets {
            addPlanet(planet, to: scene)
        }
        
        return scene
    }
    
    // MARK: - Camera
    
    private func addCamera(to scene: SCNScene) {
        let camera = SCNCamera()
        camera.fieldOfView = 65
        camera.zNear = 0.01
        camera.zFar = 1000
        
        let cameraNode = SCNNode()
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(0, 14, 26)
        cameraNode.look(at: SCNVector3Zero)
        
        scene.rootNode.addChildNode(cameraNode)
    }
    
    // MARK: - Lighting
    
    private func addLighting(to scene: SCNScene) {
        let sunlight = SCNLight()
        sunlight.type = .omni
        sunlight.intensity = 1800
        sunlight.attenuationEndDistance = 45
        
        let sunLightNode = SCNNode()
        sunLightNode.light = sunlight
        scene.rootNode.addChildNode(sunLightNode)
        
        let ambient = SCNLight()
        ambient.type = .ambient
        ambient.intensity = 80
        ambient.color = UIColor.white
        
        let ambientNode = SCNNode()
        ambientNode.light = ambient
        scene.rootNode.addChildNode(ambientNode)
    }
    
    // MARK: - Sun
    
    private func addSun(to scene: SCNScene) {
        let sphere = SCNSphere(radius: 0.6)
        sphere.segmentCount = 64
        
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named: "Sun" ) ?? UIColor.orange
        material.emission.contents = UIImage(named: "Sun" ) ?? UIColor.orange
        
        material.lightingModel = .constant
        sphere.materials = [material]
        
        let sun = SCNNode(geometry: sphere)
        sun.name = "planet_Sun"
        scene.rootNode.addChildNode(sun)
    }
    
    // MARK: - Planets
    
    private func addPlanet(
        _ planet: PlanetSpec,
        to scene: SCNScene
    ) {
        // Orbit pivot
        let pivot = SCNNode()
        scene.rootNode.addChildNode(pivot)
        
        // Create planet sphere
        let sphere = SCNSphere(radius: planet.radius)
        sphere.segmentCount = 64
        
        // Planet material
        let material = SCNMaterial()
        material.lightingModel = .physicallyBased
        
        if let texture = UIImage(named: planet.name.lowercased()) {
            material.diffuse.contents = texture
        } else {
            material.diffuse.contents = planet.color
        }
        
        material.roughness.contents = 1.0
        material.metalness.contents = 0.0
        material.specular.contents = UIColor.black
        material.emission.contents = UIColor.black
        
        sphere.materials = [material]
        
        
        
        let node = SCNNode(geometry: sphere)
        node.name = "planet_\(planet.name)"
        node.position = SCNVector3(
            Float(planet.orbit), 0, 0
        )
        
        pivot.addChildNode(node)
        
        // Planet spins on its own axis
        let spin = SCNAction.rotateBy(
            x: 0,
            y: CGFloat.pi * 2,
            z: 0,
            duration: 8
        )
        
        node.runAction(.repeatForever(spin))
        
        // Planet orbits the Sun
        let orbit = SCNAction.rotateBy(
            x: 0,
            y: CGFloat.pi * 2,
            z: 0,
            duration: planet.orbitSeconds
        )
        
        orbit.timingMode = .linear
        pivot.runAction(.repeatForever(orbit))
        
        // Visible orbital track
        let track = SCNTorus(
            ringRadius: planet.orbit,
            pipeRadius: 0.008
        )
        
        let trackMaterial = SCNMaterial()
        trackMaterial.diffuse.contents =
        UIColor.white.withAlphaComponent(0.15)
        trackMaterial.lightingModel = .constant
        track.materials = [trackMaterial]
        
        let trackNode = SCNNode(geometry: track)
        scene.rootNode.addChildNode(trackNode)
        
        // Saturn's rings
        if planet.name == "Saturn" {
            let rings = SCNTorus(
                ringRadius: 0.56,
                pipeRadius: 0.11
            )
            
            let ringMaterial = SCNMaterial()
            ringMaterial.diffuse.contents =
            UIColor(
                red: 0.78,
                green: 0.69,
                blue: 0.52,
                alpha: 1
            )
            ringMaterial.lightingModel = .physicallyBased
            rings.materials = [ringMaterial]
            
            let ringNode = SCNNode(geometry: rings)
            ringNode.eulerAngles.z = 0.35
            node.addChildNode(ringNode)
        }
    }
    
    // MARK: - Background Stars
    
    private func addStars(to scene: SCNScene) {
        let geometry = SCNSphere(radius: 0.025)
        geometry.segmentCount = 4
        
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.white
        material.lightingModel = .constant
        geometry.materials = [material]
        
        for i in 0..<350 {
            // Deterministic distribution
            let a = Float(i) * 2.399963
            let y = 1 - 2 * (Float(i) + 0.5) / 350
            let r = sqrt(max(0, 1 - y * y))
            let distance: Float = 70
            
            let star = SCNNode(geometry: geometry)
            star.position = SCNVector3(
                cos(a) * r * distance,
                y * distance,
                sin(a) * r * distance
            )
            
            scene.rootNode.addChildNode(star)
        }
    }
}
