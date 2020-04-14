//
//  GameScene.swift
//  jump_game
//
//  Created by user171355 on 4/13/20.
//  Copyright © 2020 user171355. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    override func didMove(to view: SKView) {
        self.initMenu()
    }
    

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let playButton = self.childNode(withName: "playButton")
        
        for touch: AnyObject in touches{
            let pointOfTouch = touch.location(in: self)
            if (playButton?.contains(pointOfTouch))!{
                let fadeOut = SKAction.fadeOut(withDuration: 1.0)
                playButton?.run(fadeOut, completion: {
                    let doors = SKTransition.doorway(withDuration: 1.5)
                    let jumperScene = JumperScene(fileNamed: "JumperScene")
                    self.view?.presentScene(jumperScene!, transition: doors)
                })
            }
        }
        
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
    private func initMenu() {
//        let height = self.size.height
        let width = self.size.width
        
        let background = SKSpriteNode(imageNamed: "rainforest")
        background.name = "backgroundNode"
        background.size = self.size
        background.position = CGPoint(x: 0, y: 0)
        background.zPosition = 0
        self.addChild(background)
        
        // set the game logo properties
        let gameLogo = SKSpriteNode(imageNamed: "logo")
        gameLogo.name = "gameLogo"
        gameLogo.zPosition = 1
        gameLogo.position = CGPoint(x: 0, y: 250)
        gameLogo.run((SKAction.move(by: CGVector(dx: 0, dy: -100), duration: 1.0)))
        self.addChild(gameLogo)

        //Create play button
        let playButton = SKSpriteNode(imageNamed: "play")
        playButton.name = "playButton"
        playButton.zPosition = 1
        playButton.position = CGPoint(x: 0, y: -width/6 )
//        playButton.fillColor = SKColor.cyan
        
        // set the scale to 0 to have a starting poit for scaling transform
        playButton.setScale(0)

        playButton.run(SKAction.scale(to: 0.6, duration: 1.0))
        self.addChild(playButton)
        
        
    }
}
