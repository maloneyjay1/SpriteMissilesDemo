//
//  Base.swift
//  Missile_Commando
//
//  Created by Justin Dike on 6/26/15.
//  Copyright (c) 2015 CartoonSmart. All rights reserved.
//

import Foundation
import SpriteKit



class Base: SKSpriteNode {
    
    var hitCount:Int = 1
    var maxDamage:Int = 4
    
    
    var baseName:String = ""
    
    var alreadyDestroyed:Bool = false

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    init (imageNamed:String) {
        
        
        baseName = imageNamed
        
        let imageTexture = SKTexture(imageNamed: baseName + String(hitCount))
        super.init(texture: imageTexture, color:SKColor.clearColor(), size: imageTexture.size() )
        
        let body:SKPhysicsBody = SKPhysicsBody(circleOfRadius: imageTexture.size().width / 2.25, center:CGPointMake(0, 0))
        body.dynamic = false
        body.affectedByGravity = false
        body.allowsRotation = false
      
        body.categoryBitMask = BodyType.base.rawValue
        body.contactTestBitMask = BodyType.enemyMissile.rawValue | BodyType.bullet.rawValue | BodyType.enemyBomb.rawValue
        body.collisionBitMask = BodyType.enemyMissile.rawValue
        self.physicsBody = body
        self.name = "base"
      
    }
    
    
    func hit(damageAmount:Int){
        
        
        hitCount = hitCount + damageAmount
        
        if ( hitCount <= (maxDamage - 1) ) {
        
             self.texture = SKTexture(imageNamed: baseName + String(hitCount))
            
            switch (hitCount) {
            
                case 1:
                
                 addParticles(5)
                case 2:
                
                addParticles(10)
                case 3:
                
                addParticles(15)
            
            
                default:
                break
            
            }
        
        } else if ( hitCount >= maxDamage && alreadyDestroyed == false ) {
            
            self.texture = SKTexture(imageNamed: baseName + String(maxDamage))
            addParticles(40)
            
            alreadyDestroyed = true
            
        } else {
            
            print("already destroyed")
        }
        
        
        
        
        
    }
    
    
    func addParticles(num:Int){
        
        
        
        let glassEmitter = SKEmitterNode(fileNamed: "Glass")
        
        
        glassEmitter!.name = "Glass"
        glassEmitter!.zPosition = -1
        glassEmitter!.targetNode = self
        glassEmitter!.numParticlesToEmit = num
        glassEmitter!.position = CGPointMake(0, 25)
        
        self.addChild(glassEmitter!)
        
        
    }
   
    
    func revive(){
        
        alreadyDestroyed = false
        hitCount = 1
        self.texture = SKTexture(imageNamed: baseName + String(hitCount))
        
        
    }

    
}

