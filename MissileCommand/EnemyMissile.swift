//
//  EnemyMissile.swift
//  MissileCommand
//
//  Created by Jay Maloney on 3/21/16.
//  Copyright © 2016 Jay Maloney. All rights reserved.
//

import Foundation
import SpriteKit

class EnemyMissile:SKNode {
    
    var missileNode:SKSpriteNode = SKSpriteNode()
    var missileAnimation:SKAction?
    
    let fireEmitter = SKEmitterNode(fileNamed: "FireParticle")
    
    var array = [String]()
    var atlasTextures:[SKTexture] = []
    
    var hitsToKill:Int = 1
    var damageCount:Int = 1
    var hitCount:Int = 0
    
    //createEnemyMissile
    func createEnemyMissile(image:String) {
        
        missileNode = SKSpriteNode(imageNamed: image)
        self.addChild(missileNode)
        
        let body:SKPhysicsBody = SKPhysicsBody(circleOfRadius: missileNode.size.width / 2.25, center: CGPointMake(0.0, 0.0))
        
        body.dynamic = true
        body.affectedByGravity = true
        body.allowsRotation = false
        body.categoryBitMask = BodyType.enemyMissile.rawValue
        body.contactTestBitMask = BodyType.base.rawValue | BodyType.bullet.rawValue | BodyType.playerbase.rawValue | BodyType.ground.rawValue
        
        self.physicsBody = body
        self.name = "enemyMissile"
        
        setupAnimation()
        setupFireParticles()
    }
    
    
    func setupAnimation() {
        let atlas = SKTextureAtlas(named: "enemyMissile.atlas")
        
        for i in 0 ..< 10 {
            let nameString = String(format: "enemymissile%i", i)
            array.append(nameString)
        }

        for n in 0 ..< array.count {
            let texture:SKTexture = atlas.textureNamed(array[n])
            atlasTextures.insert(texture, atIndex: n)
        }
        
        let atlasAnimation = SKAction.animateWithTextures(atlasTextures, timePerFrame: 1.0/15, resize: true, restore: true)
        missileAnimation = SKAction.repeatActionForever(atlasAnimation)
        missileNode.runAction(missileAnimation!, withKey: "animation")
    }
    
    
    func setupFireParticles() {
        fireEmitter!.name = "fireEmitter"
        fireEmitter!.zPosition = -1
        fireEmitter!.targetNode = self
        fireEmitter!.particleLifetime = 20
        fireEmitter!.numParticlesToEmit = 50
        self.addChild(fireEmitter!)
    }
    
    
    
    //hit
    func hit() -> Bool {
        hitCount += 1
        if hitCount == hitsToKill {
            destroy()
            return true
        } else {
            damageCount = 1
            fireEmitter!.numParticlesToEmit = 10
            missileNode.removeActionForKey("animation")
            return false
        }
    }
    
    
    
    //destroy
    func destroy() {
        self.removeFromParent()
    }
    
}

