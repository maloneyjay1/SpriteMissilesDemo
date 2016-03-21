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
    
    var gameIsActive:Bool = false
    
    var activeBase:CGPoint = CGPointZero
    
    var baseArray = [CGPoint]()
    
    
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
        
        setUpBaseArray()
        addBases()
        
        
        setUpBackground()
        
        createInstructionLabel()
        
        playBackgroundSound("levelsound")
        
        startGame()
        
    }
    
    
    
   // MARK: ======== INITIAL SETUP
    
    
    func setUpBaseArray(){
        
        baseArray.append(CGPointMake( screenWidth * 0.15, ground.position.y) )
        baseArray.append(CGPointMake( screenWidth * 0.3, ground.position.y) )
        baseArray.append(CGPointMake( screenWidth * 0.45, ground.position.y) )
        baseArray.append(CGPointMake( -screenWidth * 0.15, ground.position.y) )
        baseArray.append(CGPointMake( -screenWidth * 0.3, ground.position.y) )
        baseArray.append(CGPointMake( -screenWidth * 0.45, ground.position.y) )
        
    }
    
    func addBases(){
        
        for item in baseArray {
            
            print(item)
            let base:Base = Base(imageNamed:"base")
            addChild(base)
            base.position = CGPointMake(item.x , item.y + base.size.height / 2)
            
        }
        
        
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
        let repeated:SKAction = SKAction.repeatActionForever(seq)
        
        loopingBG.runAction(repeated)
        loopingBG2.runAction(repeated)
        
        
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
    
     // MARK: ======== START GAME
    
    
    func startGame(){
        
        gameIsActive = true
        
        // start the missiles coming down
        
        initiateEnemyMissiles()
        
        // add particles / dots behind enemy missiles 
        startDotLoop()
        
        
        // initiate drones flying across
        
        initateDrone()
        
        // check to see if the game is over 
        
        startGameOverTesting()
        
        
        // clear out unseen objects
        
        clearOutOfSceneItems()
        
        
    }
    
    
    
    func startGameOverTesting() {
        
        let block:SKAction = SKAction.runBlock(gameOverTest)
        let wait:SKAction = SKAction.waitForDuration(1)
        let seq:SKAction = SKAction.sequence( [ wait, block])
        let repeated:SKAction = SKAction.repeatActionForever(seq)
        self.runAction(repeated, withKey:"gameOverTest")
        
        
    }
    
    func gameOverTest() {
        
        var destroyedBases:Int = 0
        
        self.enumerateChildNodesWithName("base") {
            node, stop in
        
            
            if let someBase:Base = node as? Base {
                
                if (someBase.alreadyDestroyed == true) {
                    
                    destroyedBases++
                    
                } else {
                    
                    self.activeBase = someBase.position
                }
                
            }
            
            //////
            
            if (destroyedBases == self.baseArray.count) {
                
                
                self.gameOver()
                
                
            }
        
        
        }
        
        
    }
    
    
    
    
    
    
    
    func clearOutOfSceneItems() {
        
        clearBullet()
        clearEnemyMissiles()
        
        let wait:SKAction = SKAction.waitForDuration(1)
        let block:SKAction = SKAction.runBlock(clearOutOfSceneItems)
        let seq:SKAction = SKAction.sequence( [ wait, block])
        self.runAction(seq, withKey:"clearAction")
        
        
    }
    
    
    func clearBullet(){
        
        self.enumerateChildNodesWithName("bullet") {
            node, stop in
            
            if (node.position.x < -(self.screenWidth / 2)) {
                
                node.removeFromParent()
                
            } else if (node.position.x > (self.screenWidth / 2)) {
                
                node.removeFromParent()
                
            } else if (node.position.y > self.screenHeight) {
                
                node.removeFromParent()
                
            }
            
                // this code runs when we find a bullet
        
        }
        
    }
    
    func clearEnemyMissiles(){
        
        
        
        
    }
    
    // MARK: ======== CREATE ENEMY MISSILES 
    
    func initiateEnemyMissiles() {
        
        let wait:SKAction = SKAction.waitForDuration(2)
        let block:SKAction = SKAction.runBlock(launchEnemyMissile)
        let seq:SKAction = SKAction.sequence( [ block, wait ])
        let repeated:SKAction = SKAction.repeatActionForever(seq)
        self.runAction(repeated, withKey:"enemyLaunchAction")
        
        
    }
    
    
    func launchEnemyMissile() {
        
        let missile:EnemyMissile = EnemyMissile()
        missile.createMissile("enemyMissile")
        addChild(missile)
        
        let randomX = arc4random_uniform( UInt32(screenWidth) )
        missile.position = CGPointMake(  CGFloat(randomX)  - (screenWidth / 2), screenHeight + 50)
        
       let randomVecX = arc4random_uniform( 20 )
        
        let vecX:CGFloat = CGFloat(randomVecX) / 10
        
        
        if ( missile.position.x < 0) {
            
            missile.physicsBody?.applyImpulse( CGVector(dx: vecX, dy: 0) )
            
        } else {
            
            missile.physicsBody?.applyImpulse( CGVector(dx: -vecX, dy: 0) )
            
        }
        
        
    }
    
    
    func startDotLoop() {
        
        
        let block:SKAction = SKAction.runBlock(addDot)
        let wait:SKAction = SKAction.waitForDuration(1/60)
        let seq:SKAction = SKAction.sequence( [ block, wait ])
        let repeated:SKAction = SKAction.repeatActionForever(seq)
        self.runAction(repeated, withKey:"dotAction")
        
        
    }
    
    func addDot() {
        
        
        self.enumerateChildNodesWithName("enemyMissile") {
            node, stop in
            
            let dot:SKSpriteNode = SKSpriteNode(imageNamed: "dot")
            dot.position = node.position
            self.addChild(dot)
            dot.zPosition = -1
            dot.xScale = 0.3
            dot.yScale = 0.3
            
            let fade:SKAction = SKAction.fadeAlphaTo(0.0, duration: 3)
            let grow:SKAction = SKAction.scaleTo(3.0, duration:3)
            let color:SKAction = SKAction.colorizeWithColor(SKColor.redColor(), colorBlendFactor: 1, duration: 3)
            let group:SKAction = SKAction.group( [fade, grow, color])
            let remove:SKAction = SKAction.removeFromParent()
            let seq:SKAction = SKAction.sequence( [group, remove])
            dot.runAction(seq)
            
            
            
        }

    }
    
    
     // MARK: ======== CREATE DRONE
    
    
    func initateDrone(){
        
        
        let wait:SKAction = SKAction.waitForDuration(10)
        let block:SKAction = SKAction.runBlock(launchDrone)
        let seq:SKAction = SKAction.sequence( [ wait, block ])
        self.runAction(seq)
        
    }
    
    func launchDrone() {
        
        let theDrone:Drone = Drone()
        theDrone.createDrone()
        addChild( theDrone )
        theDrone.position = CGPointMake( (screenWidth / 2) + theDrone.droneNode.size.width, screenHeight * 0.8)
        
        let move:SKAction = SKAction.moveByX( -(screenWidth + (theDrone.droneNode.size.width * 2) ), y: 0, duration: 10)
        let remove:SKAction = SKAction.removeFromParent()
        let seq:SKAction = SKAction.sequence( [move, remove ])
        
        theDrone.runAction(seq)
        
        // drop bombs
        
        let randomDrop = arc4random_uniform( 6 )
        let waitToDrop:SKAction = SKAction.waitForDuration( CFTimeInterval(randomDrop) + 2)
        let blockDrop:SKAction = SKAction.runBlock( dropBombFromDrone)
        let dropSequence:SKAction = SKAction.sequence( [waitToDrop, blockDrop])
        self.runAction(dropSequence, withKey:"dropBombAction")
        
        // launch next drone
        
        
        let randomTime = arc4random_uniform( 20 )
        let wait:SKAction = SKAction.waitForDuration( CFTimeInterval(randomTime) + 10)
        let block:SKAction = SKAction.runBlock( launchDrone )
        let seq2:SKAction = SKAction.sequence( [wait, block])
        self.runAction(seq2, withKey:"droneAction")
        
        
    }
    
    
    func dropBombFromDrone(){
        
        var dronePosition:CGPoint = CGPointZero
        
        self.enumerateChildNodesWithName("drone") {
            node, stop in
            
            dronePosition = node.position
            
            
        }
        
        let droneBomb:SKSpriteNode = SKSpriteNode(imageNamed: "droneBomb")
        droneBomb.name = "droneBomb"
        droneBomb.position = CGPointMake( dronePosition.x, dronePosition.y - 45)
        self.addChild(droneBomb)
        droneBomb.physicsBody = SKPhysicsBody(circleOfRadius: droneBomb.size.width / 3 )
        droneBomb.physicsBody!.categoryBitMask = BodyType.enemyBomb.rawValue
        droneBomb.physicsBody!.contactTestBitMask = BodyType.base.rawValue | BodyType.bullet.rawValue
        droneBomb.physicsBody!.dynamic = true
        droneBomb.physicsBody!.affectedByGravity = false
        droneBomb.physicsBody!.allowsRotation = false
        
        
        
        
        let scaleY:SKAction = SKAction.scaleXBy(1, y: 1.5, duration: 0.5)
        droneBomb.runAction(scaleY)
        
        let move:SKAction = SKAction.moveTo(activeBase, duration: 4)
        droneBomb.runAction(move)
        
        
    }
    
    
    
    // MARK: ======== ROTATE GESTURE
    
    
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
    
    // MARK: ======== TAP TO SHOOT
    
    
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
        let repeated:SKAction = SKAction.repeatAction(seq, count: 3)
        
        node.runAction(repeated)
        
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
        fireEmitter!.position = location
        fireEmitter!.numParticlesToEmit = 50
        fireEmitter!.zPosition = 1
        fireEmitter!.targetNode = self
        
        fireEmitter!.xAcceleration = force.dx
        fireEmitter!.yAcceleration = force.dy
        
        self.addChild(fireEmitter!)
        
    }
    
    
    // MARK: ======== LABELS
   
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
        let repeated:SKAction = SKAction.repeatAction(seq, count: 3)
        let remove:SKAction = SKAction.removeFromParent()
        let seq2:SKAction = SKAction.sequence( [repeated, wait, remove] )
        instructionLabel.runAction(seq2)
        
    
    }
    
    

    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        /* Called when a touch begins */
        
       
       
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
    
    
    // MARK: ======== TAP TO SOUNDS
    
    func playBackgroundSound(name:String) {
        
        
        if (bgSoundPlayer != nil) {
            
            bgSoundPlayer!.stop()
            bgSoundPlayer = nil
            
        }
        
        let fileURL:NSURL = NSBundle.mainBundle().URLForResource(name, withExtension: "mp3")!
        
        do {
            bgSoundPlayer = try AVAudioPlayer(contentsOfURL: fileURL)
        } catch _ {
            bgSoundPlayer = nil
        }
        
        bgSoundPlayer!.volume = 0.25 //half volume
        bgSoundPlayer!.numberOfLoops = -1
        bgSoundPlayer!.prepareToPlay()
        bgSoundPlayer!.play()
        
        
    }
    
    func playSound(name:String){
        
        
        let theSound:SKAction = SKAction.playSoundFileNamed(name, waitForCompletion: false)
        self.runAction(theSound)
        
    }
    
    
    
    
     // MARK: ======== GAME OVER
    
    
    func gameOver(){
        
        print( "game over")
        
        
        
    }

    
    
}
