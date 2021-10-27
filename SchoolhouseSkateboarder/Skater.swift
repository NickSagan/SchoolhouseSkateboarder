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
            physicsBody?.allowsRotation = true
            physicsBody?.angularDamping = 1.0
            physicsBody?.categoryBitMask = PhysicsCategory.skater
            // we want skater to contact with hbricks
            physicsBody?.collisionBitMask = PhysicsCategory.brick
            // we want to know when skater contact with brick or gem
            physicsBody?.contactTestBitMask = PhysicsCategory.brick | PhysicsCategory.gem
        }
    }
    
}
