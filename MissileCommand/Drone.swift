import Foundation
import SpriteKit

class Drone:SKNode {
    
    var droneNode:SKSpriteNode = SKSpriteNode()
    var droneAnimation:SKAction?
    
    var array = [String]()
    var atlasTextures:[SKTexture] = []
    
    //createEnemyMissile
    func createDrone() {
        
        droneNode = SKSpriteNode(imageNamed: "drone1")
        
        self.addChild(droneNode)
        self.name = "drone"
        
        setupAnimation()
    }
    
    
    func setupAnimation() {
        let atlas = SKTextureAtlas(named: "drone.atlas")
        
        for var i = 0; i < 21; i++ {
            let nameString = String(format: "drone%i", i)
            array.append(nameString)
        }
        
        for var n = 0; n < array.count - 1; n++ {
            let texture:SKTexture = atlas.textureNamed(array[n])
            atlasTextures.insert(texture, atIndex: n)
        }
        
        let atlasAnimation = SKAction.animateWithTextures(atlasTextures, timePerFrame: 1.0/20, resize: true, restore: true)
        droneAnimation = SKAction.repeatActionForever(atlasAnimation)
        droneNode.runAction(droneAnimation!, withKey: "animation")
    }
    
}

