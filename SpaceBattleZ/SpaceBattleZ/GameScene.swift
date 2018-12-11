//
//  GameScene.swift
//  SpaceBattleZ
//
//  Created by Zaen on 12/4/18.
//  Copyright © 2018 Zaen. All rights reserved.
//

import SpriteKit
import GameplayKit
import CoreMotion
import AVFoundation

struct CollisionCategory {
    
    static let Player : UInt32 = 0x1 << 1
    static let Enemy : UInt32 = 0x1 << 2
    static let Bullet : UInt32 = 0x1 << 3
    
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let foregroundNode = SKSpriteNode()
    let coreMotionManager = CMMotionManager()
    var timer = Timer()
//    var timerTest = Timer()
    lazy var stopOrder = 0 //0 and 1, 1 means stop
    private var currentScore = SKLabelNode(fontNamed: "Copperplate")
    private var cScore : Int = 0
    private var highScore = SKLabelNode(fontNamed: "Copperplate")
    private var hScore : Int = 0
    private var audioPlayer : AVAudioPlayer!
    private var backgroundSoundPlayer : AVAudioPlayer!
    
    lazy var backgroundNode1 : SKSpriteNode = {
        let backgroundNode1 = SKSpriteNode(imageNamed: "BG_SpaceBattle_planet")
        backgroundNode1.size.width = frame.size.width/0.8
        backgroundNode1.size.height = frame.size.height
        backgroundNode1.anchorPoint = CGPoint(x: 0.5, y: 0.0)
        backgroundNode1.position = CGPoint(x: size.width / 2.0, y: 0.0)
        
        return backgroundNode1
    }()
    
    lazy var backgroundNode2 : SKSpriteNode = {
        let backgroundNode2 = SKSpriteNode(imageNamed: "BG_SpaceBattle_planet")
        backgroundNode2.size.width = frame.size.width/0.8
        backgroundNode2.size.height = frame.size.height
        backgroundNode2.anchorPoint = CGPoint(x: 0.5, y: 0.0)
        backgroundNode2.position = CGPoint(x: size.width / 2.0, y: backgroundNode1.size.height)
        
        return backgroundNode2
    }()
    
    lazy var playerNode : SKSpriteNode = {
        
        let playerNode = SKSpriteNode(imageNamed: "Player")
        
        playerNode.size = CGSize(width: self.size.width / 7, height: self.size.height / 14)
        playerNode.physicsBody = SKPhysicsBody(circleOfRadius: playerNode.size.width/2)
        playerNode.position = CGPoint(x: self.size.width / 2.0, y: self.size.height / 3.5)
        playerNode.physicsBody?.isDynamic = true
        playerNode.physicsBody?.affectedByGravity = false
        
        playerNode.physicsBody?.categoryBitMask = CollisionCategory.Player
        playerNode.physicsBody?.contactTestBitMask = CollisionCategory.Enemy
        playerNode.physicsBody?.collisionBitMask = 0
        
        playerNode.name = "PLAYER"
        
        return playerNode
    }()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(size: CGSize) {
        
        super.init(size: size)
        
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector(dx: 0.0, dy: -2.5)
        isUserInteractionEnabled = true
        
        
        addChild(backgroundNode1)
        addChild(backgroundNode2)
        addChild(playerNode)
        addChild(foregroundNode)
        
        playAudioFile(title: "spaceBattle", extOfFile: "mp3", howManyLoop: 4)

        timer = Timer.scheduledTimer(timeInterval: TimeInterval(1.5), target: self, selector: #selector(GameScene.addEnemy), userInfo: nil, repeats: true)
        
        
        coreMotionManager.accelerometerUpdateInterval = 0.2
        coreMotionManager.startAccelerometerUpdates()
     
        scoreSetting()
        
    }
    
    
    func playAudioFile(title: String, extOfFile: String, howManyLoop: Int) {
        
        let audioFileURL = Bundle.main.url(forResource: title, withExtension: extOfFile)
        
        if title == "spaceBattle" {
            do {
                try backgroundSoundPlayer = AVAudioPlayer(contentsOf: audioFileURL!)
            } catch let error {
                print(error.localizedDescription)
            }
            
            backgroundSoundPlayer.numberOfLoops = howManyLoop
            backgroundSoundPlayer.play()
        }
        else {
            do {
                try audioPlayer = AVAudioPlayer(contentsOf: audioFileURL!)
            } catch let error {
                print(error.localizedDescription)
            }
            
            audioPlayer.numberOfLoops = howManyLoop
            audioPlayer.play()
        }
        
        
    }
    
    
    func moveScene() {
        backgroundNode1.position = CGPoint(x: backgroundNode1.position.x, y: backgroundNode1.position.y - 1)
        backgroundNode2.position = CGPoint(x: backgroundNode2.position.x, y: backgroundNode2.position.y - 1)
        
//        foregroundNode.position = CGPoint(x: foregroundNode.position.x, y: foregroundNode.position.y - 4)
        
        if backgroundNode1.position.y <= -(backgroundNode1.size.height) {
            backgroundNode1.position = CGPoint(x: backgroundNode1.position.x, y: backgroundNode2.position.y + backgroundNode2.size.height)
        }
        
        if backgroundNode2.position.y <= -(backgroundNode2.size.height) {
            backgroundNode2.position = CGPoint(x: backgroundNode2.position.x, y: backgroundNode1.position.y + backgroundNode1.size.height)
        }
        
    }
    
    
    
    @objc func addEnemy() {
        
        let i = Int.random(in: 1...2)
        
        let imageName = "Enemy0\(i)"
        let enemyNode  = SKSpriteNode(imageNamed: imageName)
        enemyNode.size = CGSize(width: self.size.width / 7, height: self.size.height / 14)
        enemyNode.physicsBody = SKPhysicsBody(circleOfRadius: enemyNode.size.width / 2)
        enemyNode.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        enemyNode.zPosition   = 1
        enemyNode.name = "ENEMY"
        enemyNode.physicsBody?.isDynamic = false
        
        enemyNode.physicsBody?.categoryBitMask = CollisionCategory.Enemy
        enemyNode.physicsBody?.contactTestBitMask = CollisionCategory.Player | CollisionCategory.Bullet
        enemyNode.physicsBody?.collisionBitMask = 0
        
        var xPosition : CGFloat = 0.0
        xPosition = CGFloat.random(in: enemyNode.size.width/2...self.frame.size.width - (enemyNode.size.width/2))
        enemyNode.position = CGPoint(x: xPosition, y: self.frame.size.height + enemyNode.size.height * 2)
        
        enemyNode.physicsBody?.affectedByGravity = false
        
        let duration = CGFloat.random(in: CGFloat(7.0)...CGFloat(10.0))
        
        let actionDown = SKAction.move(to: CGPoint(x: xPosition, y: -self.frame.size.height), duration: TimeInterval(duration))
        enemyNode.run(SKAction.sequence([actionDown,
                                         SKAction.run({
                                            enemyNode.removeFromParent()
                                         })]))
        
        
        self.addChild(enemyNode)
        

    }
    
    
    
    @objc func bulletShot() {
        
        let bulletNode = SKSpriteNode(imageNamed: "BulletBlue")
        bulletNode.position.x = playerNode.position.x
        bulletNode.position.y = playerNode.position.y + playerNode.size.height
        bulletNode.zPosition = 1
        
        bulletNode.physicsBody = SKPhysicsBody(circleOfRadius: bulletNode.size.width / 2)
        bulletNode.physicsBody?.affectedByGravity = false
        
        bulletNode.physicsBody?.categoryBitMask   = CollisionCategory.Bullet
        bulletNode.physicsBody?.contactTestBitMask = CollisionCategory.Enemy
        bulletNode.physicsBody?.collisionBitMask = 0
        
        bulletNode.physicsBody?.usesPreciseCollisionDetection = true
        
        
        let moveTo = CGPoint(x: playerNode.position.x, y: playerNode.position.y + self.frame.size.height)
        
        
        let trailNode = SKNode()
        trailNode.zPosition = 1
        addChild(trailNode)
        
        let emitterNode = SKEmitterNode(fileNamed: "ShootTrailBlue")!
        emitterNode.targetNode = trailNode
        bulletNode.addChild(emitterNode)
        
        bulletNode.run(SKAction.sequence([
            SKAction.move(to: moveTo, duration: TimeInterval(0.4)),
            SKAction.run({
                bulletNode.removeAllChildren()
                bulletNode.removeFromParent()
                trailNode.removeFromParent()
            })]))
        
        
        
        self.addChild(bulletNode)
//        playAudioFile(title: "torpedo", extOfFile: "mp3", howManyLoop: 0)
        
    }
    
    
    
    func enemyHitBullet(nodeA : SKSpriteNode, nodeB : SKSpriteNode){
        
        cScore += 1
        UserDefaults.standard.set(cScore, forKey: "CURRENTSCORE")
        
        if cScore > hScore {
            hScore = cScore
            UserDefaults.standard.set(cScore, forKey: "HIGHSCORE")
        }
        
        if nodeA.physicsBody?.categoryBitMask == CollisionCategory.Bullet {
            nodeA.removeAllChildren()
            nodeA.isHidden = true
            nodeA.physicsBody?.categoryBitMask = 0
            nodeB.removeFromParent()
            
            let explosion = SKEmitterNode(fileNamed: "ExplosionBlue")!
            explosion.position = nodeA.position
            self.addChild(explosion)
            
            explosion.run(SKAction.sequence([
                SKAction.wait(forDuration: 0.3),
                SKAction.run {
                    explosion.removeFromParent()
                }]))
            
        }else if nodeB.physicsBody?.categoryBitMask == CollisionCategory.Bullet {
            nodeA.removeFromParent()
            nodeB.removeAllChildren()
            nodeB.isHidden =  true
            nodeB.physicsBody?.categoryBitMask = 0
            
            let explosion = SKEmitterNode(fileNamed: "ExplosionBlue")!
            explosion.position = nodeB.position
            self.addChild(explosion)
            
            explosion.run(SKAction.sequence([
                SKAction.wait(forDuration: 0.3),
                SKAction.run {
                    explosion.removeFromParent()
                }]))
        }
    }
    
    // MARK: 外星人Alien撞击到飞船
    func enemyHitPlayer(nodeA : SKSpriteNode, nodeB : SKSpriteNode){
        
        if (nodeA.physicsBody?.categoryBitMask == CollisionCategory.Enemy  || nodeB.physicsBody?.categoryBitMask == CollisionCategory.Enemy) && (nodeA.physicsBody?.categoryBitMask == CollisionCategory.Player || nodeB.physicsBody?.categoryBitMask == CollisionCategory.Player) {
            
            playAudioFile(title: "explosion", extOfFile: "mp3", howManyLoop: 0)
            
            let explosion = SKEmitterNode(fileNamed: "Explosion")!
            explosion.position = playerNode.position
            self.addChild(explosion)
            
            nodeA.removeFromParent()
            nodeB.removeFromParent()

            stopAction()

            let reveal = SKTransition.fade(withDuration: TimeInterval(2.0))
            let menuScene = MenuScene(size: size)
            menuScene.size = self.size
            menuScene.scaleMode = .aspectFill
            
            
            self.run(SKAction.sequence([
                SKAction.wait(forDuration: TimeInterval(0.7)),
                SKAction.run {
                    self.view?.presentScene(menuScene, transition: reveal)
                }]))

            cScore = 0
            UserDefaults.standard.set(0, forKey: "CURRENTSCORE")
            
        }
        
    }
    
    
    func stopAction() {
        timer.invalidate()
        enumerateChildNodes(withName: "ENEMY", using: ({
            (node, error) in
            node.removeAllActions()
            node.removeFromParent()
        }))
        stopOrder = 1
        backgroundSoundPlayer.stop()
    }
    
    
    func scoreSetting(){
        
        currentScore.text = "SCORE : \(cScore)"
        currentScore.fontSize = 20
        currentScore.fontColor = SKColor.white
        currentScore.position = CGPoint(x: 10, y: size.height - 20)
        currentScore.horizontalAlignmentMode = .left
        addChild(currentScore)
        
        highScore.text = "HIGH : \(hScore)"
        highScore.fontSize = 20
        highScore.fontColor = SKColor.white
        highScore.position = CGPoint(x: size.width - 10, y: size.height - 20)
        highScore.horizontalAlignmentMode = .right
        addChild(highScore)
        
        
        cScore = UserDefaults.standard.integer(forKey: "CURRENTSCORE")
        hScore = UserDefaults.standard.integer(forKey: "HIGHSCORE")
        
        if !UserDefaults.standard.bool(forKey: "HIGHSCORE") {
            UserDefaults.standard.set(0, forKey: "HIGHSCORE")
        }
        
        UserDefaults.standard.set(0, forKey: "CURRENTSCORE")
        
    }
    
    func scoreUpdate(){
        highScore.text = "HIGH : \(hScore)"
        currentScore.text = "SCORE : \(cScore)"
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if stopOrder == 0 {
            
            playAudioFile(title: "torpedo", extOfFile: "mp3", howManyLoop: 0)
            bulletShot()

        }
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if stopOrder == 0 {
            
            
            guard let touch = touches.first else {
                return
            }
            
            let touchLocation = touch.location(in: self)
            
            if backgroundNode1.contains(touchLocation) || backgroundNode2.contains(touchLocation) {
                
                bulletShot()
                
            }
            
            
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    
    override func didSimulatePhysics() {
       
        if let accelerometerData = coreMotionManager.accelerometerData {
            
                playerNode.physicsBody!.velocity = CGVector(dx: CGFloat(accelerometerData.acceleration.x * 580.0), dy: 0)
            
        }
        
        if playerNode.position.x < -(playerNode.size.width / 2) {
            
            playerNode.position = CGPoint(x: size.width - playerNode.size.width / 2, y: playerNode.position.y);
        }
            
        else if playerNode.position.x > size.width + (playerNode.size.width / 2) {
            
            playerNode.position = CGPoint(x: playerNode.size.width / 2, y: playerNode.position.y);
        }
    }
    
    
    
    deinit {
        coreMotionManager.stopAccelerometerUpdates()
    }
        
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        let contactBody = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        // contactBody will receive value from bodyA and bodyB, so in switch case, if the value is same like Enemy + Bullet = 12, it will doing by same condition and also if the value is same like Enemy + Player = 6 .
        
//        print(CollisionCategory.Enemy | CollisionCategory.Bullet)
//        print(CollisionCategory.Enemy | CollisionCategory.Player)
        
        switch contactBody {
            
        case CollisionCategory.Enemy | CollisionCategory.Bullet :
            enemyHitBullet(nodeA: contact.bodyA.node as! SKSpriteNode,nodeB: contact.bodyB.node as! SKSpriteNode)
            
        case CollisionCategory.Enemy | CollisionCategory.Player :
            enemyHitPlayer(nodeA: contact.bodyA.node as! SKSpriteNode,nodeB: contact.bodyB.node as! SKSpriteNode)
            
        default:
            break
            
        }
    }
    
    
    override func didMove(to view: SKView) {
        
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        if stopOrder == 0 {
            moveScene()
            scoreUpdate()
        }
        
    }
}
