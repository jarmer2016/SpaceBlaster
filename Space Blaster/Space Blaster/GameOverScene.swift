//
//  GameOverScene.swift
//  Space Blaster
//
//  Created by James Armer on 15/10/2020.
//

import Foundation
import SpriteKit

class GameOverScene: SKScene{
    
    let restartLabel = SKLabelNode(fontNamed: "The Bold Font")
    let restartButtonSound = SKAction.playSoundFileNamed("RestartButtonClickSound.m4a", waitForCompletion: false)        //creating the Button Sound Action
    
    let gameOverLabel = SKLabelNode(fontNamed: "The Bold Font")
    
    override func didMove(to view: SKView) {
        
        
        
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        background.zPosition = 0
        self.addChild(background)
        
       
        gameOverLabel.text = "Game Over"
        gameOverLabel.fontSize = 200
        gameOverLabel.fontColor = SKColor.white
        gameOverLabel.position = CGPoint(x: self.size.width*0.5, y: self.size.height*0.7)
        gameOverLabel.zPosition = 1
        self.addChild(gameOverLabel)
        
        let scoreLabel = SKLabelNode(fontNamed: "The Bold Font")
        scoreLabel.text = "Score: \(gameScore)"
        scoreLabel.fontSize = 125
        scoreLabel.fontColor = SKColor.white
        scoreLabel.position = CGPoint(x: self.size.width/2, y: self.size.height*0.55)
        scoreLabel.zPosition = 1
        self.addChild(scoreLabel)
        
        
       
        let defaults = UserDefaults()
        var highScoreNumber = defaults.integer(forKey: "highScoreSaved")
        
        if gameScore > highScoreNumber {
            
            addHighScoreEmitter()
            
            gameOverLabel.text = "New High Score!"
            gameOverLabel.fontColor = SKColor.red
            gameOverLabel.fontSize = 150
            highScoreNumber = gameScore
            defaults.set(highScoreNumber, forKey: "highScoreSaved")
        }else{
            
            addGameOverEmitter()
            
            gameOverLabel.text = "Game Over"
            gameOverLabel.fontSize = 200
            gameOverLabel.fontColor = SKColor.white
        }
        
        let highScoreLabel = SKLabelNode(fontNamed: "The Bold Font")
        highScoreLabel.text = "High Score: \(highScoreNumber)"
        highScoreLabel.fontSize = 125
        highScoreLabel.fontColor = SKColor.white
        highScoreLabel.position = CGPoint(x: self.size.width/2, y: self.size.height*0.45)
        highScoreLabel.zPosition = 1
        addChild(highScoreLabel)
        
        
        
        
        restartLabel.text = "Restart"
        restartLabel.fontSize = 90
        restartLabel.fontColor = SKColor.yellow
        restartLabel.position = CGPoint(x: self.size.width/2, y: self.size.height*0.3)
        restartLabel.zPosition = 1
        addChild(restartLabel)
        
        
    }
    
    func addGameOverEmitter() {
        let emitter = SKEmitterNode(fileNamed: "magic.sks")
        emitter!.zPosition = 0
        emitter?.position = CGPoint(x: self.size.width/2, y: self.size.height)
        addChild(emitter!)
    }
    
    func addHighScoreEmitter() {
        let emitter = SKEmitterNode(fileNamed: "highscore.sks")
        emitter!.zPosition = 0
        emitter?.position = CGPoint(x: self.size.width/2, y: self.size.height*0.9)
        addChild(emitter!)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch: AnyObject in touches{
            
            let pointOfTouch = touch.location(in: self)
            
            if restartLabel.contains(pointOfTouch){
                
                
                
                run(restartButtonSound)
                let sceneToMoveTo = GameScene(size: self.size)
                sceneToMoveTo.scaleMode = self.scaleMode
                let myTransition = SKTransition.fade(withDuration: 0.5)
                self.view!.presentScene(sceneToMoveTo, transition: myTransition)
   
                
            }
          
        }
}

}
