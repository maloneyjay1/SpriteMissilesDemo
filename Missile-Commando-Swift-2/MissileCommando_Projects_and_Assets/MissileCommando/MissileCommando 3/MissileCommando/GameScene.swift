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




class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var isPhone:Bool = true
    var screenWidth:CGFloat = 0
    var screenHeight:CGFloat = 0
    let instructionLabel:SKLabelNode = SKLabelNode(fontNamed: "BM germar")
    let statsLabel:SKLabelNode = SKLabelNode(fontNamed: "BM germar")
    let scoreLabel:SKLabelNode = SKLabelNode(fontNamed: "BM germar")
    let levelLabel:SKLabelNode = SKLabelNode(fontNamed: "BM germar")

 
    var health:Int = 5
    var healthMeter:SKSpriteNode = SKSpriteNode(imageNamed: "healthMeter1")
    
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
    
    var level:Int = 1
    var score:Int = 0
    var attacksLaunched:Int = 0
    var attacksTotal:Int = 25
    var droneHowOften:UInt32 = 30
    var droneBombSpeed:CFTimeInterval = 5
    var missileRate:CFTimeInterval = 2
    
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        
        if (UIDevice.currentDevice().userInterfaceIdiom == .Pad) {
            
            isPhone = false
            
        } else {
            
            isPhone = true
        }
        
        
        
        physicsWorld.gravity = CGVector(dx: 0, dy:-0.1)
        physicsWorld.contactDelegate = self
        
        
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
        
        
        setLevelVars()
        
        createGround()
        addPlayer()
        
        setUpBaseArray()
        addBases()
        
        
        setUpBackground()
        
        createInstructionLabel()
        createLevelLabel()
        createScoreLabel()
        createStatsLabel()
        
        playBackgroundSound("levelsound")
        
        startGame()
        
        createMainLabel("Defend!")
        
    }
    
    
    
   // MARK: ======== INITIAL SETUP
    
    
    func setLevelVars() {
        
        attacksTotal = level * 25
        
        if (level == 1) {
            
            physicsWorld.gravity = CGVector(dx: 0, dy:-0.1)
            droneBombSpeed = 4
            missileRate = 3
            
        } else if (level == 2) {
            
             physicsWorld.gravity = CGVector(dx: 0, dy:-0.12)
            droneBombSpeed = 3
            missileRate = 2.5
            
        } else if (level == 3) {
            
             physicsWorld.gravity = CGVector(dx: 0, dy:-0.14)
            droneBombSpeed = 2
            missileRate = 2
            
        } else {
            
            
             physicsWorld.gravity = CGVector(dx: 0, dy:-0.18)
            droneBombSpeed = 2
            missileRate = 1.5
            
        }
        
        
        
    }
    
    
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
            
           // println(item)
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
        
        
        addChild(healthMeter)
        healthMeter.zPosition = 1000
        healthMeter.position = CGPointMake(0, playerBase.position.y - 20)
        
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
        let repeat:SKAction = SKAction.repeatActionForever(seq)
        self.runAction(repeat, withKey:"gameOverTest")
        
        
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
                
                node.name = "removeNode"
                
            } else if (node.position.x > (self.screenWidth / 2)) {
                
                node.name = "removeNode"
                
            } else if (node.position.y > self.screenHeight) {
                
                node.name = "removeNode"
                
            }
            
                // this code runs when we find a bullet
        
        }
        
    }
    
    func clearEnemyMissiles(){
        
        
        self.enumerateChildNodesWithName("enemyMissile") {
            node, stop in
            
            if (node.position.x < -(self.screenWidth / 2)) {
                
                node.name = "removeNode"
                
            } else if (node.position.x > (self.screenWidth / 2)) {
                
                node.name = "removeNode"
                
            }
            
            // this code runs when we find a bullet
            
        }
        
        
        
        
    }
    
    // MARK: ======== CREATE ENEMY MISSILES 
    
    func initiateEnemyMissiles() {
        
        let wait:SKAction = SKAction.waitForDuration(missileRate)
        let block:SKAction = SKAction.runBlock(launchEnemyMissile)
        let seq:SKAction = SKAction.sequence( [ block, wait ])
        let repeat:SKAction = SKAction.repeatActionForever(seq)
        self.runAction(repeat, withKey:"enemyLaunchAction")
        
        
    }
    
    
    func launchEnemyMissile() {
        
        attacksLaunched++
        updateStats()
        
        
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
        let repeat:SKAction = SKAction.repeatActionForever(seq)
        self.runAction(repeat, withKey:"dotAction")
        
        
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
        
        attacksLaunched++
        updateStats()
        
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
        
        let move:SKAction = SKAction.moveTo(activeBase, duration: droneBombSpeed)
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
    
    
    // MARK: ======== LABELS
    
    
    func createLevelLabel() {
        
        
        levelLabel.horizontalAlignmentMode = .Left
        levelLabel.verticalAlignmentMode = .Center
        levelLabel.fontColor = SKColor.whiteColor()
        levelLabel.text = "Level: " + String(level)
        
        levelLabel.zPosition = 300
        
        addChild(levelLabel)
        
        
        if (isPhone == true ) {
            
            levelLabel.position = CGPoint(x: (screenWidth / 2) * 0.7, y: screenHeight - 30 )
            levelLabel.fontSize = 20
        } else  {
            levelLabel.position = CGPoint(x: (screenWidth / 2) * 0.7, y: screenHeight - 30 )
            levelLabel.fontSize = 40
        }
        
        
        
    }
    
    
    func createScoreLabel() {
        
        
        scoreLabel.horizontalAlignmentMode = .Center
        scoreLabel.verticalAlignmentMode = .Center
        scoreLabel.fontColor = SKColor.whiteColor()
        scoreLabel.text = "Score: " + String(score)
        
        scoreLabel.zPosition = 300
        
        addChild(scoreLabel)
        
        
        if (isPhone == true ) {
            
            scoreLabel.position = CGPoint(x: 0, y: screenHeight - 30 )
            scoreLabel.fontSize = 20
            
        } else  {
            scoreLabel.position = CGPoint(x: 0, y: screenHeight - 30 )
            scoreLabel.fontSize = 40
            
        }
        
        
        
    }
    
    
    func updateScore(scoreToAdd:Int) {
        
        
        score = score + scoreToAdd
        
        scoreLabel.text = "Score: " + String(score)
        
        
    }
    
   
    func createInstructionLabel() {
        
        
        instructionLabel.horizontalAlignmentMode = .Center
        instructionLabel.verticalAlignmentMode = .Center
        instructionLabel.fontColor = SKColor.whiteColor()
        instructionLabel.text = "Rotate Fingers to Swivel Turret"
        instructionLabel.zPosition = 1
        addChild(instructionLabel)
       
        if ( isPhone == true) {
            
            instructionLabel.position = CGPointMake(0, (screenHeight / 2) - 55)
            instructionLabel.fontSize = 30
            
        } else {
            
            instructionLabel.position = CGPointMake(0, (screenHeight / 2) - 85)
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
    
    func createStatsLabel() {
        
        
        statsLabel.horizontalAlignmentMode = .Left
        statsLabel.verticalAlignmentMode = .Center
        statsLabel.fontColor = SKColor.whiteColor()
        statsLabel.text = "Wave: " + String(attacksLaunched) + "/" + String(attacksTotal)
        
        statsLabel.zPosition = 300
        
        addChild(statsLabel)
        
        
        if (isPhone == true ) {
            
            statsLabel.position = CGPoint(x: -(screenWidth / 2) * 0.9, y: screenHeight - 30 )
            statsLabel.fontSize = 20
        } else  {
            statsLabel.position = CGPoint(x: -(screenWidth / 2) * 0.9, y: screenHeight - 30 )
            statsLabel.fontSize = 40
        }
        
        
        
    }
    
    
    func updateStats() {
        
        
       statsLabel.text = "Wave: " + String(attacksLaunched) + "/" + String(attacksTotal)
        
        if (attacksLaunched == attacksTotal) {
            
            // LEVEL UP
            
            createMainLabel("Level Up!")
            stopGameActions()
            moveDownBases()
            explodeAllMissiles()
            
            let wait:SKAction = SKAction.waitForDuration(4)
            let block:SKAction = SKAction.runBlock(levelUp)
            let seq:SKAction = SKAction.sequence( [wait, block])
            self.runAction(seq)
            
            
        }
        
        
    }
    
    
    func levelUp(){
        
        let wait:SKAction = SKAction.waitForDuration(1)
        let block:SKAction = SKAction.runBlock(successSound)
        let seq:SKAction = SKAction.sequence( [wait, block])
        self.runAction(seq)
        
        
        
        attacksLaunched = 0
        level++
        
        levelLabel.text = "Level: " + String(level)
        
        resetHealth()
        
        
        setLevelVars()
        
        startGame()
        
        
        
    }
    
    
    func successSound(){
        
        playRandomSound("success", withRange: 3)
        
    }
    
    
    func createMainLabel(theText:String) {
        
        
        let bigMiddleLabel:SKLabelNode = SKLabelNode(fontNamed: "BM germar")
        
        bigMiddleLabel.horizontalAlignmentMode = .Center
        bigMiddleLabel.verticalAlignmentMode = .Center
        bigMiddleLabel.fontColor = SKColor.whiteColor()
        bigMiddleLabel.text = theText
        bigMiddleLabel.fontSize = 100
        bigMiddleLabel.zPosition = 300
        
        addChild(bigMiddleLabel)
        
        
        if (isPhone == true ) {
            
            bigMiddleLabel.position = CGPoint(x:0 , y: (screenHeight / 2) + 15 )
            
        } else  {
            bigMiddleLabel.position = CGPoint(x: 0 , y: screenHeight / 2 )
            
        }
        
        
        let wait:SKAction = SKAction.waitForDuration(2)
        let fade:SKAction = SKAction.fadeAlphaTo(0, duration: 1)
        let remove:SKAction = SKAction.removeFromParent()
        let seq:SKAction = SKAction.sequence( [wait, fade, remove])
        bigMiddleLabel.runAction(seq)
        
        
        
    }
    

    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
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
    
    
    func playRandomSound(baseName:String, withRange:UInt32) {
        
        
        let randomNum = arc4random_uniform( withRange)
        
        playSound(baseName + String(randomNum) + ".caf" )
        
        
    }
    
    
    
     // MARK: ======== EXPLOSION
    
    func createExplosion( atLocation:CGPoint, image:String) {
    
        let explosion:SKSpriteNode = SKSpriteNode(imageNamed: image)
        explosion.position = atLocation
        self.addChild(explosion)
        explosion.zPosition = 1
        explosion.xScale = 0.1
        explosion.yScale = explosion.xScale
        
        let grow:SKAction = SKAction.scaleTo(1, duration: 0.5)
        grow.timingMode = .EaseOut
        let color:SKAction = SKAction.colorizeWithColor(SKColor.whiteColor(), colorBlendFactor: 0.5, duration: 0.5)
        let group:SKAction = SKAction.group( [grow, color])
        
        
        let fade:SKAction = SKAction.fadeAlphaTo(0, duration:1)
        fade.timingMode = .EaseIn
        let shrink:SKAction = SKAction.scaleTo(0.8, duration: 1)
        let group2:SKAction = SKAction.group( [fade, shrink])
        
        let remove:SKAction = SKAction.removeFromParent()
        let seq:SKAction = SKAction.sequence( [group, group2, remove])
        explosion.runAction( seq)
        
        
        
    }
    
    
    
    // MARK: ======== CONTACT LISTENER
    
    func didBeginContact(contact: SKPhysicsContact) {
        
        
        if ( contact.bodyA.categoryBitMask == BodyType.enemyMissile.rawValue && contact.bodyB.categoryBitMask == BodyType.bullet.rawValue) {
        
            if let missile = contact.bodyA.node! as? EnemyMissile {
                
                 enemyMissileAndBullet(missile)
                
            }
            
            contact.bodyB.node?.name = "removeNode"
        
        
        } else if ( contact.bodyA.categoryBitMask == BodyType.bullet.rawValue && contact.bodyB.categoryBitMask == BodyType.enemyMissile.rawValue) {
            
            if let missile = contact.bodyB.node! as? EnemyMissile {
                
                enemyMissileAndBullet(missile)
                
            }
            
            contact.bodyA.node?.name = "removeNode"
            
            
            
        } else if ( contact.bodyA.categoryBitMask == BodyType.bullet.rawValue && contact.bodyB.categoryBitMask == BodyType.enemyBomb.rawValue) {
            
          
            updateScore(50)
            createExplosion(contact.bodyB.node!.position, image: "explosion2")
            
            contact.bodyB.node?.name = "removeNode"
            contact.bodyA.node?.name = "removeNode"
            
            playSound("loud_bomb.caf")
            
            
        }  else if ( contact.bodyA.categoryBitMask == BodyType.enemyBomb.rawValue && contact.bodyB.categoryBitMask == BodyType.bullet.rawValue) {
            
            updateScore(50)
            createExplosion(contact.bodyA.node!.position, image: "explosion2")
            
            contact.bodyB.node?.name = "removeNode"
            contact.bodyA.node?.name = "removeNode"
            
             playSound("loud_bomb.caf")
            
        }  else if (contact.bodyA.categoryBitMask == BodyType.base.rawValue  && contact.bodyB.categoryBitMask == BodyType.bullet.rawValue ) {
            
            contact.bodyB.node?.name = "removeNode"
            
            
        } else if (contact.bodyA.categoryBitMask == BodyType.bullet.rawValue  && contact.bodyB.categoryBitMask == BodyType.base.rawValue ) {
            
            contact.bodyA.node?.name = "removeNode"
            
        }  else if (contact.bodyA.categoryBitMask == BodyType.enemyMissile.rawValue  && contact.bodyB.categoryBitMask == BodyType.playerBase.rawValue ) {
            
            if let missile = contact.bodyA.node! as? EnemyMissile {
                
                createExplosion(missile.position, image: "explosion")
                missile.destroy()
                
            }
            
            subtractHealth()
            
            playSound("explosion2.caf")
            
            
        } else if (contact.bodyA.categoryBitMask == BodyType.playerBase.rawValue  && contact.bodyB.categoryBitMask == BodyType.enemyMissile.rawValue ) {
            
            if let missile = contact.bodyB.node! as? EnemyMissile {
                
                createExplosion(missile.position, image: "explosion")
                missile.destroy()
                
            }
            
            subtractHealth()
            
            playSound("explosion2.caf")

            
        }  else if (contact.bodyA.categoryBitMask == BodyType.enemyMissile.rawValue  && contact.bodyB.categoryBitMask == BodyType.ground.rawValue ) {
            
            
            
            if let missile = contact.bodyA.node! as? EnemyMissile {
                
                missile.destroy()
                createExplosion(missile.position , image:"explosion")
            }
            
            playSound("explosion2.caf")
            
        } else if (contact.bodyA.categoryBitMask == BodyType.ground.rawValue  && contact.bodyB.categoryBitMask == BodyType.enemyMissile.rawValue ) {
            
            
            if let missile = contact.bodyB.node! as? EnemyMissile {
                
                missile.destroy()
                createExplosion(missile.position , image:"explosion")
            }
            
            playSound("explosion2.caf")
            
        } else if (contact.bodyA.categoryBitMask == BodyType.enemyMissile.rawValue  && contact.bodyB.categoryBitMask == BodyType.base.rawValue ) {
            
            
            if let missile = contact.bodyA.node! as? EnemyMissile {
                
                
                if let base = contact.bodyB.node! as? Base {
                    
                    base.hit( missile.damagePoints )
                    
                }
                
                missile.destroy()
                createExplosion(missile.position , image:"explosion")
                
            }
            
            
            playSound("explosion2.caf")
            
            
            
        } else if (contact.bodyA.categoryBitMask == BodyType.base.rawValue  && contact.bodyB.categoryBitMask == BodyType.enemyMissile.rawValue ) {
            
            if let missile = contact.bodyB.node! as? EnemyMissile {
                
                
                
                if let base = contact.bodyA.node! as? Base {
                    
                    base.hit(missile.damagePoints)
                    
                }
                
                missile.destroy()
                createExplosion(missile.position , image:"explosion")
            }
            
            
            playSound("explosion2.caf")
            
        }  else if (contact.bodyA.categoryBitMask == BodyType.enemyBomb.rawValue  && contact.bodyB.categoryBitMask == BodyType.base.rawValue ) {
            
            
            if let base = contact.bodyB.node! as? Base {
                
                base.hit( base.maxDamage)
                
            }
            
            createExplosion(contact.bodyA.node!.position , image:"explosion2")
            contact.bodyA.node?.name = "removeNode"
            
            playSound("explosion2.caf")
            
            
        } else if (contact.bodyA.categoryBitMask == BodyType.base.rawValue  && contact.bodyB.categoryBitMask == BodyType.enemyBomb.rawValue ) {
            
            
            
            if let base = contact.bodyA.node! as? Base {
                
                base.hit(base.maxDamage)
                
            }
            
            
            createExplosion(contact.bodyB.node!.position , image:"explosion2")
            contact.bodyB.node?.name = "removeNode"
            
            playSound("explosion2.caf")
            
            
        }

        
        
        
    }
    
    func enemyMissileAndBullet(theMissile:EnemyMissile) {
        
        let thePoint:CGPoint = theMissile.position
        
        if ( theMissile.hit() == true) {
            
            createExplosion(thePoint, image: "explosion")
            updateScore(15)
            playSound( "explosion1.caf")
            
        } else {
            updateScore(5)
            playSound( "ricochet.caf")
        }
        
        
    }

    
    // MARK: ======== HEALTH 
    
    
    func subtractHealth() {
        
        health = health + 1
        healthMeter.texture = SKTexture(imageNamed: "healthMeter" + String(health))
        
        if (health == 6) {
            
            gameOver()
            
        }
        
    }
    
    func resetHealth(){
        
        health = 1
        healthMeter.texture = SKTexture(imageNamed: "healthMeter" + String(health))
        
    }
    
    
    
    
     // MARK: ======== GAME OVER

    
    
    func gameOver(){
        
        if (gameIsActive == true) {
            
            gameIsActive = false
            
            let wait2:SKAction = SKAction.waitForDuration(2)
            let block2:SKAction = SKAction.runBlock(failSounds)
            let seq2:SKAction = SKAction.sequence( [wait2, block2])
            self.runAction(seq2)
            
            createMainLabel("Game Over")
            
            explodeAllMissiles()
            stopGameActions()
            moveDownBases()
            
             let wait:SKAction = SKAction.waitForDuration(4)
             let block:SKAction = SKAction.runBlock( restartGame )
            let seq:SKAction = SKAction.sequence([wait, block])
            self.runAction(seq)
        }
        
    }
    
    func failSounds(){
        
        playRandomSound("fail", withRange: 14)
        
        
    }
    
    
    
    func restartGame() {
        
        if (gameIsActive == false) {
        
            level = 1
            score = 0
            attacksLaunched = 0
            
            
            levelLabel.text = "Level: " + String(level)
            scoreLabel.text = "Score: " + String(score)
            
            setLevelVars()
            
            resetHealth()
            startGame()
        
            
        }
        
    }
    
    
   
    
    
    
    func moveDownBases() {
        
        playSound("restoreHealth.caf")
        
        self.enumerateChildNodesWithName("base") {
            node, stop in
            
            if let someBase:Base = node as? Base {
                
                let wait:SKAction = SKAction.waitForDuration(2)
                let moveDown:SKAction = SKAction.moveByX(0, y:-200, duration: 3)
                let block:SKAction = SKAction.runBlock( someBase.revive )
                let moveUp:SKAction = SKAction.moveByX(0, y: 200, duration: 1)
                let seq:SKAction = SKAction.sequence([wait, moveDown, block, moveUp])
                someBase.runAction(seq)
                
                
            }
            
            
            
        }
        
        
        
        
    }
    
    
    
    func stopGameActions() {
        
        self.removeActionForKey("gameOverTest")
        self.removeActionForKey("droneAction")
        self.removeActionForKey("enemyLaunchAction")
        self.removeActionForKey("dotAction")
        self.removeActionForKey("clearAction")
        self.removeActionForKey("dropBombAction")
        
        
    }
    
    
    
    
    func explodeAllMissiles() {
        
        
        playSound("explosion1.caf")
        
        
        self.enumerateChildNodesWithName("enemyMissile") {
            node, stop in
            
            if let enemyMissile:EnemyMissile = node as? EnemyMissile {
                
                self.createExplosion(enemyMissile.position, image: "explosion")
                enemyMissile.destroy()
                
                
            }
            
            
            
        }
        self.enumerateChildNodesWithName("droneBomb") {
            node, stop in
            
                self.createExplosion(node.position, image: "explosion2")
                node.name = "removeNode"
            
        }
        
        
        
    }
    
    
    
    
    
    
    
    
    
    
    
    // MARK: ======== REMOVE ALL NODES MARKED FOR REMOVAL
    
    override func didSimulatePhysics() {
        
        self.enumerateChildNodesWithName("removeNode") {
            node, stop in
            
            node.removeFromParent()
            
        }
    }

    
    
}






