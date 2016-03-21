//
//  EnemyMissile.swift
//  MissileCommando
//
//  Created by Justin Dike on 7/3/15.
//  Copyright (c) 2015 CartoonSmart. All rights reserved.
//

import Foundation
import SpriteKit


class EnemyMissile: SKNode {
    
    
    var missileNode:SKSpriteNode = SKSpriteNode()
    var missileAnimation:SKAction?
    
    let fireEmitter = SKEmitterNode(fileNamed: "FireParticles")
    
    
    var hitsToKill:Int = 2
    var hitCount:Int = 0
    var damagePoints:Int = 4
    
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override init () {
        
        super.init()
        
        
    }
    
    func createMissile( theImage:String) {
        
        missileNode = SKSpriteNode(imageNamed: theImage)
        self.addChild(missileNode)
        
        var body:SKPhysicsBody = SKPhysicsBody(circleOfRadius: missileNode.size.width / 2.25, center:CGPointMake(0, 0))
        body.dynamic = true
        body.affectedByGravity = true
        body.allowsRotation = false
        
        body.categoryBitMask = BodyType.enemyMissile.rawValue
        body.contactTestBitMask = BodyType.ground.rawValue | BodyType.bullet.rawValue | BodyType.base.rawValue | BodyType.playerBase.rawValue
        
        
        self.physicsBody = body
        
        self.name = "enemyMissile"
        
        
        setUpAnimation()
        addParticles()
        
        
    }
    
    
    func setUpAnimation() {
        
        let atlas = SKTextureAtlas(named: "enemyMissile")
        
        var array = [String]()
        
        for (var i=1; i <= 10; i++) {
            
            let nameString = String (format:"enemyMissile%i"  , i)
            array.append(nameString)
            
        }
        
        
        var atlasTextures:[SKTexture] = []
        
        for (var i=0; i < array.count; i++ ) {
            
            let texture:SKTexture = atlas.textureNamed( array[i] )
            atlasTextures.insert(texture, atIndex:i)
            
        }
        
        let atlasAnimation = SKAction.animateWithTextures(atlasTextures, timePerFrame: 1.0/20, resize: true, restore: false)
        missileAnimation = SKAction.repeatActionForever(atlasAnimation)
        
        missileNode.runAction(missileAnimation!, withKey:"animation")
        
        
        
        
    }
    
    func addParticles(){
    
        fireEmitter!.name = "fireEmitter"
        fireEmitter!.zPosition = -1
        fireEmitter!.targetNode = self
        fireEmitter!.particleLifetime = 10
        //fireEmitter!.numParticlesToEmit = 200
    
        self.addChild(fireEmitter!)
    
    }
    
    func hit() -> Bool {
        
        hitCount++
        
        if ( hitCount == hitsToKill) {
            
            destroy()
            return true
            
            
        } else {
            
            damagePoints = 1
            fireEmitter!.numParticlesToEmit = 10
            missileNode.removeActionForKey("animation")
            
            return false
        }
        
        
        
    }
    
    
    func destroy() {
        
        //self.removeFromParent()
        self.name = "removeNode"
        
        
    }
    
    
    
    
}





