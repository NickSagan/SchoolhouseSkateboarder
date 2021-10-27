//
//  GameScene.swift
//  SchoolhouseSkateboarder
//
//  Created by Nick Sagan on 27.10.2021.
//

import SpriteKit

class GameScene: SKScene {
    
    override func didMove(to view: SKView) {
        anchorPoint = CGPoint.zero
        }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        let background = SKSpriteNode(imageNamed: "background")
        let xMid = frame.midX
        let yMid = frame.midY
        background.position = CGPoint(x: xMid, y: yMid)
        addChild(background)
    }
}
