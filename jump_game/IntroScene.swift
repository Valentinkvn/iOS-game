import SpriteKit
import GameplayKit
import UIKit

// is the music activated?
var sound : Bool = true

class GameScene: SKScene {
    
    // main nodes of the biew
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
                goToGame()
            }
            
            // the sound button was pressed
            if (soundButton.contains(pointOfTouch)){
                // toggle the sound and change the texture of sound image
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
    
    private func initMenu() {

        let width = self.size.width
        let height = self.size.height
        
        print(self.size)
        
        // init background
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

        //create play button
        playButton = SKSpriteNode(imageNamed: "play")
        playButton.name = "playButton"
        playButton.zPosition = 1
        playButton.position = CGPoint(x: 0, y: -width/6 )
        // set the scale to 0 to have a starting point for scaling transform
        playButton.setScale(0)
        playButton.run(SKAction.scale(to: 0.6, duration: 2.0))
        self.addChild(playButton)
        
        // create sound button
        soundButton = SKSpriteNode(imageNamed: "sound")
        soundButton.name = "soundButton"
        soundButton.zPosition = 1
        soundButton.position = CGPoint(x: -2*height/3, y: width/6)
        self.addChild(soundButton)
        
        // create sound node
        let soundUrl = Bundle.main.url(forResource: "Jungle_Intro", withExtension: "mp3")!
        let backgroundMusic = SKAudioNode(url: soundUrl)
        backgroundMusic.name = "backgroundMusic"
        self.addChild(backgroundMusic)
    }
    
    private func goToGame() {
        // first, fadeOut the playbutton and then play the doors transition
        let fadeOut = SKAction.fadeOut(withDuration: 1.0)
        playButton.run(fadeOut, completion: {
            let doors = SKTransition.doorway(withDuration: 2.5)
            let jumperScene = JumperScene(fileNamed: "JumperScene")
            // go to the jumper scene
            self.view?.presentScene(jumperScene!, transition: doors)
        })
    }

}
