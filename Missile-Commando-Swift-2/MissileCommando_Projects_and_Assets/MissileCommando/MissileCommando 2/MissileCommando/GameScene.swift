//
//  GameScene.swift
//  MissileCommando
//
//  Created by Justin Dike on 7/1/15.
//  Copyright (c) 2015 CartoonSmart. All rights reserved.
//

import SpriteKit
import AVFoundation

enum BodyType:UInt32 {
    
    case playerBase = 1
    case base = 2
    case bullet = 4
    case enemyMissile = 8
    case enemy = 16
    case ground = 32
    case enemyBomb = 64
    
}




class GameScene: SKScene {
    
    var isPhone:Bool = true
    var screenWidth:CGFloat = 0
    var screenHeight:CGFloat = 0
    let instructionLabel:SKLabelNode = SKLabelNode(fontNamed: "BM germar")
 
    let playerBase:SKSpriteNode = SKSpriteNode(imageNamed: "playerBase")
    let turret:SKSpriteNode = SKSpriteNode(imageNamed: "turret")
    let target:SKSpriteNode = SKSpriteNode(imageNamed: "target")
    var ground:SKSpriteNode = SKSpriteNode()
    
    let loopingBG:SKSpriteNode = SKSpriteNode(imageNamed: "stars")
    let loopingBG2:SKSpriteNode = SKSpriteNode(imageNamed: "stars")
    let moon:SKSpriteNode = SKSpriteNode(imageNamed: "moon")
    
    let length:CGFloat = 200
    var theRotation:CGFloat = 0
    var offset:CGFloat = 0
    
    let rotateRec = UIRotationGestureRecognizer()
    let tapRec = UITapGestureRecognizer()
    
    var bgSoundPlayer:AVAudioPlayer?
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        
        if (UIDevice.currentDevice().userInterfaceIdiom == .Pad) {
            
            isPhone = false
            
        } else {
            
            isPhone = true
        }
        
        physicsWorld.gravity = CGVector(dx: 0, dy:-0.1)
        
        
        screenWidth = self.view!.bounds.width
        screenHeight  = self.view!.bounds.height
        
        rotateRec.addTarget(self, action: "rotatedView:")
        self.view!.addGestureRecognizer(rotateRec)
        
        tapRec.addTarget(self, action: "tappedView")
        tapRec.numberOfTouchesRequired = 1
        tapRec.numberOfTapsRequired = 1
        self.view!.addGestureRecognizer(tapRec)
        
        
        self.backgroundColor = SKColor.blackColor()
        self.anchorPoint = CGPointMake(0.5, 0.0)
        
        createGround()
        addPlayer()
        
        setUpBackground()
        
        createInstructionLabel()
        
        playBackgroundSound("levelsound")
    }
    
    
    func setUpBackground() {
        
        addChild(moon)
        addChild(loopingBG)
        addChild(loopingBG2)
        
        
        moon.zPosition = -199
        loopingBG.zPosition = -200
        loopingBG2.zPosition = -200
        
        loopingBG.position = CGPointMake(0, loopingBG.size.height / 2 )
        loopingBG2.position = CGPointMake(loopingBG2.size.width, loopingBG.size.height / 2 )
        moon.position = CGPointMake((screenWidth / 2) + moon.size.width, screenHeight / 2)
        
        startLoopingBackground()
        
    }
    
    
    func startLoopingBackground(){
        
        let move:SKAction = SKAction.moveByX(-loopingBG.size.width, y:0, duration:80)
        let moveBack:SKAction = SKAction.moveByX(loopingBG.size.width, y:0, duration:0)
        let seq:SKAction = SKAction.sequence([move, moveBack])
        let repeat:SKAction = SKAction.repeatActionForever(seq)
        
        loopingBG.runAction(repeat)
        loopingBG2.runAction(repeat)
        
        
        let moveMoon:SKAction = SKAction.moveByX(-screenWidth * 1.3, y:0, duration:60)
        let moveMoonBack:SKAction = SKAction.moveByX(screenWidth * 1.3, y:0, duration:0)
        let wait:SKAction = SKAction.waitForDuration(20)
        let seqMoon:SKAction = SKAction.sequence([moveMoon, wait, moveMoonBack])
        let repeatMoon:SKAction = SKAction.repeatActionForever(seqMoon)
        
        moon.runAction(repeatMoon)
        
        
    }
    
    
    
    func createGround(){
        
        let theSize:CGSize = CGSizeMake(screenWidth, 70)
        let tex:SKTexture = SKTexture(imageNamed: "rocky_ground")
        ground = SKSpriteNode(texture: tex, color: SKColor.clearColor(), size:theSize)
        ground.physicsBody = SKPhysicsBody(rectangleOfSize: theSize)
        ground.physicsBody!.categoryBitMask = BodyType.ground.rawValue
        ground.physicsBody!.contactTestBitMask = BodyType.enemyMissile.rawValue | BodyType.enemyBomb.rawValue
        
        ground.physicsBody!.dynamic = false
        
        addChild(ground)
        
        if ( isPhone == true) {
            
            ground.position = CGPointMake(0, 0)
            
        } else {
            
            ground.position = CGPointMake(0, theSize.height / 2)
            
            
        }
        
        ground.zPosition = 500
        
    }
    
    
    func addPlayer(){
        
        
        addChild(playerBase)
        playerBase.zPosition = 100
        playerBase.position = CGPointMake(0, ground.position.y + (playerBase.size.height / 2) )
        playerBase.physicsBody = SKPhysicsBody(circleOfRadius: playerBase.size.width / 2)
        playerBase.physicsBody!.categoryBitMask = BodyType.playerBase.rawValue
        playerBase.physicsBody!.dynamic = false
        
        
        addChild(turret)
        turret.zPosition = 99
        turret.anchorPoint = CGPointMake(0.5, 0.0)
        turret.position = CGPointMake(0, playerBase.position.y)
        
        
        addChild(target)
        target.zPosition = 98
        target.position = CGPointMake(turret.position.x, turret.position.y + length)
        
        
        
        
    }
    
    
    func rotatedView(sender:UIRotationGestureRecognizer) {
        
        
        if ( sender.state == .Changed) {
            
            theRotation = CGFloat( -sender.rotation ) + offset
            
            let maxRotation:CGFloat = 1.4
            
            if (theRotation < -maxRotation) {
                
                theRotation = -maxRotation
            } else if (theRotation > maxRotation) {
                
                theRotation = maxRotation
                
            }
            
            
            turret.zRotation = theRotation
            target.zRotation = theRotation
            
            let xDist:CGFloat = sin(theRotation) * length
            let yDist:CGFloat = cos(theRotation) * length
            
            target.position = CGPointMake( turret.position.x - xDist, turret.position.y + yDist)
            
            
            
        }
        
        if ( sender.state == .Ended) {
            
            offset = theRotation
                        
        }

    }
    
    func tappedView() {
        
        
        createBullet()
        
        rattle(playerBase)
        rattle(turret)
        
        playSound("gun1.caf")
        
    }
    
    func rattle(node:SKSpriteNode) {
        
        let rattleUp:SKAction = SKAction.moveByX(0, y:5, duration: 0.05)
        let rattleDown:SKAction = SKAction.moveByX(0, y:-5, duration: 0.05)
        let seq:SKAction = SKAction.sequence( [ rattleUp, rattleDown  ])
        let repeat:SKAction = SKAction.repeatAction(seq, count: 3)
        
        node.runAction(repeat)
        
    }
    
    
    func createBullet() {
        
        let bullet:SKSpriteNode = SKSpriteNode(imageNamed: "bullet")
        bullet.physicsBody = SKPhysicsBody(circleOfRadius:  bullet.size.width / 3)
        bullet.physicsBody!.categoryBitMask = BodyType.bullet.rawValue
        bullet.zRotation = theRotation
        bullet.name = "bullet"
        
        let xDist:CGFloat = sin(theRotation) * 70
        let yDist:CGFloat = cos(theRotation) * 70
        
        bullet.position = CGPointMake( turret.position.x - xDist, turret.position.y + yDist)
        
        addChild(bullet)
        
        
        
        let forceXDist:CGFloat = sin(theRotation) * 250
        let forceYDist:CGFloat = cos(theRotation) * 250
        
        let theForce:CGVector = CGVectorMake(turret.position.x - forceXDist, turret.position.y + forceYDist)
        
        bullet.physicsBody!.applyForce(theForce)
    
        createFiringParticles( bullet.position, force:theForce)
        
    }
    
    
    func createFiringParticles(location:CGPoint, force:CGVector){
        
        let fireEmitter = SKEmitterNode(fileNamed: "FireParticles")
        fireEmitter.position = location
        fireEmitter.numParticlesToEmit = 50
        fireEmitter.zPosition = 1
        fireEmitter.targetNode = self
        
        fireEmitter.xAcceleration = force.dx
        fireEmitter.yAcceleration = force.dy
        
        self.addChild(fireEmitter)
        
    }
    
   
    func createInstructionLabel() {
        
        
        instructionLabel.horizontalAlignmentMode = .Center
        instructionLabel.verticalAlignmentMode = .Center
        instructionLabel.fontColor = SKColor.whiteColor()
        instructionLabel.text = "Rotate Fingers to Swivel Turret"
        instructionLabel.zPosition = 1
        addChild(instructionLabel)
       
        if ( isPhone == true) {
            
            instructionLabel.position = CGPointMake(0, screenHeight / 2)
            instructionLabel.fontSize = 30
            
        } else {
            
            instructionLabel.position = CGPointMake(0, screenHeight / 2)
            instructionLabel.fontSize = 40
            
        }
        
        // Lets introduce SKActions
        
        let wait:SKAction = SKAction.waitForDuration(0.6)
        let fadeDown:SKAction = SKAction.fadeAlphaTo(0, duration: 0.2)
        let fadeUp:SKAction = SKAction.fadeAlphaTo(1, duration: 0.2)
        let seq:SKAction = SKAction.sequence( [wait, fadeDown, fadeUp] )
        let repeat:SKAction = SKAction.repeatAction(seq, count: 3)
        let remove:SKAction = SKAction.removeFromParent()
        let seq2:SKAction = SKAction.sequence( [repeat, wait, remove] )
        instructionLabel.runAction(seq2)
        
    
    }
    
    

    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        /* Called when a touch begins */
        
       
       
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
    
    
    func playBackgroundSound(name:String) {
        
        
        if (bgSoundPlayer != nil) {
            
            bgSoundPlayer!.stop()
            bgSoundPlayer = nil
            
        }
        
        let fileURL:NSURL = NSBundle.mainBundle().URLForResource(name, withExtension: "mp3")!
        
        bgSoundPlayer = AVAudioPlayer(contentsOfURL: fileURL, error: nil)
        
        bgSoundPlayer!.volume = 0.25 //half volume
        bgSoundPlayer!.numberOfLoops = -1
        bgSoundPlayer!.prepareToPlay()
        bgSoundPlayer!.play()
        
        
    }
    
    func playSound(name:String){
        
        
        let theSound:SKAction = SKAction.playSoundFileNamed(name, waitForCompletion: false)
        self.runAction(theSound)
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
}
