//
//  MenuScene.swift
//  SpaceBattleZ
//
//  Created by Zaen on 12/9/18.
//  Copyright © 2018 Zaen. All rights reserved.
//

import SpriteKit

class MenuScene : SKScene {
    private var play : SKSpriteNode!
    private var currentScore = SKLabelNode(fontNamed: "Copperplate")
    private var highScore = SKLabelNode(fontNamed: "Copperplate")
    let background = SKSpriteNode(imageNamed: "BG_SpaceBattle_planet")
    
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
    }
    
    override init(size: CGSize) {
        
        super.init(size: size)
        
        background.size.width = frame.size.width/0.8
        background.size.height = frame.size.height
        background.anchorPoint = CGPoint(x: 0.5, y: 0.0)
        background.position = CGPoint(x: size.width / 2.0, y: 0.0)
        addChild(background)
        
        currentScore.text = "SCORE : \(UserDefaults.standard.integer(forKey: "CURRENTSCORE"))"
        currentScore.fontSize = 20
        currentScore.fontColor = SKColor.white
        currentScore.position = CGPoint(x: size.width/2, y: size.height/2)
        currentScore.horizontalAlignmentMode = .center
        addChild(currentScore)
        
        highScore.text = "HIGH : \(UserDefaults.standard.integer(forKey: "HIGHSCORE"))"
        highScore.fontSize = 20
        highScore.fontColor = SKColor.white
        highScore.position = CGPoint(x: size.width/2, y: size.height/2.5)
        highScore.horizontalAlignmentMode = .center
        addChild(highScore)
        
        play = SKSpriteNode(imageNamed: "playButton")
        play.size = CGSize(width: size.width/2, height: size.height/8)
        play.position = CGPoint(x: size.width/2, y: size.height/1.5)
        addChild(play)
        
    }

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        let touchLocation = touch.location(in: self)
        
        if play.contains(touchLocation) {
            let reveal = SKTransition.doorsOpenVertical(withDuration: TimeInterval(0.5))
            let scene = GameScene(size: size)
            scene.size = self.size
            scene.scaleMode = .aspectFill
            self.view?.presentScene(scene, transition: reveal)
        }
    }
    
}

