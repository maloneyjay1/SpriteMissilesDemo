//
//  IntroScene.swift
//  MissileCommand
//
//  Created by Jay Maloney on 3/15/16.
//  Copyright © 2016 Jay Maloney. All rights reserved.
//

import SpriteKit

class IntroScene: SKScene {
    
    var isPhone:Bool = true
    
    var screenWidth:CGFloat = 0
    var screenHeight:CGFloat = 0
    
    var introScreenImage:SKSpriteNode?
    var instructLabel:SKLabelNode?
    
    var backgroundMusic:SKAudioNode?
    
    override func didMoveToView(view: SKView) {
        
        if (UIDevice.currentDevice().userInterfaceIdiom == .Pad) {
            isPhone = false
        } else {
            isPhone = true
        }
        
        screenWidth = (self.view?.bounds.width)!
        screenHeight = (self.view?.bounds.height)!
        
        self.backgroundColor = SKColor.blackColor()
        self.anchorPoint = CGPointMake(0.5, 0.0)
        
//        let introScreenTexture:SKTexture = SKTexture(imageNamed: "intro_screen")
//        let introTextSize:CGSize = CGSizeMake(screenWidth, screenHeight)
//        introScreenImage = SKSpriteNode(texture: introScreenTexture, color: UIColor.clearColor(), size: introTextSize)
        if let introScreenImage = introScreenImage {
            introScreenImage.position = CGPointMake(0, screenHeight / 2)
            addChild(introScreenImage)
        }
        
        createInstructionLabel()
        
        GameScene.sharedInstance.playBackgroundSoundWav("epicMusic")
    }
    
    func createInstructionLabel() {
        
        instructLabel = SKLabelNode(fontNamed: "BM germar")
        if let instructLabel = instructLabel {
            
            instructLabel.horizontalAlignmentMode = .Center
            instructLabel.verticalAlignmentMode = .Center
            instructLabel.fontColor = SKColor.whiteColor()
            instructLabel.text = "Tap to Start!"
            instructLabel.zPosition = 1
            addChild(instructLabel)
            
            if isPhone == true {
                instructLabel.position = CGPointMake(0, screenHeight * 0.2)
                instructLabel.fontSize = 20
            } else {
                instructLabel.position = CGPointMake(0, screenHeight * 0.2)
                instructLabel.fontSize = 40
            }
            
            let wait:SKAction = SKAction.waitForDuration(0.75)
            let fadeDown:SKAction = SKAction.fadeAlphaTo(0, duration: 0.2)
            let fadeUp:SKAction = SKAction.fadeAlphaTo(1, duration: 0.4)
            let seq:SKAction = SKAction.sequence([wait, fadeDown, fadeUp])
            let seqRepeat:SKAction = SKAction.repeatActionForever(seq)
            
            instructLabel.runAction(seqRepeat)
        }
    }
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        let transition = SKTransition.revealWithDirection(SKTransitionDirection.Down, duration: 0.75)
        let scene = GameScene(size: self.scene!.size)
        scene.scaleMode = SKSceneScaleMode.AspectFill
        
        self.scene!.view!.presentScene(scene, transition: transition)
        
//        let fadeDown:SKAction = SKAction.fadeAlphaTo(0, duration: 0.70)
//        let removeObject:SKAction = SKAction.removeFromParent()
//        let touchSeq:SKAction = SKAction.sequence([fadeDown, removeObject])
//        
//        if let instructLabel = instructLabel {
//            instructLabel.runAction(touchSeq)
//        }
//        if let introScreenImage = introScreenImage {
//            introScreenImage.runAction(touchSeq)
//        }
        
        
    }
}

