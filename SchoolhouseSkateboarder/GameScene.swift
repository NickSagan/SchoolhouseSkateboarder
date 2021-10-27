//
//  GameScene.swift
//  SchoolhouseSkateboarder
//
//  Created by Nick Sagan on 27.10.2021.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    // skater sprite
    let skater = Skater(imageNamed: "skater")
    // bricks array
    var bricks = [SKSpriteNode]()
    var brickSize = CGSize.zero
    // movement speed
    var scrollSpeed: CGFloat = 5.0
    
    override func didMove(to view: SKView) {
        // left bottom corner: 0, 0
        anchorPoint = CGPoint.zero
        
        // Create background sprite
        let background = SKSpriteNode(imageNamed: "background")

        let xMid = frame.midX
        print(xMid)
        let yMid = frame.midY
        print(yMid)
        background.position = CGPoint(x: xMid, y: yMid)
        print(background.position)
        addChild(background)
        resetSkater()
        addChild(skater)
        print(skater.position)
        }
    
    func resetSkater() {
        //skater init position
        let skaterX = frame.midX / 2.0
        let skaterY = skater.frame.height / 2.0 + 64
        skater.position = CGPoint(x: skaterX, y: skaterY)
        skater.zPosition = 10
        skater.mimimumY = skaterY
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
            var brickX = farthestRightBrickX + brickSize.width + 1.0
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
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered

    }
}
