import Foundation
import SpriteKit

class Drone:SKNode {
    
    var droneNode:SKSpriteNode = SKSpriteNode()
    var droneAnimation:SKAction?
    
    var array = [String]()
    var atlasTextures:[SKTexture] = []
    
    //createEnemyMissile
    func createDrone() {
        
        droneNode = SKSpriteNode(imageNamed: "trump1")
        
        self.addChild(droneNode)
        self.name = "drone"
        
        setupAnimation()
    }
    
    
    func setupAnimation() {
        let atlas = SKTextureAtlas(named: "trump.atlas")
        
        for i in 0 ..< 20 {
            let nameString = String(format: "trump%i", i)
            array.append(nameString)
            print(array.count)
        }
    
        for n in 0 ..< array.count {
            let texture:SKTexture = atlas.textureNamed(array[n])
            atlasTextures.insert(texture, atIndex: n)
            print(atlasTextures.count)
        }
        
        let atlasAnimation = SKAction.animateWithTextures(atlasTextures, timePerFrame: 1.0/15, resize: true, restore: true)
        droneAnimation = SKAction.repeatActionForever(atlasAnimation)
        droneNode.runAction(droneAnimation!, withKey: "animation")
    }
}

