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
        
        for var i = 0; i < 11; i++ {
            let nameString = String(format: "enemymissile%i", i)
            array.append(nameString)
        }

        for var n = 0; n < array.count - 1; n++ {
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
        fireEmitter!.particleLifetime = 10
//        fireEmitter!.numParticlesToEmit = 200
        
        self.addChild(fireEmitter!)
    }
    
}

