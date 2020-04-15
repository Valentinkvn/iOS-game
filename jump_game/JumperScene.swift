import UIKit
import SpriteKit

class JumperScene: SKScene {
    
    var jumperRunning = [SKTexture]()
    var jumperIdle = [SKTexture]()
    var jumperJump = [SKTexture]()
    var jumperHit = [SKTexture]()
    var jumperGround = [SKTexture]()
    
    var background = SKSpriteNode()
    var ground = SKSpriteNode()
    
    
    override func didMove(to view: SKView) {
        self.initJumperScene()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let jumperNode = self.childNode(withName: "jumperNode")
        
        for touch: AnyObject in touches{
            let pointOfTouch = touch.location(in: self)
            if(pointOfTouch.x > 0) {
                if (jumperNode != nil){
                    let animation = SKAction.animate(with: jumperRunning, timePerFrame:0.1)
                    jumperNode?.run(animation)
                    let groundAnimation = SKAction.animate(with: jumperGround, timePerFrame:0.4)
                    ground.run(groundAnimation)
                    
                }
            }
        }
    }
    
    func initJumperScene() {
        background = SKSpriteNode(imageNamed: "rainforest")
        background.size = self.size
        print(self.size)
        background.position = CGPoint(x: 0, y: 0)
        background.zPosition = 0
        background.name = "backgroundNode"
        self.addChild(background)
        
        ground = SKSpriteNode(imageNamed: "ground-init")
        ground.size.width = self.size.width
        ground.size.height = self.size.height/10
        ground.position = CGPoint(x: 0, y: -self.size.height/2 + 15)
        ground.zPosition = 1
        ground.name = "groundNode"
        self.addChild(ground)
        
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
    }
    
    func grabAtlas(dataAtlas: SKTextureAtlas, label: String) -> [SKTexture]{
        var atlas = [SKTexture]()
        print(dataAtlas.textureNames.count)
        for index in 1...dataAtlas.textureNames.count{
            let path = "frame-" + label + "-%01d"
            let imgName = String(format: path, index)
            atlas += [dataAtlas.textureNamed(imgName)]
        }
        return atlas
    }
    
}
