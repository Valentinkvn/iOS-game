import UIKit
import SpriteKit

class JumperScene: SKScene, SKPhysicsContactDelegate {
    
    // is the music activated?
    var sound: Bool = true
    
    // declare the arrays of atlas frames
    var jumperRunning = [SKTexture]()
    var jumperIdle = [SKTexture]()
    var jumperJump = [SKTexture]()
    var jumperHit = [SKTexture]()
    var jumperGround = [SKTexture]()
    
    var background = SKSpriteNode()
    var ground = SKSpriteNode()
    var soundButton = SKSpriteNode()
    var enemyNode = SKSpriteNode()
    var jumperNode = SKSpriteNode()
    
    struct PhysicsCategories {
        static let None : UInt32 = 0
        static let Jumper : UInt32 = 0b1
        static let Bananas : UInt32 = 0b10
    }
    
    func randomInt(min: Int, max: Int) -> Int {
        return min + Int(arc4random_uniform(UInt32(max - min + 1)))
    }
    
    func deg2rad(degree: Int) -> CGFloat {
        return CGFloat(degree) * .pi / 180
    }
    
    override func didMove(to view: SKView) {
        self.physicsWorld.contactDelegate = self
        self.initJumperScene()
        self.startLevel()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let jumperNode = self.childNode(withName: "jumperNode")
        
        let backgroundMusic = self.childNode(withName: "backgroundMusic") as! SKAudioNode
        
        for touch: AnyObject in touches{
            let pointOfTouch = touch.location(in: self)
            // if the right side of the window was touched, then play the jumper and ground animations
            if(pointOfTouch.x > 0) {
                if (jumperNode != nil){
                    let animation = SKAction.animate(with: jumperRunning, timePerFrame:0.1)
                    jumperNode?.run(animation)
                    let groundAnimation = SKAction.animate(with: jumperGround, timePerFrame:0.4)
                    ground.run(groundAnimation)
                }
//                moveEnemy()
//                spawnBananas()
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
        
        if body1.categoryBitMask == PhysicsCategories.Jumper && body2.categoryBitMask == PhysicsCategories.Bananas{
            spawnSplash(spawnPosition: body2.node!.position)
            body2.node?.removeFromParent()
        }
    }
    
    func initJumperScene() {
        
        let width = self.size.width
        let height = self.size.height
        
        print(self.size)
        
        // init background
        background = SKSpriteNode(imageNamed: "rainforest")
        background.size = self.size
        background.position = CGPoint(x: 0, y: 0)
        background.zPosition = 0
        background.name = "backgroundNode"
        self.addChild(background)
        
        // init ground
        ground = SKSpriteNode(imageNamed: "ground-init")
        ground.size.width = self.size.width
        ground.size.height = self.size.height/10
        ground.position = CGPoint(x: 0, y: -self.size.height/2 + 15)
        ground.zPosition = 1
        ground.name = "groundNode"
        self.addChild(ground)
        
        // init jumper player
        jumperNode = SKSpriteNode(imageNamed: "jumper")
        jumperNode.position = CGPoint(x: -255, y: -125)
        jumperNode.zPosition = 2
        jumperNode.setScale(0.1)
        jumperNode.name = "jumperNode"
        jumperNode.physicsBody = SKPhysicsBody(rectangleOf: jumperNode.size)
        jumperNode.physicsBody!.affectedByGravity = false
        jumperNode.physicsBody!.categoryBitMask = PhysicsCategories.Jumper
        jumperNode.physicsBody!.collisionBitMask = PhysicsCategories.None
        jumperNode.physicsBody!.contactTestBitMask = PhysicsCategories.Bananas
        self.addChild(jumperNode)
        
        // declare atlas textures
        let runningAtlas = SKTextureAtlas(named: "running")
        let idleAtlas = SKTextureAtlas(named: "idle")
        let hitAtlas = SKTextureAtlas(named: "gotHit")
        let jumpAtlas = SKTextureAtlas(named: "jump")
        let groundAtlas = SKTextureAtlas(named: "ground")
        
        jumperRunning = grabAtlas(dataAtlas: runningAtlas, label: "running")
        jumperIdle = grabAtlas(dataAtlas: idleAtlas, label: "idle")
        jumperHit = grabAtlas(dataAtlas: hitAtlas, label: "gotHit")
        jumperJump = grabAtlas(dataAtlas: jumpAtlas, label: "jump")
        jumperGround = grabAtlas(dataAtlas: groundAtlas, label: "ground")
        
        // create sound button
        soundButton = SKSpriteNode(imageNamed: "sound")
        soundButton.name = "soundButton"
        soundButton.zPosition = 1
        soundButton.setScale(0.5)
        soundButton.position = CGPoint(x: -2*height/3, y: width/6)
        self.addChild(soundButton)
        
        // create sound node
        let soundUrl = Bundle.main.url(forResource: "Forest_Ambience", withExtension: "mp3")!
        let backgroundMusic = SKAudioNode(url: soundUrl)
        backgroundMusic.name = "backgroundMusic"
        self.addChild(backgroundMusic)
        
        // create sound button
        enemyNode = SKSpriteNode(imageNamed: "monkey-enemy")
        enemyNode.name = "enemyNode"
        enemyNode.zPosition = 1
        enemyNode.setScale(2.0)
        enemyNode.position = CGPoint(x: 2*height/3, y: width/6)
        self.addChild(enemyNode)
        
        
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
    
    func startLevel(){
        let spawn = SKAction.run(spawnBananas)
        let move = SKAction.run(moveEnemy)
        let wait = SKAction.wait(forDuration: 2.0)
        let spawnSeq = SKAction.sequence([wait, move, spawn])
        let spawnForever = SKAction.repeatForever(spawnSeq)
        self.run(spawnForever)
    }
    
    func spawnBananas(){

        let throwingError = randomInt(min: -100, max: 50)
        
        // spawn bananas to be put in the hand of the monkey and add a throwing error to the end point
        let startPoint = CGPoint(x: Int((enemyNode.position.x) - 30), y: Int((enemyNode.position.y) + 10))
        let endPoint = CGPoint(x: Int(-self.size.width/2), y: Int((jumperNode.position.y)) + throwingError)
        
        // create the bananas node with a random rotation
        let bananasNode = SKSpriteNode(imageNamed: "bananas")
        bananasNode.setScale(0.08)
        bananasNode.position = startPoint
        bananasNode.zPosition = 1.5
        bananasNode.zRotation = deg2rad(degree: randomInt(min: 0, max: 360))
        bananasNode.physicsBody = SKPhysicsBody(rectangleOf: bananasNode.size)
        bananasNode.physicsBody!.affectedByGravity = false
        bananasNode.physicsBody!.categoryBitMask = PhysicsCategories.Bananas
        bananasNode.physicsBody!.collisionBitMask = PhysicsCategories.None
        bananasNode.physicsBody!.contactTestBitMask = PhysicsCategories.Jumper
        self.addChild(bananasNode)
        
        // group the move and rotate actions together and then run sequencelly the grouping and the remove actions
        let moveBananas = SKAction.move(to: endPoint, duration: 1.0)
        let rotateBananas = SKAction.rotate(byAngle: .pi, duration: 1.0)
        let bananaGroup = SKAction.group([moveBananas, rotateBananas])
        let removeBananas = SKAction.removeFromParent()
        let bananaSequence = SKAction.sequence([bananaGroup, removeBananas])
        bananasNode.run(bananaSequence)
        
    }
    
    func spawnSplash(spawnPosition: CGPoint){
        let splashNode = SKSpriteNode(imageNamed: "explosion")
        splashNode.position = spawnPosition
        splashNode.zPosition = 2
        splashNode.setScale(0)
        self.addChild(splashNode)
        
        let scaleAction = SKAction.scale(to: 0.2, duration: 0.1)
        let fadeAction = SKAction.fadeOut(withDuration: 0.1)
        let removeAction = SKAction.removeFromParent()
        
        let splashSequence = SKAction.sequence([scaleAction, fadeAction, removeAction])
        
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
    
}
