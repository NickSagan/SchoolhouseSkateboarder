//
//  GameScene.swift
//  SchoolhouseSkateboarder
//
//  Created by Nick Sagan on 27.10.2021.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    let skater = Skater(imageNamed: "skater")
    
    override func didMove(to view: SKView) {
        // left bottom corner: 0, 0
        anchorPoint = CGPoint.zero
        
        // Create background sprite
        let background = SKSpriteNode(imageNamed: "background")
        // set x y constants to be equal frame x y (default: 0, 0)
        let xMid = frame.midX
        let yMid = frame.midY
        background.position = CGPoint(x: xMid, y: yMid)
        // add bg sprite to scene
        addChild(background)
        resetSkater()
        addChild(skater)
        }
    
    func resetSkater() {
        //skater init position
        let skaterX = frame.midX / 2.0
        let skaterY = skater.frame.height / 2.0 + 64
        skater.position = CGPoint(x: skaterX, y: skaterY)
        skater.zPosition = 10
        skater.mimimumY = skaterY
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered

    }
}
