//
//  Base.swift
//  MissileCommand
//
//  Created by Jay Maloney on 3/22/16.
//  Copyright © 2016 Jay Maloney. All rights reserved.
//

import Foundation
import SpriteKit

class Base:SKSpriteNode {
    
    var baseName = "base"
    var hitCount: Int = 1
    var isPhone:Bool = true
    var alreadyDestroyed:Bool = false
    var maxDamage:Int = 4
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(imageNamed:String) {
        
        if (UIDevice.currentDevice().userInterfaceIdiom == .Pad) {
            isPhone = false
        } else {
            isPhone = true
        }
        
        baseName = imageNamed
        let texture = SKTexture(imageNamed: baseName + String(hitCount) )
        let smallSize = CGSizeMake(texture.size().width / 2, texture.size().height / 2)
        
        if isPhone == true {
            super.init(texture: texture, color: SKColor.clearColor(), size: smallSize)
        } else {
            super.init(texture: texture, color: SKColor.clearColor(), size: texture.size())
        }
        
        let body:SKPhysicsBody = SKPhysicsBody(circleOfRadius: texture.size().width / 2, center: CGPointMake(0, 15))
        body.categoryBitMask = BodyType.base.rawValue
        body.contactTestBitMask = BodyType.enemyMissile.rawValue | BodyType.enemyBomb.rawValue | BodyType.bullet.rawValue
        body.collisionBitMask = BodyType.enemyMissile.rawValue | BodyType.enemyBomb.rawValue
        body.dynamic = false
        body.affectedByGravity = false
        body.allowsRotation = false
        self.physicsBody = body
        self.name = "base"
    }
    
    
    //MARK: hit
    func hit(damageAmount:Int) {
        
        hitCount += damageAmount
        
        if hitCount <= maxDamage - 1 {
            self.texture = SKTexture(imageNamed: baseName + "\(hitCount)")
            
            switch(hitCount) {
            case 2:
                addParticles(5)
            case 3:
                addParticles(10)
            default:
                addParticles(15)
                break
            }
    
        } else if hitCount >= maxDamage && alreadyDestroyed == false {
            self.texture = SKTexture(imageNamed: baseName + "\(maxDamage)")
            alreadyDestroyed = true
            addParticles(40)
        }
    }
    
    
    //MARK: revive base
    func revive() {
        hitCount = 1
        alreadyDestroyed = false
        self.texture = SKTexture(imageNamed: baseName + "\(hitCount)")
    }
    
    
    
    //MARK: add glass
    func addParticles(num:Int) {
        let emitter:SKEmitterNode = SKEmitterNode(fileNamed: "Glass")!
        
        emitter.name = "glass"
        emitter.zPosition = -1
        emitter.targetNode = self
        emitter.numParticlesToEmit = num
        emitter.position = CGPointMake(0.0, 25)
        self.addChild(emitter)
    }
    
}
