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
    
    var sound: Bool = true
    
    var background = SKSpriteNode()
    var gameLogo = SKSpriteNode()
    var playButton = SKSpriteNode()
    var soundButton = SKSpriteNode()
    
    override func didMove(to view: SKView) {
        self.initMenu()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

        let backgroundMusic = self.childNode(withName: "backgroundMusic") as! SKAudioNode
        
        for touch: AnyObject in touches{
            let pointOfTouch = touch.location(in: self)
            // the play button was pressed
            if (playButton.contains(pointOfTouch)){
                let fadeOut = SKAction.fadeOut(withDuration: 1.0)
                playButton.run(fadeOut, completion: {
                    let doors = SKTransition.doorway(withDuration: 1.5)
                    let jumperScene = JumperScene(fileNamed: "JumperScene")
                    self.view?.presentScene(jumperScene!, transition: doors)
                })
            }
            // the sound button was pressed
            if (soundButton.contains(pointOfTouch)){
                if (sound == true){
                    soundButton.texture = SKTexture(imageNamed: "mute")
                    backgroundMusic.run(SKAction.stop())
                    sound = false
                }
                else{
                    soundButton.texture = SKTexture(imageNamed: "sound")
                    backgroundMusic.run(SKAction.play())
                    sound = true
                }
                
            }
        }
        
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
    private func initMenu() {
//        let height = self.size.height
        let width = self.size.width
        let height = self.size.height
        
        background = SKSpriteNode(imageNamed: "rainforest")
        background.name = "backgroundNode"
        background.size = self.size
        background.position = CGPoint(x: 0, y: 0)
        background.zPosition = 0
        self.addChild(background)
        
        // set the game logo properties
        gameLogo = SKSpriteNode(imageNamed: "logo")
        gameLogo.name = "gameLogo"
        gameLogo.zPosition = 1
        gameLogo.position = CGPoint(x: 0, y: 250)
        gameLogo.run((SKAction.move(by: CGVector(dx: 0, dy: -100), duration: 1.0)))
        self.addChild(gameLogo)

        //Create play button
        playButton = SKSpriteNode(imageNamed: "play")
        playButton.name = "playButton"
        playButton.zPosition = 1
        playButton.position = CGPoint(x: 0, y: -width/6 )
        // set the scale to 0 to have a starting point for scaling transform
        playButton.setScale(0)
        playButton.run(SKAction.scale(to: 0.6, duration: 1.0))
        self.addChild(playButton)
        
        soundButton = SKSpriteNode(imageNamed: "sound")
        soundButton.name = "soundButton"
        soundButton.zPosition = 1
        soundButton.position = CGPoint(x: -2*height/3, y: -width/6)
        self.addChild(soundButton)
        
        let soundUrl = Bundle.main.url(forResource: "Jungle", withExtension: "mp3")!
        let backgroundMusic = SKAudioNode(url: soundUrl)
        backgroundMusic.name = "backgroundMusic"
        self.addChild(backgroundMusic)
        
        
    }
}
