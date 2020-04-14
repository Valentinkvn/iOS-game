import UIKit
import SpriteKit

class JumperScene: SKScene {
    
    var jumperAnimation = [SKTexture]()
    override func didMove(to view: SKView) {
        self.initJumperScene()
    }
    
    func initJumperScene() {
        let background = SKSpriteNode(imageNamed: "rainforest")
        background.size = self.size
        print(self.size)
        background.position = CGPoint(x: 0, y: 0)
        background.zPosition = 0
        background.name = "backgroundNode"
        self.addChild(background)
        
        let ground = SKSpriteNode(imageNamed: "ground")
        ground.size.width = self.size.width
        ground.size.height = self.size.height/10
        ground.position = CGPoint(x: 0, y: -self.size.height/2 + 15)
        ground.zPosition = 1
        ground.name = "groundNode"
        self.addChild(ground)
        
        let jumperAtlas = SKTextureAtlas(named: "running")
        print(jumperAtlas.textureNames.count)
        
        for index in 1...jumperAtlas.textureNames.count{
            let imgName = String(format: "frame-running-%01d", index)
            jumperAnimation += [jumperAtlas.textureNamed(imgName)]
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let jumperNode = self.childNode(withName: "jumperNode")
        
        for touch: AnyObject in touches{
            let pointOfTouch = touch.location(in: self)
            if(pointOfTouch.x > 0) {
                if (jumperNode != nil){
                    let animation = SKAction.animate(with: jumperAnimation, timePerFrame:0.1)
                    jumperNode?.run(animation)
                }
            }
        }
        
    }
    
    
}
