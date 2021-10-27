//
//  GameScene.swift
//  SchoolhouseSkateboarder
//
//  Created by Nick Sagan on 27.10.2021.
//

import SpriteKit
import GameplayKit

struct PhysicsCategory {
    
    // bit masks categorys for different physical bodies
    static let skater: UInt32 = 0x1 << 0
    static let brick: UInt32 = 0x1 << 1
    static let gem: UInt32 = 0x1 << 2
}

class GameScene: SKScene {
    
    // skater sprite
    let skater = Skater(imageNamed: "skater")
    // bricks array
    var bricks = [SKSpriteNode]()
    var brickSize = CGSize.zero
    // movement speed
    var scrollSpeed: CGFloat = 5.0
    let startingScrollSpeed = 5.0
    
    // how fast sprites will fall down
    let gravitySpeed: CGFloat = 1.5
    
    var lastUpdateTime: TimeInterval?
    
    override func didMove(to view: SKView) {
        // set gravity
        physicsWorld.gravity = CGVector(dx: 0.0, dy: -6.0)
        // default speed
        physicsWorld.speed = 1.0
        
        // Accept contactDelegate protocol
        physicsWorld.contactDelegate = self
        
        // left bottom corner: 0, 0
        anchorPoint = CGPoint.zero
        
        // Create background sprite
        let background = SKSpriteNode(imageNamed: "background")
        let xMid = frame.midX
        let yMid = frame.midY
        background.position = CGPoint(x: xMid, y: yMid)
        addChild(background)
        
        skater.setupPhysicsBody()
        addChild(skater)
        
        // add gesture recognizer
        let tapMethod = #selector(GameScene.handleTap(tapGesture:))
        let tapGesture = UITapGestureRecognizer(target: self, action: tapMethod)
        view.addGestureRecognizer(tapGesture)
        
        startGame()
        }
    
    func resetSkater() {
        //skater init position
        let skaterX = frame.midX / 2.0
        let skaterY = skater.frame.height / 2.0 + 64
        skater.position = CGPoint(x: skaterX, y: skaterY)
        skater.zPosition = 10
        skater.mimimumY = skaterY
        
        skater.zRotation = 0.0
        skater.physicsBody?.velocity = CGVector(dx: 0.0, dy: 0.0)
        skater.physicsBody?.angularVelocity = 0.0
        
//        let ballbody = SKPhysicsBody(circleOfRadius: 30.0)
//        let boxBody = SKPhysicsBody(rectangleOf: box.size)
//        let textureBody = SKPhysicsBody(texture: skaterTexture, size: skater.size)
    }
    
    func startGame() {
        resetSkater()
        scrollSpeed = startingScrollSpeed
        lastUpdateTime = nil
        
        for brick in bricks {
            brick.removeFromParent()
        }
        bricks.removeAll(keepingCapacity: true)
    }
    
    func gameOver() {
        startGame()
    }
    
    func spawnBrick(atPosition position: CGPoint) -> SKSpriteNode {
        // create brick sprite
        let brick = SKSpriteNode(imageNamed: "sidewalk")
        brick.position = position
        brick.zPosition = 8
        // add brick to scene
        addChild(brick)
        
        // update brickSize with a real size of sidewalk.png
        brickSize = brick.size
        bricks.append(brick)
        
        // setup physics body
        let center = brick.centerRect.origin
        brick.physicsBody = SKPhysicsBody(rectangleOf: brick.size, center: center)
        brick.physicsBody?.affectedByGravity = false
        brick.physicsBody?.categoryBitMask = PhysicsCategory.brick
        brick.physicsBody?.collisionBitMask = 0
        
        return brick
    }
    
    func updateBricks(withScrollAmount currentScrollAmount: CGFloat) {
        var farthestRightBrickX: CGFloat = 0.0
        
        for brick in bricks {
            let newX = brick.position.x - currentScrollAmount
            
            // if brick scrolled through the left side of our screen
            if newX < -brickSize.width {
                brick.removeFromParent()
                
                if let brickIndex = bricks.firstIndex(of: brick) {
                    bricks.remove(at: brickIndex)
                }
            } else {
                // if brick is still on the screen: update his X
                brick.position = CGPoint(x: newX, y: brick.position.y)
                
                // update fartherest right brick X position
                if brick.position.x > farthestRightBrickX {
                    farthestRightBrickX = brick.position.x
                }
            }
        }
        
        while farthestRightBrickX < frame.width {
            var brickX = farthestRightBrickX + brickSize.width + 1
            let brickY = brickSize.height / 2
            
            let randomNumber = arc4random_uniform(99)
            
            if randomNumber < 5 {
                let gap = 20.0 * scrollSpeed
                brickX += gap
            }
            
            let newBrick = spawnBrick(atPosition: CGPoint(x: brickX, y: brickY))
            farthestRightBrickX = newBrick.position.x
        }
        
    }
    
    func updateSkater() {
        if !skater.isOnGround {
            let velocityY = skater.velocity.y - gravitySpeed
            skater.velocity = CGPoint(x: skater.velocity.x, y: velocityY)
            
            let newSkaterY: CGFloat = skater.position.y + skater.velocity.y
            skater.position = CGPoint(x: skater.position.x, y: newSkaterY)
            
            if skater.position.y < skater.mimimumY {
                skater.position.y = skater.mimimumY
                skater.velocity = CGPoint.zero
                skater.isOnGround = true
            }
        }
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        var elapsedTime: TimeInterval = 0.0
        if let lastTimeStamp = lastUpdateTime {
            elapsedTime = currentTime - lastTimeStamp
        }
        lastUpdateTime = currentTime
        
        let expectedElapsedTime: TimeInterval = 1.0 / 60.0
        let scrollAdjustment = CGFloat(elapsedTime / expectedElapsedTime)
        let currentScrollAmount = scrollSpeed * scrollAdjustment
        
        updateBricks(withScrollAmount: currentScrollAmount)
        updateSkater()
    }
    
    @objc func handleTap(tapGesture: UITapGestureRecognizer) {
        if skater.isOnGround {
            // set skater.y velocity
            skater.physicsBody?.applyImpulse(CGVector(dx: 0.0, dy: 260.0))
        }
    }
    
}

//MARK: - SKPhysicsContactDelegate

extension GameScene: SKPhysicsContactDelegate {
    
    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.categoryBitMask == PhysicsCategory.skater && contact.bodyB.categoryBitMask == PhysicsCategory.brick {
            skater.isOnGround = true
        }
    }
    
}
