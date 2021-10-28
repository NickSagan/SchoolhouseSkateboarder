//
//  Skater.swift
//  SchoolhouseSkateboarder
//
//  Created by Nick Sagan on 27.10.2021.
//

import SpriteKit

class Skater: SKSpriteNode {
    
    var velocity = CGPoint.zero
    var mimimumY: CGFloat = 0.0
    var jumpSpeed: CGFloat = 20.0
    var isOnGround = true
    
    func setupPhysicsBody() {
        if let skaterTexture = texture {
            physicsBody = SKPhysicsBody(texture: skaterTexture, size: size)
            physicsBody?.isDynamic = true
            physicsBody?.density = 6.0
            //physicsBody?.allowsRotation = true
            physicsBody?.allowsRotation = false
            physicsBody?.angularDamping = 1.0
            physicsBody?.categoryBitMask = PhysicsCategory.skater
            // we want skater to contact with hbricks
            physicsBody?.collisionBitMask = PhysicsCategory.brick
            // we want to know when skater contact with brick or gem
            physicsBody?.contactTestBitMask = PhysicsCategory.brick | PhysicsCategory.gem
        }
    }
    
    func createSparks() {
        // find emitter file
        if let sparksPathUrl = Bundle.main.url(forResource: "sparks", withExtension: "sks") {
            do {
                let fileData = try Data(contentsOf: sparksPathUrl)
                // create emitter node
                let sparksNode = try NSKeyedUnarchiver.unarchivedObject(ofClass: SKEmitterNode.self, from: fileData)
                sparksNode!.position = CGPoint(x: 0.0, y: -50.0)
                addChild(sparksNode!)
                let waitAction = SKAction.wait(forDuration: 0.5)
                let removeAction = SKAction.removeFromParent()
                let waitThenRemove = SKAction.sequence([waitAction, removeAction])
                sparksNode?.run(waitThenRemove)
            } catch {
                print(error)
            }
        }
    }
    
}
