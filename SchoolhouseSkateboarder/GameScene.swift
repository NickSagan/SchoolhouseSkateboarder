//
//  GameScene.swift
//  SchoolhouseSkateboarder
//
//  Created by Nick Sagan on 27.10.2021.
//

import SpriteKit
import GameplayKit

struct PhysicsCategory {
    // bit masks categories for different physical bodies
    static let skater: UInt32 = 0x1 << 0
    static let brick: UInt32 = 0x1 << 1
    static let gem: UInt32 = 0x1 << 2
}

enum BrickLevel: CGFloat {
    case low = 0.0
    case high = 100.0
}

class GameScene: SKScene {
    
    // skater sprite
    let skater = Skater(imageNamed: "skater")
    // bricks array
    var bricks = [SKSpriteNode]()
    var gems = [SKSpriteNode]()
    var brickSize = CGSize.zero
    
    var brickLevel = BrickLevel.low
    // movement speed
    var scrollSpeed: CGFloat = 5.0
    let startingScrollSpeed = 5.0
    
    // how fast sprites will fall down
    let gravitySpeed: CGFloat = 1.5
    
    var score = 0
    var highScore = 0
    var lastScoreUpdateTime: TimeInterval = 0.0
    
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
        
        setupLabels()
        
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
    
    func setupLabels() {
        let scoreTextLabel: SKLabelNode = SKLabelNode(text: "Score")
        scoreTextLabel.position = CGPoint(x: 14.0, y: frame.size.height - 20.0)
        scoreTextLabel.horizontalAlignmentMode = .left
        scoreTextLabel.fontName = "Courier-Bold"
        scoreTextLabel.fontSize = 14.0
        scoreTextLabel.zPosition = 20
        addChild(scoreTextLabel)
        
        let scoreLabel: SKLabelNode = SKLabelNode(text: "0")
        scoreLabel.position = CGPoint(x: 14.0, y: frame.size.height - 40.0)
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.fontName = "Courier-Bold"
        scoreLabel.fontSize = 18.0
        scoreLabel.name = "scoreLabel"
        scoreLabel.zPosition = 20
        addChild(scoreLabel)
        
        let highScoreTextLabel: SKLabelNode = SKLabelNode(text: "Highest score")
        highScoreTextLabel.position = CGPoint(x: frame.size.width - 14.0, y: frame.size.height - 20.0)
        highScoreTextLabel.horizontalAlignmentMode = .right
        highScoreTextLabel.fontName = "Courier-Bold"
        highScoreTextLabel.fontSize = 14.0
        highScoreTextLabel.zPosition = 20
        addChild(highScoreTextLabel)
        
        let highScoreLabel: SKLabelNode = SKLabelNode(text: "0")
        highScoreLabel.position = CGPoint(x: frame.size.width - 14.0, y: frame.size.height - 40.0)
        highScoreLabel.horizontalAlignmentMode = .right
        highScoreLabel.fontName = "Courier-Bold"
        highScoreLabel.fontSize = 18.0
        highScoreLabel.name = "highScoreLabel"
        highScoreLabel.zPosition = 20
        addChild(highScoreLabel)
    }
    
    func updateScoreLabelText() {
        if let scoreLabel = childNode(withName: "scoreLabel") as? SKLabelNode {
            scoreLabel.text = String(format: "%04d", score)
        }
    }
    
    func updateHighScorelabelText() {
        if let highScoreLabel = childNode(withName: "highScoreLabel") as? SKLabelNode {
            highScoreLabel.text = String(format: "%04d", highScore)
        }
    }
    
    func startGame() {
        score = 0
        resetSkater()
        scrollSpeed = startingScrollSpeed
        brickLevel = .low
        lastUpdateTime = nil
        
        for brick in bricks {
            brick.removeFromParent()
        }
        bricks.removeAll(keepingCapacity: true)
        
        for gem in gems {
            removeGem(gem)
        }
    }
    
    func updateScore(withCurrentTime currentTime: TimeInterval){
        let elapsedTime = currentTime - lastScoreUpdateTime
        
        if elapsedTime > 1.0 {
            score += Int(scrollSpeed)
            lastScoreUpdateTime = currentTime
            updateScoreLabelText()
        }
    }
    
    func gameOver() {
        
        if score > highScore {
            highScore = score
            updateHighScorelabelText()
        }
        
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
    
    func spawnGem(atPosition position: CGPoint){
        let gem = SKSpriteNode(imageNamed: "gem")
        gem.position = position
        gem.zPosition = 9
        addChild(gem)
        gem.physicsBody = SKPhysicsBody(rectangleOf: gem.size, center: gem.centerRect.origin)
        gem.physicsBody?.categoryBitMask = PhysicsCategory.gem
        gem.physicsBody?.affectedByGravity = false
        
        gems.append(gem)
    }
    
    func removeGem(_ gem: SKSpriteNode){
        gem.removeFromParent()
        if let gemIndex = gems.firstIndex(of: gem) {
            gems.remove(at: gemIndex)
        }
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
            var brickX = farthestRightBrickX + brickSize.width + 1.0
            let brickY = (brickSize.height / 2) + brickLevel.rawValue
            
            let randomNumber = arc4random_uniform(99)
            
            if randomNumber < 2 && score > 10 {
                let gap = 20.0 * scrollSpeed
                brickX += gap
                let randomGemYAmount = CGFloat(arc4random_uniform(150))
                let newGemY = brickY + skater.size.height + randomGemYAmount
                let newGemX = brickX - gap / 2.0
                spawnGem(atPosition: CGPoint(x: newGemX, y: newGemY))
                
            } else if randomNumber < 4 && score > 20 {
                if brickLevel == .high {
                    brickLevel = .low
                } else {
                    brickLevel = .high
                }
            }
            
            let newBrick = spawnBrick(atPosition: CGPoint(x: brickX, y: brickY))
            farthestRightBrickX = newBrick.position.x
        }
        
    }
    
    func updateGems(withScrollAmount currentScrollAmount: CGFloat) {
        for gem in gems {
            let thisGemX = gem.position.x - currentScrollAmount
            gem.position = CGPoint(x: thisGemX, y: gem.position.y)
            
            if gem.position.x < 0.0 {
                removeGem(gem)
            }
        }
    }
    
    func updateSkater() {
//        if !skater.isOnGround {
//            let velocityY = skater.velocity.y - gravitySpeed
//            skater.velocity = CGPoint(x: skater.velocity.x, y: velocityY)
//
//            let newSkaterY: CGFloat = skater.position.y + skater.velocity.y
//            skater.position = CGPoint(x: skater.position.x, y: newSkaterY)
//
//            if skater.position.y < skater.mimimumY {
//                skater.position.y = skater.mimimumY
//                skater.velocity = CGPoint.zero
//                skater.isOnGround = true
//            }
//        }
        
        // check if skater is on the ground
        if let velocityY = skater.physicsBody?.velocity.dy {
            if velocityY < -100.0 || velocityY > 100.0 {
                skater.isOnGround = false
            }
        }
        
        let isOffScreen = skater.position.y < 0.0 || skater.position.x < 0
        let maxRotation = CGFloat(GLKMathDegreesToRadians(85.0))
        let isTippedOver = skater.zRotation > maxRotation || skater.zRotation < -maxRotation
        
        if isOffScreen || isTippedOver {
            gameOver()
        }
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        scrollSpeed += 0.01
        
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
        updateGems(withScrollAmount: currentScrollAmount)
        updateScore(withCurrentTime: currentTime)
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
        } else if contact.bodyA.categoryBitMask == PhysicsCategory.skater && contact.bodyB.categoryBitMask == PhysicsCategory.gem {
            if let gem = contact.bodyB.node as? SKSpriteNode {
                score += 50
                updateScoreLabelText()
                removeGem(gem)
            }
        }
    }
}
