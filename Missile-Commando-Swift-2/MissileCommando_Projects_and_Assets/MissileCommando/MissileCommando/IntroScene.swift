//
//  IntroScene.swift
//  MissileCommando
//
//  Created by Justin Dike on 7/1/15.
//  Copyright (c) 2015 CartoonSmart. All rights reserved.
//

import Foundation
import SpriteKit

class IntroScene: SKScene {
    
    var isPhone:Bool = true
    var screenWidth:CGFloat = 0
    var screenHeight:CGFloat = 0
    let instructionLabel:SKLabelNode = SKLabelNode(fontNamed: "BM germar")
    var introImage:SKSpriteNode?
    
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        
        if (UIDevice.currentDevice().userInterfaceIdiom == .Pad) {
            
            isPhone = false
            
        } else {
            
            isPhone = true
        }
        
        
        screenWidth = self.view!.bounds.width
        screenHeight  = self.view!.bounds.height
        
        println(screenWidth)
        println(screenHeight)
        
        self.backgroundColor = SKColor.blackColor()
        self.anchorPoint = CGPointMake(0.5, 0.0)
        
        let tex:SKTexture = SKTexture(imageNamed: "intro_screen")
        let theSize:CGSize = CGSizeMake(screenWidth, screenHeight)
        
        introImage = SKSpriteNode(texture: tex, color: SKColor.clearColor(), size: theSize)
        
        addChild(introImage!)
        introImage!.position = CGPointMake(0, screenHeight / 2)
        
        
        createInstructionLabel()
        
    }
    
    
    func createInstructionLabel() {
        
        
        instructionLabel.horizontalAlignmentMode = .Center
        instructionLabel.verticalAlignmentMode = .Center
        instructionLabel.fontColor = SKColor.whiteColor()
        instructionLabel.text = "Touch to Begin Game"
        instructionLabel.zPosition = 1
        addChild(instructionLabel)
        
        if ( isPhone == true) {
            
            instructionLabel.position = CGPointMake(0, screenHeight * 0.15)
            instructionLabel.fontSize = 30
            
        } else {
            
            instructionLabel.position = CGPointMake(0, screenHeight * 0.20)
            instructionLabel.fontSize = 40
            
        }
        
        // Lets introduce SKActions
        
        let wait:SKAction = SKAction.waitForDuration(1)
        let fadeDown:SKAction = SKAction.fadeAlphaTo(0, duration: 0.2)
        let fadeUp:SKAction = SKAction.fadeAlphaTo(1, duration: 0.2)
        let seq:SKAction = SKAction.sequence( [wait, fadeDown, fadeUp] )
        let repeat:SKAction = SKAction.repeatActionForever(seq)
        instructionLabel.runAction(repeat)
        
    }
    
    
    
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        /* Called when a touch begins */
       
        let transition = SKTransition.revealWithDirection(SKTransitionDirection.Down, duration: 1.0)
        let scene = GameScene(size: self.scene!.size)
        scene.scaleMode = SKSceneScaleMode.AspectFill
        
        self.scene!.view!.presentScene(scene, transition: transition)
    
        
        
        /*
        let fadeDown:SKAction = SKAction.fadeAlphaTo(0, duration: 0.2)
        let remove:SKAction = SKAction.removeFromParent()
        let seq:SKAction = SKAction.sequence( [fadeDown, remove] )
        
        instructionLabel.runAction(seq)
        introImage!.runAction(seq)
        */
        
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
    
}

