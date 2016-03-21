
import Foundation
import SpriteKit


class Drone: SKNode {
    
    
    var droneNode:SKSpriteNode = SKSpriteNode()
    var droneAnimation:SKAction?
    
    
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override init () {
        
        super.init()
        
        
    }
    
    func createDrone() {
        
        droneNode = SKSpriteNode(imageNamed:"drone1")
        self.addChild(droneNode)
        
 
        
        self.name = "drone"
        
        
        setUpAnimation()
   
        
        
    }
    
    
    func setUpAnimation() {
        
        let atlas = SKTextureAtlas(named: "drone")
        
        var array = [String]()
        
        for (var i=1; i <= 20; i++) {
            
            let nameString = String (format:"drone%i"  , i)
            array.append(nameString)
            
        }
        
        
        var atlasTextures:[SKTexture] = []
        
        for (var i=0; i < array.count; i++ ) {
            
            let texture:SKTexture = atlas.textureNamed( array[i] )
            atlasTextures.insert(texture, atIndex:i)
            
        }
        
        let atlasAnimation = SKAction.animateWithTextures(atlasTextures, timePerFrame: 1.0/30, resize: true, restore: false)
        droneAnimation = SKAction.repeatActionForever(atlasAnimation)
        
        droneNode.runAction(droneAnimation!, withKey:"animation")
        
        
        
        
    }
    
   
    
    
    
    
}