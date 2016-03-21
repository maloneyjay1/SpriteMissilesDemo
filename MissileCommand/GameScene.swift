//
//  GameScene.swift
//  MissileCommand
//
//  Created by Jay Maloney on 3/14/16.
//  Copyright (c) 2016 Jay Maloney. All rights reserved.
//

import SpriteKit
import AVFoundation


enum BodyType:UInt32 {
    case playerbase = 1
    case base = 2
    case bullet = 4
    case enemyMissile = 8
    case enemy = 16
    case ground = 32
    case enemyBomb = 64
}

class GameScene: SKScene {
    
    static let sharedInstance = GameScene()
    
    var isPhone:Bool = true
    var screenWidth:CGFloat = 0
    var screenHeight:CGFloat = 0
    var instructLabel:SKLabelNode?
    
    let playerBase:SKSpriteNode = SKSpriteNode(imageNamed: "playerBase")
    let target:SKSpriteNode = SKSpriteNode(imageNamed: "target")
    let turret:SKSpriteNode = SKSpriteNode(imageNamed: "turret")
    var ground:SKSpriteNode = SKSpriteNode()
    
    let loopingBG:SKSpriteNode = SKSpriteNode(imageNamed: "stars")
    let loopingBG2:SKSpriteNode = SKSpriteNode(imageNamed: "stars")
    let moon:SKSpriteNode = SKSpriteNode(imageNamed: "moon")
    
    let length:CGFloat = 200
    var rotation:CGFloat = 0.0
    var offSet:CGFloat = 0
    
    let rotateRec = UIRotationGestureRecognizer()
    let tapRec = UITapGestureRecognizer()
    
    var bgSoundPlayer = AVAudioPlayer()
    
    var gameIsActive:Bool = false
    
    
    override func didMoveToView(view: SKView) {
        
        if (UIDevice.currentDevice().userInterfaceIdiom == .Pad) {
            isPhone = false
        } else {
            isPhone = true
        }
        
        screenWidth = (self.view?.bounds.width)!
        screenHeight = (self.view?.bounds.height)!
        
        physicsWorld.gravity = CGVector(dx: 0.0, dy: 0.1)
        
        rotateRec.addTarget(self, action: "rotatedView:")
        self.view!.addGestureRecognizer(rotateRec)
        
        tapRec.addTarget(self, action: "tappedView:")
        tapRec.numberOfTouchesRequired = 1
        tapRec.numberOfTapsRequired = 1
        self.view!.addGestureRecognizer(tapRec)
        
        self.backgroundColor = SKColor.blackColor()
        self.anchorPoint = CGPointMake(0.5, 0.0)
        
        createPlayer()
        createGround()
        createInstructionLabel()
        setupBackground()
    }
    
    
    //setupBackground
    func setupBackground() {
        
        addChild(loopingBG)
        addChild(loopingBG2)
        addChild(moon)
        
        moon.zPosition = -199
        moon.alpha = 1.0
        loopingBG.zPosition = -200
        loopingBG2.zPosition = -200
        
        let loopY:CGFloat = loopingBG.size.height
        let loopX:CGFloat = loopingBG.size.width
        let moonX:CGFloat = moon.size.width
        loopingBG.position = CGPointMake(0.0, loopY / 2)
        loopingBG2.position = CGPointMake(loopX, loopY / 2)
        moon.position = CGPointMake((screenWidth / 2) + (moonX / 2), screenHeight / 2)
        
        startLoopingBackground()
        startGame()
    }
    
    
    //startLoopBackground
    func startLoopingBackground() {
        let bgMove:SKAction = SKAction.moveByX(-loopingBG.size.width, y: -loopingBG.size.height / 2, duration: 160)
        let bgMoveBack:SKAction = SKAction.moveByX(loopingBG.size.width, y: 0.0, duration: 0)
        let seq:SKAction = SKAction.sequence([bgMove, bgMoveBack])
        let repeatAction:SKAction = SKAction.repeatActionForever(seq)
        
        loopingBG.runAction(repeatAction)
        loopingBG2.runAction(repeatAction)
        
        let moonMove:SKAction = SKAction.moveByX(-screenWidth * 2, y: -screenHeight / 2, duration: 100)
        let moonMoveBack:SKAction = SKAction.moveByX(screenWidth * 2, y: screenHeight / 2, duration: 0)
        let wait:SKAction = SKAction.waitForDuration(5)
        let seqMoon:SKAction = SKAction.sequence([moonMove, wait, moonMoveBack])
        let repeatMoonAction:SKAction = SKAction.repeatActionForever(seqMoon)
        
        moon.runAction(repeatMoonAction)
    }
    
    
    //createPlayer
    func createPlayer() {
        addChild(playerBase)
        playerBase.zPosition = 100
        
        if isPhone == true {
            playerBase.position = CGPointMake(0.0, ground.position.y + (playerBase.size.height * 1.5))
        } else {
            playerBase.position = CGPointMake(0.0, ground.position.y + (playerBase.size.height))
        }
        
        playerBase.physicsBody = SKPhysicsBody(circleOfRadius: playerBase.size.width / 2)
        playerBase.physicsBody!.categoryBitMask = BodyType.playerbase.rawValue
        playerBase.physicsBody?.dynamic = false
        
        addChild(turret)
        turret.zPosition = 99
        turret.anchorPoint = CGPointMake(0.5, 0.0)
        if isPhone == true {
            turret.position = CGPointMake(0.0, playerBase.position.y)
        } else {
            turret.position = CGPointMake(0.0, playerBase.position.y)
        }
        
        
        addChild(target)
        target.zPosition = 98
        let smallSize:CGSize = CGSize(width: target.size.width / 2, height: target.size.height / 2)
        if isPhone == true {
            target.position = CGPointMake(0.0, turret.position.y + (length / 1.25))
            target.size = smallSize
        } else {
            target.position = CGPointMake(0.0, turret.position.y + length)
        }
        
    }
    
    
    //createGround
    func createGround() {
        let size:CGSize = CGSizeMake(screenWidth, 70)
        let tex:SKTexture = SKTexture(imageNamed: "rocky_ground")
        let ground = SKSpriteNode(texture: tex, color: SKColor.clearColor(), size: size)
        ground.physicsBody = SKPhysicsBody(rectangleOfSize: size)
        ground.physicsBody!.categoryBitMask = BodyType.ground.rawValue
        ground.physicsBody!.contactTestBitMask = BodyType.enemyMissile.rawValue | BodyType.enemyBomb.rawValue
        
        ground.physicsBody!.dynamic = false
        
        addChild(ground)
        
        ground.zPosition = 500
        
        if isPhone == true {
            ground.position = CGPointMake(0.0, size.height / 4)
        } else {
            ground.position = CGPointMake(0.0, size.height / 2)
        }
    }
    
    
    //firstLabel
    func createInstructionLabel() {
        instructLabel = SKLabelNode(fontNamed: "BM germar")
        if let instructLabel = instructLabel {
            
            instructLabel.alpha = 0.0
            instructLabel.horizontalAlignmentMode = .Center
            instructLabel.verticalAlignmentMode = .Center
            instructLabel.fontColor = SKColor.whiteColor()
            instructLabel.text = "Rotate Fingers to Swivel Turret!"
            instructLabel.zPosition = 5
            
            addChild(instructLabel)
            
            if isPhone == true {
                instructLabel.position = CGPointMake(0, screenHeight * 0.5)
                instructLabel.fontSize = 30
            } else {
                instructLabel.position = CGPointMake(0, screenHeight * 0.3)
                instructLabel.fontSize = 40
            }
            
            
            let wait:SKAction = SKAction.waitForDuration(0.15)
            let wait2:SKAction = SKAction.waitForDuration(0.20)
            let fadeDown:SKAction = SKAction.fadeAlphaTo(0, duration: 0.25)
            let fadeUp:SKAction = SKAction.fadeAlphaTo(1, duration: 0.25)
            let seq:SKAction = SKAction.sequence([wait, fadeUp, wait2, fadeDown])
            let runLoop:SKAction = SKAction.repeatActionForever(seq)
            
            instructLabel.runAction(runLoop)
        }
    }
    
    
    func rotatedView(sender:UIRotationGestureRecognizer) {
        if sender.state == .Changed {
            rotation = CGFloat(-sender.rotation) + offSet
            let maxRotation = CGFloat(1.4)
            
            if rotation < -maxRotation {
                rotation = -maxRotation
            } else if rotation > maxRotation {
                rotation = maxRotation
            }
            
            turret.zRotation = rotation
            target.zRotation = rotation
            
            let xDist:CGFloat = sin(rotation) * (length / 1.25)
            let yDist:CGFloat = cos(rotation) * (length / 1.25)
            
            target.position = CGPointMake(turret.position.x - xDist, turret.position.y + yDist)
        }
        
        if sender.state == .Ended {
            offSet = rotation
        }
    }
    
    
    func tappedView(sender:UITapGestureRecognizer) {
        createBullet()
        rattle(playerBase)
        turretRattle(turret)
    }
    
    
    func rattle(node:SKSpriteNode) {
        let rattleUp:SKAction = SKAction.moveByX(0, y: 3, duration: 0.05)
        let rattleDown:SKAction = SKAction.moveByX(0, y: -3, duration: 0.05)
        let seq:SKAction = SKAction.sequence([rattleUp, rattleDown])
        let actionRepeat:SKAction = SKAction.repeatAction(seq, count: 3)
        
        node.runAction(actionRepeat)
    }
    
    func turretRattle(node:SKSpriteNode) {
        let rattleUp:SKAction = SKAction.moveByX(0, y: -2, duration: 0.1)
        let rattleDown:SKAction = SKAction.moveByX(0, y: 2, duration: 0.05)
        let seq:SKAction = SKAction.sequence([rattleUp, rattleDown])
        let actionRepeat:SKAction = SKAction.repeatAction(seq, count: 1)
        
        node.runAction(actionRepeat)
    }
    
    
    func createBullet() {
        
        self.enumerateChildNodesWithName("bulletNode") {
            node, stop in
            print("\(node)")
        }
        
        self.enumerateChildNodesWithName("bulletNode") {
            node, stop in
            
            if node.position.x < -(self.screenWidth/2) {
                node.removeFromParent()
                print("bulletNode at \(node.position) removed")
            } else if node.position.x > self.screenWidth/2 {
                node.removeFromParent()
                print("bulletNode at \(node.position) removed")
            } else if node.position.y > self.screenHeight {
                node.removeFromParent()
                print("bulletNode at \(node.position) removed")
            }
        }
        
        self.enumerateChildNodesWithName("fireEmitterNode") {
            node, stop in
            node.removeFromParent()
            print("fireEmitterNode at \(node.position) removed")
        }
        
        let bullet:SKSpriteNode = SKSpriteNode(imageNamed: "bullet")
        bullet.physicsBody = SKPhysicsBody(circleOfRadius: bullet.size.width / 3)
        bullet.physicsBody!.categoryBitMask = BodyType.bullet.rawValue
        bullet.zRotation = rotation
        bullet.name = "bulletNode"
        
        if isPhone == true {
            let xDist:CGFloat = sin(rotation) * 15
            let yDist:CGFloat = cos(rotation) * 15
            
            bullet.position = CGPointMake(turret.position.x - xDist, turret.position.y + yDist)
            
            addChild(bullet)
            
            let forceXDist:CGFloat = sin(rotation) * 100
            let forceYDist:CGFloat = cos(rotation) * 5
            let theForce:CGVector = CGVectorMake(turret.position.x - forceXDist, turret.position.y + forceYDist)
            bullet.physicsBody!.applyForce(theForce)
            
            let firingParticlesPosition = CGPointMake(turret.position.x - xDist * 2.5, (turret.position.y + yDist) * 1.3)
            let fireForce:CGVector = CGVectorMake((turret.position.x - forceXDist), (turret.position.y + forceYDist))
            playNodeActionSound("gun1.caf")
            createFiringParticles(firingParticlesPosition, force:fireForce)
            
        } else {
            let xDist:CGFloat = sin(rotation) * 60
            let yDist:CGFloat = cos(rotation) * 60
            
            bullet.position = CGPointMake(turret.position.x - xDist, turret.position.y + yDist)
            
            addChild(bullet)
            
            let destroyWait:SKAction = SKAction.waitForDuration(0.5)
            let destroy:SKAction = SKAction.removeFromParent()
            let seq:SKAction = SKAction.sequence([destroyWait,destroy])
            
            let forceXDist:CGFloat = sin(rotation) * 200
            let forceYDist:CGFloat = cos(rotation) * 200
            let theForce:CGVector = CGVectorMake(turret.position.x - forceXDist, turret.position.y + forceYDist)
            bullet.physicsBody!.applyForce(theForce)
            
            playNodeActionSound("gun1.caf")
            createFiringParticles(bullet.position, force:theForce)
            
            runAction(seq)
        }
    }
    
    
    //createFiringParticles
    func createFiringParticles(location:CGPoint, force:CGVector) {
        if isPhone == true {
            let fireEmitter = SKEmitterNode(fileNamed: "FireParticle")
            fireEmitter?.position = location
            fireEmitter?.numParticlesToEmit = 3
            fireEmitter?.zPosition = 1
            fireEmitter?.xAcceleration = force.dx
            fireEmitter?.yAcceleration = force.dy
            fireEmitter?.targetNode = self
            fireEmitter?.name = "fireEmitterNode"
            
            addChild(fireEmitter!)
        } else {
            let fireEmitter = SKEmitterNode(fileNamed: "FireParticle")
            fireEmitter?.position = location
            fireEmitter?.numParticlesToEmit = 5
            fireEmitter?.zPosition = 1
            fireEmitter?.xAcceleration = force.dx
            fireEmitter?.yAcceleration = force.dy
            fireEmitter?.targetNode = self
            fireEmitter?.name = "fireEmitterNode"
            
            addChild(fireEmitter!)
        }
    }
    
    
    
    //startGame
    func startGame() {
        gameIsActive = true
        
        //begin dropping missiles
        
        //add particles to missiles
        
        //begin drones flying around
        
        //check to see if game is over
        
        //clear unseen/unneeded nodes
        clearUnseenObjects()
    }
    
    
    //clearUnseenNodes
    func clearUnseenObjects() {
        
        clearBullets()
        clearEnemyMissiles()
        
        let wait:SKAction = SKAction.waitForDuration(0.5)
        let block:SKAction = SKAction.runBlock(clearUnseenObjects)
        let seq:SKAction = SKAction.sequence([wait, block])
        let repeatAction:SKAction = SKAction.repeatActionForever(seq)
        self.runAction(repeatAction, withKey: "clearItems")
    }
    
    
    //clearBullets
    func clearBullets() {
        self.enumerateChildNodesWithName("bulletNode") {
            node, stop in
            var nodeArray = [node]
            nodeArray.append(node)
            
            if node.position.x < -(self.screenWidth/2) {
                node.removeFromParent()
                print("node at \(node.position) removed")
            } else if node.position.x > self.screenWidth/2 {
                node.removeFromParent()
                print("node at \(node.position) removed")
            } else if node.position.y > self.screenHeight {
                node.removeFromParent()
                print("node at \(node.position) removed")
            }
        }
        
        self.enumerateChildNodesWithName("FireParticle") {
            node, stop in
            node.removeFromParent()
        }
    }
    
    
    //clearEnemyMissiles
    func clearEnemyMissiles() {
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let fadeDown:SKAction = SKAction.fadeAlphaTo(0, duration: 0.50)
        let removeObject:SKAction = SKAction.removeFromParent()
        let touchSeq:SKAction = SKAction.sequence([fadeDown, removeObject])
        
        if let instructLabel = instructLabel {
            instructLabel.runAction(touchSeq)
        }
    }
    
    
    //playNodeSound
    func playNodeActionSound(sound:String) {
        let soundAction:SKAction = SKAction.playSoundFileNamed(sound, waitForCompletion: false)
        self.runAction(soundAction)
    }
    
    
    //playBackgroundSoundWav
    func playBackgroundSoundWav(sound:String) {
        let fileURL:NSURL = NSBundle.mainBundle().URLForResource(sound, withExtension: "wav")!
        do {
            try bgSoundPlayer = AVAudioPlayer(contentsOfURL: fileURL)
            bgSoundPlayer.volume = 0.25
            bgSoundPlayer.numberOfLoops = -1
            bgSoundPlayer.prepareToPlay()
            bgSoundPlayer.play()
            print("AudioPlayer Created")
        } catch {
            print("No Audio")
        }
    }
}
