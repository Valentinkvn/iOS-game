import SpriteKit

class GameOverScene: SKScene {
    
    var highScore = 0
    
    var background = SKSpriteNode()
    var gameOverLabel = SKLabelNode(fontNamed: "The Bold Font")
    var scoreLabel = SKLabelNode(fontNamed: "The Bold Font")
    var highScoreLabel = SKLabelNode(fontNamed: "The Bold Font")
    var restartLabel = SKLabelNode(fontNamed: "The Bold Font")
    
    override func didMove(to view: SKView) {
        self.initGameOverScene()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch: AnyObject in touches{
            let pointOfTouch = touch.location(in: self)
            
            // the play button was pressed
            if (restartLabel.contains(pointOfTouch)){
                goToGame()
            }
        }
    }
    
    private func goToGame() {
        let fadeOut = SKTransition.fade(withDuration: 1.0)
        let gameScene = JumperScene(fileNamed: "JumperScene")
        
        // go to the jumper scene
        self.view?.presentScene(gameScene!, transition: fadeOut)
    }
    
    private func initGameOverScene() {

        let width = self.size.width
        let height = self.size.height
        
        // init background
        background = SKSpriteNode(imageNamed: "rainforest")
        background.name = "backgroundNode"
        background.size = self.size
        //background.anchorPoint = CGPoint(x: width/2, y: height/2)
        background.position = CGPoint(x: width/2, y: height/2)
        background.zPosition = 0
        self.addChild(background)
        
        gameOverLabel.text = "Game Over"
        gameOverLabel.fontSize = 80
        gameOverLabel.color = SKColor.white
        gameOverLabel.zPosition = 5
        gameOverLabel.position = CGPoint(x: width/2, y: height*0.7)
        self.addChild(gameOverLabel)
        
        scoreLabel.text = "Score: \(gameScore)"
        scoreLabel.fontSize = 40
        scoreLabel.color = SKColor.white
        scoreLabel.zPosition = 5
        scoreLabel.position = CGPoint(x: width/2, y: height*0.5)
        self.addChild(scoreLabel)
        
        if gameScore > UserDefaults.standard.integer(forKey: "highscore"){
            UserDefaults.standard.set(gameScore, forKey: "highscore") // set
            highScore = gameScore
        }
        else{
            highScore = UserDefaults.standard.integer(forKey: "highscore") // get
        }
        
        highScoreLabel.text = "Highscore: \(highScore)"
        highScoreLabel.fontSize = 40
        highScoreLabel.color = SKColor.white
        highScoreLabel.zPosition = 5
        highScoreLabel.position = CGPoint(x: width/2, y: height*0.4)
        self.addChild(highScoreLabel)
        
        restartLabel.text = "Restart"
        restartLabel.fontSize = 60
        restartLabel.color = SKColor.white
        restartLabel.zPosition = 5
        restartLabel.position = CGPoint(x: width/2, y: height*0.15)
        self.addChild(restartLabel)
        
        let deadSound = SKAction.playSoundFileNamed("dead.wav", waitForCompletion: true)
        self.run(deadSound)
        
    }
    

}
