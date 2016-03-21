//
//  EnemyMissile.swift
//  Missile_Commando
//
//  Created by Justin Dike on 6/26/15.
//  Copyright (c) 2015 CartoonSmart. All rights reserved.
//

import Foundation
import SpriteKit

class EnemyMissile: SKNode {
    
     let fireEmitter = SKEmitterNode(fileNamed: "FireParticles")
    var missileNode:SKSpriteNode = SKSpriteNode()
    var imageName:String = ""
    
    var hitsToKill:Int = 2
    var hitCount:Int = 0
    var damagePoints:Int = 4
    
    
    var missileAnimation:SKAction?
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override init () {
        
        super.init()
        
        
    }
    
    func createMissile(theImage:String) {
        
        
        
        missileNode = SKSpriteNode(imageNamed: theImage)
        self.addChild(missileNode)
        
        let body:SKPhysicsBody = SKPhysicsBody(circleOfRadius: missileNode.size.width / 2.25, center:CGPointMake(0, 0))
        body.dynamic = true
        body.affectedByGravity = true
        body.allowsRotation = false
        
        
        body.categoryBitMask = BodyType.enemyMissile.rawValue
        body.contactTestBitMask = BodyType.ground.rawValue | BodyType.bullet.rawValue  | BodyType.base.rawValue | BodyType.playerBase.rawValue
        
        self.physicsBody = body
        
        self.name = "enemyMissile"
        
        addParticles()
        setUpAnimation()
       
        
    }
    
    func setUpAnimation() {
        
        //let atlas = SKTextureAtlas (named: "enemyMissile")  // patch for a bug with Xcode 7
        
        var array = [String]()
        
        //or setup an array with exactly the sequential frames start from 1
        for var i=1; i <= 10; i++ {
            
            let nameString = String(format: "enemyMissile%i", i)
            
            array.append(nameString)
            
        }
        
        //create another array this time with SKTexture as the type (textures being the .png images)
        var atlasTextures:[SKTexture] = []
        
        for (var i = 0; i < array.count; i++ ) {
            
            let texture:SKTexture = SKTexture(imageNamed: array[i])
           // let texture:SKTexture = atlas.textureNamed( array[i] ) //patch for a bug with Xcode 7
            atlasTextures.insert(texture, atIndex:i)
            
        }
        
        let atlasAnimation = SKAction.animateWithTextures(atlasTextures, timePerFrame: 1.0/20, resize: true , restore:false )
        missileAnimation =  SKAction.repeatActionForever(atlasAnimation)
        
        missileNode.runAction(missileAnimation!, withKey:"animation")
        
        
    }
    
    
    
    
   
    
    func addParticles(){
        
        
    
        fireEmitter!.name = "fireEmitter"
        fireEmitter!.zPosition = -1
        fireEmitter!.targetNode = self
       
        fireEmitter!.particleLifetime = 10
  
        self.addChild(fireEmitter!)
        
        
    }
    
   
    
    
    func hit() ->Bool {
        
        hitCount++
        
        if ( hitCount == hitsToKill) {
            
            self.removeFromParent()
            return true
            
        } else {
            damagePoints = 1
            
            fireEmitter!.numParticlesToEmit = 10
            
            missileNode.removeActionForKey("animation")
            return false
        }
        
        
    }
    func destroy(){
        
       
            
            self.name = "removeNode"
       
        
        
    }
    
    
    
    
}