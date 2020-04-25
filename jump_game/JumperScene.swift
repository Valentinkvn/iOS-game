import UIKit
import SpriteKit

var gameScore = 0

class JumperScene: SKScene, SKPhysicsContactDelegate {
    
    let throwingErrorMargin = 200
    var lastRewardTime : Double = 0 // in milliseconds
    var gameLives: Int32 = 5
    var gameLevel: UInt32 = 0
    
    var jumperOnGroundPos : CGPoint = CGPoint()
    
    // declare the arrays of atlas frames
    var jumperRunning = [SKTexture]()
    var jumperIdle = [SKTexture]()
    var jumperJump = [SKTexture]()
    var jumperHit = [SKTexture]()
    var jumperGround = [SKTexture]()
    var jumperCrouch = [SKTexture]()
    
    var background = SKSpriteNode()
    var groundNode = SKSpriteNode()
    var enemyNode = SKSpriteNode()
    var jumperNode = SKSpriteNode()
    var scoreNode = SKLabelNode(fontNamed: "The Bold Font")
    var livesNode = SKLabelNode(fontNamed: "The Bold Font")
    
    let backgroundMusic = SKAudioNode()
    
    struct PhysicsCategories {
        static let None :       UInt32 = 0
        static let Jumper :     UInt32 = 0b1
        static let Bananas :    UInt32 = 0b10
        static let Reward :     UInt32 = 0b100
    }
    
    func randomInt(min: Int, max: Int) -> Int {
        return min + Int(arc4random_uniform(UInt32(max - min + 1)))
    }
    
    func deg2rad(degree: Int) -> CGFloat {
        return CGFloat(degree) * .pi / 180
    }
    
    override func didMove(to view: SKView) {
        
        gameScore = 0
        
        self.physicsWorld.contactDelegate = self
        if (sound == true){
            backgroundMusic.run(SKAction.play())
        }
        else{
            backgroundMusic.run(SKAction.stop())
        }
            
        self.initJumperScene()
        self.startNewLevel()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch: AnyObject in touches{
            let pointOfTouch = touch.location(in: self)
            
            // if the right side of the window was touched, then play the jumper and ground animations
            if (pointOfTouch.x > 0) {
                let now = getCurrentTimeInMillis()
                let timeElapsed = now - lastRewardTime
                if (touch.tapCount == 1){
                    playerJump(tapType: "single-tap", elapsedTime: timeElapsed)
                }
                else if (touch.tapCount == 2){
                    playerJump(tapType: "double-tap", elapsedTime: timeElapsed)
                }
            }
            else {
                playerCrouch()
            }
        }
    }
    
    func playerJump(tapType: String, elapsedTime: Double){
        
        var jumpReach : CGFloat = 0.0
        let initialPosition = jumperNode.position
        var jumpUpAction = SKAction()
        var jumpDownAction = SKAction()
        
        if (tapType == "single-tap"){
            jumpReach = 40.0
            
        }
        else if (tapType == "double-tap"){
            jumpReach = 80.0
        }
        if (elapsedTime < 500){
            // move up 20
            jumpUpAction = SKAction.moveTo(y: initialPosition.y + jumpReach*2, duration: 0.4)
            // move down 20
            jumpDownAction = SKAction.move(to: jumperOnGroundPos, duration: 0.8)
        }
        else{
            // move up 20
            jumpUpAction = SKAction.moveBy(x: 0, y: jumpReach, duration: 0.4)
            // move down 20
            jumpDownAction = SKAction.move(to: jumperOnGroundPos, duration: 0.4)
        }
        
        // sequence of move up then down
        let jumpSequence = SKAction.sequence([jumpUpAction, jumpDownAction])

        let jumpAnimation = SKAction.animate(with: jumperJump, timePerFrame:0.2)
        
        let jumpGroup = SKAction.group([jumpSequence, jumpAnimation])
        // make player run sequence
        jumperNode.run(jumpGroup)
    }
    
    func playerCrouch(){
        let scaleDown = SKAction.scaleY(to: 0.06, duration: 0.0)
        let scaleUp = SKAction.scaleY(to: 0.1, duration: 0.0)
        let moveDown = SKAction.moveTo(y: -140, duration: 0.0)
        let moveUp = SKAction.moveTo(y: -125, duration: 0.0)
        let crouchAnimation = SKAction.animate(with: jumperCrouch, timePerFrame:0.5)
        let crouchSeq = SKAction.sequence([scaleDown, moveDown, crouchAnimation, moveUp, scaleUp])
        jumperNode.run(crouchSeq)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        var body1 = SKPhysicsBody()
        var body2 = SKPhysicsBody()
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask{
            body1 = contact.bodyA
            body2 = contact.bodyB
        }
        else{
            body1 = contact.bodyB
            body2 = contact.bodyA
        }
        
        // the contact between the jumper and bananas
        if body1.categoryBitMask == PhysicsCategories.Jumper && body2.categoryBitMask == PhysicsCategories.Bananas{
            spawnSplash(spawnPosition: body2.node!.position)
            body2.node!.removeFromParent()
            let hitAnimation = SKAction.animate(with: jumperHit, timePerFrame:0.4)
            
            body1.node!.run(hitAnimation)
            loseLife()
        }
        
        // the contact between the jumper and reward
        if body1.categoryBitMask == PhysicsCategories.Jumper && body2.categoryBitMask == PhysicsCategories.Reward{
            let scaleAction = SKAction.scale(to: 0.2, duration: 0.1)
            let fadeAction = SKAction.fadeOut(withDuration: 0.1)
            let removeAction = SKAction.removeFromParent()
            let rewardSeq = SKAction.sequence([scaleAction, fadeAction, removeAction])
            
            body2.node!.run(rewardSeq)
            if (body2.node!.name == "special") {
                print("wowowow")
            }
            addScore()
            
            lastRewardTime = getCurrentTimeInMillis()

        }
    }
    func getCurrentTimeInMillis() -> Double{
        return Double(DispatchTime.now().uptimeNanoseconds/1_000_000)
    }
    
    func initJumperScene() {
        
        let width = self.size.width
        let height = self.size.height
        
        // init background
        background = SKSpriteNode(imageNamed: "rainforest")
        background.size = self.size
        background.position = CGPoint(x: 0, y: 0)
        background.zPosition = 0
        background.name = "backgroundNode"
        self.addChild(background)
        
        // init ground
        groundNode = SKSpriteNode(imageNamed: "ground-init")
        groundNode.size.width = self.size.width
        groundNode.size.height = self.size.height/10
        groundNode.position = CGPoint(x: 0, y: -self.size.height/2 + 15)
        groundNode.zPosition = 1
        groundNode.name = "groundNode"
        self.addChild(groundNode)
        
        // init jumper player
        jumperNode = SKSpriteNode(imageNamed: "jumper")
        jumperNode.position = CGPoint(x: -255, y: -125)
        jumperNode.zPosition = 4
        jumperNode.setScale(0.1)
        jumperNode.name = "jumperNode"
        jumperNode.physicsBody = SKPhysicsBody(rectangleOf: jumperNode.size)
        jumperNode.physicsBody!.affectedByGravity = false
        jumperNode.physicsBody!.categoryBitMask = PhysicsCategories.Jumper
        jumperNode.physicsBody!.collisionBitMask = PhysicsCategories.None
        jumperNode.physicsBody!.contactTestBitMask = PhysicsCategories.Bananas
        jumperOnGroundPos = jumperNode.position
        self.addChild(jumperNode)
        
        // declare atlas textures
        let runningAtlas = SKTextureAtlas(named: "running")
        let idleAtlas = SKTextureAtlas(named: "idle")
        let hitAtlas = SKTextureAtlas(named: "gotHit")
        let jumpAtlas = SKTextureAtlas(named: "jump")
        let crouchAtlas = SKTextureAtlas(named: "crouch")
        let groundAtlas = SKTextureAtlas(named: "ground")
        
        
        jumperRunning = grabAtlas(dataAtlas: runningAtlas, label: "running")
        jumperIdle = grabAtlas(dataAtlas: idleAtlas, label: "idle")
        jumperHit = grabAtlas(dataAtlas: hitAtlas, label: "gotHit")
        jumperJump = grabAtlas(dataAtlas: jumpAtlas, label: "jump")
        jumperGround = grabAtlas(dataAtlas: groundAtlas, label: "ground")
        jumperCrouch = grabAtlas(dataAtlas: crouchAtlas, label: "crouch")
        
        // create sound button
//        soundButton = SKSpriteNode(imageNamed: "sound")
//        soundButton.name = "soundButton"
//        soundButton.zPosition = 1
//        soundButton.setScale(0.5)
//        soundButton.position = CGPoint(x: -2*height/3, y: width/6)
//        self.addChild(soundButton)
        
        // create sound node
        let soundUrl = Bundle.main.url(forResource: "Forest_Ambience", withExtension: "mp3")!
        let backgroundMusic = SKAudioNode(url: soundUrl)
        backgroundMusic.name = "backgroundMusic"
        self.addChild(backgroundMusic)
        
        // init enemy
        enemyNode = SKSpriteNode(imageNamed: "monkey-enemy")
        enemyNode.name = "enemyNode"
        enemyNode.zPosition = 4
        enemyNode.setScale(2.0)
        enemyNode.position = CGPoint(x: 2*height/3, y: width/6)
        self.addChild(enemyNode)
        
        // init score and lives nodes
        scoreNode.text = "Score: 0"
        scoreNode.fontSize = 20
        scoreNode.color = SKColor.white
        scoreNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        scoreNode.zPosition = 5
        scoreNode.position = CGPoint(x: -width/2*0.85, y: height/2*0.8)
        self.addChild(scoreNode)
        
        livesNode.text = "Lives: \(gameLives)"
        livesNode.fontSize = 20
        livesNode.color = SKColor.brown
        livesNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        livesNode.zPosition = 5
        livesNode.position = CGPoint(x: -width/2*0.85, y: height/2*0.6)
        self.addChild(livesNode)
        
    }
    
    // function that takes an Atlas Texture and a label and returns the array of corresponing frames
    func grabAtlas(dataAtlas: SKTextureAtlas, label: String) -> [SKTexture]{
        var atlas = [SKTexture]()
        for index in 1...dataAtlas.textureNames.count{
            let path = "frame-" + label + "-%01d"
            let imgName = String(format: path, index)
            atlas += [dataAtlas.textureNamed(imgName)]
        }
        return atlas
    }
    
    func startNewLevel(){
        
        gameLevel += 1
        
        // if next level then stop spawning with the previous timers and start with new ones
        if self.action(forKey: "spawnBananasForever") != nil && self.action(forKey: "spawnRewardForever") != nil{
            self.removeAction(forKey: "spawnBananasForever")
            self.removeAction(forKey: "spawnRewardForever")
        }
        
        // declare a spawning interval used for spawn functions
        var spawningDelay = NSTimeIntervalSince1970
        
        switch gameLevel {
            case 1:
                spawningDelay = 1.8
            case 2:
                spawningDelay = 1.0
            case 3:
                spawningDelay = 0.5
            default:
                spawningDelay = 2.0
                print("Could not find level info")
        }
        
        let enemyMove = SKAction.run(moveEnemy)
        let bananaSpawn = SKAction.run(spawnBananas)
        let bananasWait = SKAction.wait(forDuration: spawningDelay + 2.0)
        let bananaSeq = SKAction.sequence([bananasWait, enemyMove, bananaSpawn])
        
        let rewardSpawn = SKAction.run(spawnReward)
        let rewardWait = SKAction.wait(forDuration: spawningDelay)
        let rewardSeq = SKAction.sequence([rewardWait, rewardSpawn])
        
        let runAnimation = SKAction.animate(with: jumperRunning, timePerFrame:0.1)
        jumperNode.run(runAnimation)
        let groundAnimation = SKAction.animate(with: jumperGround, timePerFrame:0.2)
        groundNode.run(groundAnimation)
//        let renderWait = SKAction.wait(forDuration: 1.1)
//        let renderGroup = SKAction.group([runAnimation, groundAnimation])
//        let renderSeq = SKAction.sequence([renderGroup, renderWait])

        // run the bananas and reward spawn in parallel
        let spawnBananasForever = SKAction.repeatForever(bananaSeq)
        let spawnRewardForever = SKAction.repeatForever(rewardSeq)
        let renderRunForever = SKAction.repeatForever(runAnimation)
        let renderGroundForever = SKAction.repeatForever(groundAnimation)
        
        self.run(spawnBananasForever, withKey: "spawnBananasForever")
        self.run(spawnRewardForever, withKey: "spawnRewardForever")
        jumperNode.run(renderRunForever)
        groundNode.run(renderGroundForever)
    }
    
    func spawnBananas(){

        let throwingError = randomInt(min: -throwingErrorMargin, max: throwingErrorMargin)
        
        // spawn bananas to be put in the hand of the monkey and add a throwing error to the end point
        let startPoint = CGPoint(x: Int((enemyNode.position.x) - 30), y: Int((enemyNode.position.y) + 10))
        let endPoint = CGPoint(x: Int(-self.size.width/2), y: Int((jumperNode.position.y)) + throwingError)
        
        // create the bananas node with a random rotation
        let bananasNode = SKSpriteNode(imageNamed: "bananas")
        bananasNode.setScale(0.08)
        bananasNode.position = startPoint
        bananasNode.zPosition = 2
        bananasNode.zRotation = deg2rad(degree: randomInt(min: 0, max: 360))
        bananasNode.physicsBody = SKPhysicsBody(rectangleOf: bananasNode.size)
        bananasNode.physicsBody!.affectedByGravity = false
        bananasNode.physicsBody!.categoryBitMask = PhysicsCategories.Bananas
        bananasNode.physicsBody!.collisionBitMask = PhysicsCategories.None
        bananasNode.physicsBody!.contactTestBitMask = PhysicsCategories.Jumper
        self.addChild(bananasNode)
        
        // group the move and rotate actions together and then run sequencelly the grouping and the remove actions
        let throwingSound = SKAction.playSoundFileNamed("sfx_throw.wav", waitForCompletion: false)
        let moveBananas = SKAction.move(to: endPoint, duration: 1.0)
        // add a simple rotation for the animation factor
        let rotateBananas = SKAction.rotate(byAngle: .pi, duration: 1.0)
        let bananaGroup = SKAction.group([moveBananas, rotateBananas])
        let removeBananas = SKAction.removeFromParent()
        let bananaSequence = SKAction.sequence([throwingSound, bananaGroup, removeBananas])
        
        bananasNode.run(bananaSequence)
        
    }
    
    func spawnReward(){
        // define a margin for the movement and random chose an endPoint
        let margin = 100
        let specialReward = randomInt(min: 0, max: 3)
        
        let randomY = randomInt(min: -Int(self.size.height/2) + margin, max: Int(self.size.height/2) - margin)
        let startPoint = CGPoint(x: Int(self.size.width/2), y: randomY)
        let endPoint = CGPoint(x: -Int(self.size.width/2), y: randomY)
        
        let vineNode = SKSpriteNode(imageNamed: "jungle-vine-1")
        vineNode.size.height = background.size.height/2 - CGFloat(randomY)
        vineNode.anchorPoint = CGPoint(x: 0.5, y: 0)
        vineNode.position = startPoint
        vineNode.zPosition = 2
        self.addChild(vineNode)
        
        var rewardNode : SKSpriteNode
        if (specialReward == 0){
            rewardNode = SKSpriteNode(imageNamed: "special-gem")
            rewardNode.name = "special"
        }
        else{
            rewardNode = SKSpriteNode(imageNamed: "gem")
            rewardNode.name = "common"
        }
        
        rewardNode.setScale(0.15)
//        rewardNode.anchorPoint = CGPoint(x: 0.5, y: 1.0)
        rewardNode.position = startPoint
        rewardNode.zPosition = 3
        rewardNode.physicsBody = SKPhysicsBody(rectangleOf: rewardNode.size)
        rewardNode.physicsBody!.affectedByGravity = false
        rewardNode.physicsBody!.categoryBitMask = PhysicsCategories.Reward
        rewardNode.physicsBody!.collisionBitMask = PhysicsCategories.None
        rewardNode.physicsBody!.contactTestBitMask = PhysicsCategories.Jumper
        self.addChild(rewardNode)
        
        let moveReward = SKAction.move(to: endPoint, duration: 2.0)
        let removeReward = SKAction.removeFromParent()
        let rewardSequence = SKAction.sequence([moveReward, removeReward])
        
        rewardNode.run(rewardSequence)
        vineNode.run(rewardSequence)
    }
    
    func spawnSplash(spawnPosition: CGPoint){
        let splashNode = SKSpriteNode(imageNamed: "explosion")
        splashNode.position = spawnPosition
        splashNode.zPosition = 2
        splashNode.setScale(0)
        self.addChild(splashNode)
        
        let hitSound = SKAction.playSoundFileNamed("hit.wav", waitForCompletion: false)
        let scaleAction = SKAction.scale(to: 0.2, duration: 0.1)
        let fadeAction = SKAction.fadeOut(withDuration: 0.1)
        let removeAction = SKAction.removeFromParent()
        let splashSequence = SKAction.sequence([hitSound, scaleAction, fadeAction, removeAction])
        
        splashNode.run(splashSequence)
    }
    
    func moveEnemy(){

        // define a margin for the movement and random chose an endPoint
        let margin = 100
        let randomYEnd = randomInt(min: -Int(self.size.height/2) + margin, max: Int(self.size.height/2) - margin)
        let endPoint = CGPoint(x: Int(enemyNode.position.x), y: randomYEnd)
        
        // move the monkey to the endpoint
        let moveMonkey = SKAction.move(to: endPoint, duration: 1.0)
        enemyNode.run(moveMonkey)
    }
    
    func addScore(){
        gameScore += 1
        scoreNode.text = "Score: \(gameScore)"
        
        if gameScore == 5 || gameScore == 20 || gameScore == 50{
            startNewLevel()
        }
    }
    
    func loseLife(){
        gameLives -= 1
        
        if gameLives < 0{
            goToGameOver()
        }
        else{
            livesNode.text = "Lives: \(gameLives)"
            
            let scaleUp = SKAction.scale(to: 1.5, duration: 0.2)
            let scaleDown = SKAction.scale(to: 1.0, duration: 0.2)
            let scaleSeq = SKAction.sequence([scaleUp, scaleDown])
            
            livesNode.run(scaleSeq)
        }
    }
    
    func goToGameOver(){
        self.removeAllActions()
        let fadeOut = SKTransition.fade(withDuration: 1.0)
        let gameOver = GameOverScene(size : self.size)
        gameOver.scaleMode = self.scaleMode
        
        // go to the jumper scene
        self.view?.presentScene(gameOver, transition: fadeOut)
    }
}
