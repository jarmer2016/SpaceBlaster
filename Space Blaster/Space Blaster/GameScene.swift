//
//  GameScene.swift
//  Space Blaster
//
//  Created by James Armer on 14/10/2020.
//

import SpriteKit
import GameplayKit

var gameScore = 0                                                                          //Game Score created globally so it can be setup in didMove(to view: ), but edited elsewhere




class GameScene: SKScene, SKPhysicsContactDelegate {                                        //SpriteKit Scene, and SpriteKit Physics Contact Delegate for collisons
    
    var levelNumber = 0                                                                     //creating Level Number variable for game logic and setting to 0
    var livesNumber = 3                                                                     //creating Lives Number variable for HUD and setting to 3

    let livesLabel = SKLabelNode(fontNamed: "The Bold Font")                                //creating the Lives Label Sprite Node
    let scoreLabel = SKLabelNode(fontNamed: "The Bold Font")                                //creating the Score Label Sprite Node
    
    let player = SKSpriteNode(imageNamed: "playerShip")                                     //creating the Player Spaceship Sprite Node
    
    let bulletSound = SKAction.playSoundFileNamed("FireSound.m4a", waitForCompletion: false)                    //creating the Bullet Sound Action
    let explosionSound = SKAction.playSoundFileNamed("ExplosionSound.m4a", waitForCompletion: false)            //creating the Explosion Sound Action

    
    
    enum gameState{
        case preGame                                                                         //when the game state is before the start of the game
        case inGame                                                                          //when the game state is during the game
        case afterGame                                                                       //when the game state is after the game
        
    }
    
    
    
    
    var currentGameState = gameState.inGame                                                  //set gameState to inGame
    
    
    struct PhysicsCategories{                                                               //setting up PhysicsCategories to categorise physicsBodies
        static let None : UInt32 = 0                                                        //0
        static let Player : UInt32 = 0b1                                                    //1
        static let Bullet : UInt32 = 0b10                                                   //2
        static let Enemy : UInt32 = 0b100                                                   //4 <- 4 is used because 3 would be Player AND Bullet
        
    }
    
    
    func random() -> CGFloat {                                                              //creating a random functions that will be used in spawning enemies
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)                                    //
    }                                                                                       //
    func random(min: CGFloat, max: CGFloat) -> CGFloat {                                    //
        return random() * (max - min) + min                                                 //
    }                                                                                       //
    
    
    
    
    var gameArea: CGRect                                                                        //creating the game area variable
                                                                                                
    override init(size: CGSize) {                                                               //creating the playable area
                                                                                                //
        let maxAspectRatio: CGFloat = 16.0/9.0                                                  //
        let playableWidth = size.height / maxAspectRatio                                        //
        let margin = (size.width - playableWidth) / 2                                           //
        gameArea = CGRect(x: margin, y: 0, width: playableWidth, height: size.height)
        
        //
                                                                                                //
        super.init(size: size)                                                                  //
    }                                                                                           //
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func didMove(to view: SKView) {                                                //function called when the view is displayed on the screen
        
        
        gameScore = 0                                                                       //set gameScore to 0
        
        self.physicsWorld.contactDelegate = self                                            //contact physics setup
        
        let background = SKSpriteNode(imageNamed: "background")                             //creating the background Sprite Node
        background.size = self.size                                                         //set the size of the background to be the same as the view
        print(background.size)
        background.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)      //setting the position of the background to the center of the view
        background.zPosition = 0                                                            //zPosition is 0 so that it will be the bottom layer
        self.addChild(background)                                                           //adds background
        
       
        player.setScale(1)                                                                  //creating a scale so it can be adjusted later if needs be
        player.position = CGPoint(x: self.size.width/2, y: self.size.height * 0.1)          //setting the position to be centered horizontally, and 10% up from the bottom vertically
        player.zPosition = 2                                                                //zPosition is 2, because bullets will be set to 1 so they emerge from underneath the spaceship
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)                        //creating a physicsBody rectangle around player (which will be used for collision)
        player.physicsBody!.affectedByGravity = false                                       //player physicsBody not affected by gravity
        player.physicsBody!.categoryBitMask = PhysicsCategories.Player                      //assigned physicsBody of player into the category of Player
        player.physicsBody!.collisionBitMask = PhysicsCategories.None                       //set physicsBody of player to collide with None (to stop bouncing/moving in different direction)
        player.physicsBody!.contactTestBitMask = PhysicsCategories.Enemy                    //sets physicsBody of player to make contact with Enemy (when contact happens, we will run code)
        self.addChild(player)                                                               //adds player
        
        scoreLabel.text = "Score: 0"                                                        //set default text on load
        scoreLabel.fontSize = 70                                                            //set font size to 70
        scoreLabel.fontColor = SKColor.white                                                //set font colour to white
        scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left            //align label to horizontal left
        scoreLabel.position = CGPoint(x: self.size.width*0.15, y: self.size.height*0.9)     //setting the position | x =  15% view across width, y = 90% up view height
        scoreLabel.zPosition = 100                                                          //setting the zPosition to 100 so it will be at the top layer of the view
        self.addChild(scoreLabel)                                                           //adds scoreLabel
        
        
        livesLabel.text = "Lives: 3"                                                        //set default text on load
        livesLabel.fontSize = 70                                                            //set font size to 70
        livesLabel.fontColor = SKColor.white                                                //set font colour to white
        livesLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.right           //align label to horizontal right
        livesLabel.position = CGPoint(x: self.size.width*0.85, y: self.size.height*0.9)     //setting the position | x = 85% across view width, y = 90% up view height
        livesLabel.zPosition = 100                                                          //setting the zPosition to 100 so it will be at the top layer of the view
        self.addChild(livesLabel)                                                           //adds livesLabel
        
        startNewLevel()                                                                     //start new level / begin game
    }
    
    func loseALife(){                                                                       //function to lose a life
        
        livesNumber -= 1                                                                    //decrement livesNumber by 1
        livesLabel.text = "Lives: \(livesNumber)"                                           //update liveLabel text
        
        let scaleUp = SKAction.scale(to: 1.5, duration: 0.2)                                //assign scale to 1.5 action to scaleUp, with a duration of 0.2
        let scaleDown = SKAction.scale(to: 1, duration: 0.2)                                //assign scale to 1 action to scaleDown, with a duration of 0.2
        let scaleSequence = SKAction.sequence([scaleUp,scaleDown])                          //create sequence of scale up and scale down
        livesLabel.run(scaleSequence)                                                       //runs the livesLabel animation sequence
        
        if livesNumber == 0{                                                                //if livesNumber is equal to 0, run the game over function
            runGameOver()
        }
    }
    
    func addScore() {                                                                       //function to add to score
        
        gameScore += 1                                                                      //increment gameScore by 1
        scoreLabel.text = "Score: \(gameScore)"                                             //update scoreLabel text
        
        if gameScore == 10 || gameScore == 25 || gameScore == 50{
            startNewLevel()
        }
    }
    
    
    func runGameOver(){                                                                     //Game Over function
        
        
        currentGameState = gameState.afterGame                                              //change the gameState to afterGame
        
        self.removeAllActions()                                                             //remove all actions
        
        self.enumerateChildNodes(withName: "Bullet"){                                       //go through all bullets and stop
            bullet, stop in
   
            bullet.removeAllActions()                                                       //remove bullet actions
        }
        
        self.enumerateChildNodes(withName: "Enemy"){                                        //go through all enemies and stop
            enemy, stop in
            
            enemy.removeAllActions()                                                        //remove enemy actions
        }
        
        
        let changeSceneAction = SKAction.run(changeScene)                                   //assign run changeScene action to ChangeSceneAction
        let waitToChangeScene = SKAction.wait(forDuration: 1)                               //assign wait action to waitToChangeScene with a duraction of 1
        let changeSceneSequence = SKAction.sequence([waitToChangeScene, changeSceneAction]) //create sequence of waitToChangeScene and changeSceneAction, to have a slight pause before transitioning scenes
        self.run(changeSceneSequence)                                                       //run changeSceneSequence
    }
    
    
    func changeScene(){                                                                     //function to change scenes
        
        let sceneToMoveTo = GameOverScene(size: self.size)                                  //assign GameOverScene to sceneToMoveTo, which the size of self.size
        sceneToMoveTo.scaleMode = self.scaleMode                                            //set sceneToMoveTo's scale mode to be the same as self's
        let myTransition = SKTransition.fade(withDuration: 0.5)                             //create fade transition with duration of 0.5 and assign it to myTransition
        self.view!.presentScene(sceneToMoveTo, transition: myTransition)                    //current view change to GameOverScene, using the transition myTransition
        
    }
    
    
    
    func didBegin(_ contact: SKPhysicsContact) {                                            //function that runs if contact between phsyicsBodys did begin
                                                                                            //contact: has all the information about the contact, which conains the two physicsBodies which touched, bodyA and bodyB
                                                                                            //however, they aren't passed in  a particular order, so bodyA could be the Bullet, it it could be the enemy
                                                                                            //Therefore, I will organise them numerically by using the PhysicsCategories
        
        var body1 = SKPhysicsBody()                                                         //creating a physicsBody called body1 to be used for organising
        var body2 = SKPhysicsBody()                                                         //creating a physicsBody called body2 to be used for organising
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask{                   //if bodyA's categoryNumber is less than bodyB's, they are already in numerical order
            body1 = contact.bodyA                                                           //body1 = bodyA
            body2 = contact.bodyB                                                           //body2 = bodyB
        }
        else{                                                                               //otherwise, flip them around
            body1 = contact.bodyB                                                           //set body1 = bodyB
            body2 = contact.bodyA                                                           //set body2 = bodyA
            
        }
            
        
        //NOTE: Opptionals are used to prevent crashing when removing node from parent in the event there isn't a node there.
        //This could happen if 2 bullets hit the enemy at the same time. The second bullet would cause the game to crash if it tried to remove
        //a node that wasn't there, so we use an option to check if there is a node there first, and if so, remove it
        
            if body1.categoryBitMask == PhysicsCategories.Player && body2.categoryBitMask == PhysicsCategories.Enemy{       //if player and enemy hit
               
                if body1.node != nil {                                                      //checks there is still a node there
                spawnExplosion(spawnPosition: body1.node!.position)                         //spawn explosion at player (body1) position
                }
                
                if body2.node != nil {                                                      //checks theres still a node there
                spawnExplosion(spawnPosition: body2.node!.position)                         //spawn explosion at enemy (body2) position
                }
                body1.node?.removeFromParent()                                              //delete the player (optional incase there isn't a node)
                body2.node?.removeFromParent()                                              //delete the enemy  (optional incase there isn't a node)
                
                
                runGameOver()                                                               //run Game Over funtion (for instant death //going to change)
                
            }
        
            if body1.categoryBitMask == PhysicsCategories.Bullet && body2.categoryBitMask == PhysicsCategories.Enemy{       //if bullet and enemy hit
                //if the bullet has hit the enemy
                
                addScore()                                                                  //run addScore() to increment the players score
                
                if body2.node != nil {                                                      //checks theres still a node there
                    if body2.node!.position.y > self.size.height{                           //if the enemy is above the top of the visable screen
                        return                                                              //don't show anything
                    }
                    else{                                                                   //else if it is on the viewable screen
                        spawnExplosion(spawnPosition: body2.node!.position)                 //spawn an explosion at the enemies positon
                    }
                }
    
                body1.node?.removeFromParent()                                              //delete the bullet (optional incase there isn't a node)
                body2.node?.removeFromParent()                                              //delete the enemy  (optional incase there isn't a node)
        }
        
    }
    
    func spawnExplosion(spawnPosition: CGPoint){
        let explosion = SKSpriteNode(imageNamed: "explosion")                                           //creating explosion Sprite Node
        explosion.position = spawnPosition                                                              //setting the position of the explosion
        explosion.zPosition = 3                                                                         //setting zPosition to 3 so it will appear above enemies and player ship
        explosion.setScale(1)                                                                           //default scale
        self.addChild(explosion)                                                                        //adds explosion
        
        let scaleIn = SKAction.scale(by: 2, duration: 0.1 )                                             //scales up by 2 with a duration of 0.1
        let fadeOut = SKAction.fadeOut(withDuration: 0.1)                                               //fade out with duration of 0.1
        let delete = SKAction.removeFromParent()                                                        //assigning removeFromParent action to delete
        
        let explosionSequence = SKAction.sequence([explosionSound, scaleIn, fadeOut, delete])           //creating explosionSequence to play explosion sound, animate in with scale, animate out with fade, and then delete explosion node
        
        explosion.run(explosionSequence)                                                                //run explosionSequence
    }
    
    
    func fireBullet() {                                                                                 //function to fire a bullet
        
        let bullet = SKSpriteNode(imageNamed: "bullet")                                                 //creating bullet Sprite Node
        bullet.name = "Bullet"                                                                          //assigning the name Bullet
        bullet.setScale(0.5)                                                                            //setting the default scale
        bullet.position.x = player.position.x                                                           //setting bullets x position to be the same as the player
        bullet.position.y = player.position.y + player.size.height/2                                    //setting bullets y possition to be at the top of the player
        bullet.zPosition = 1                                                                            //zPosition of 1 so it will appear from under the players ship
        bullet.physicsBody = SKPhysicsBody(rectangleOf: bullet.size)                                    //creating a physicBody rectangle around bullet (which will be used for collision)
        bullet.physicsBody!.affectedByGravity = false                                                   //Bullet physicsBody not affacted by gravity
        bullet.physicsBody!.categoryBitMask = PhysicsCategories.Bullet                                  //assigned physicsBody of bullet into the category of Bullet
        bullet.physicsBody!.collisionBitMask = PhysicsCategories.None                                   //set physicsBody of bullet to collide with None (to stop bouncing/moving in different direction)
        bullet.physicsBody!.contactTestBitMask = PhysicsCategories.Enemy                                //sets physicsBody of bullet to make contact with Enemy (when contact happens, we will run code)
        self.addChild(bullet)                                                                           //adds bullet
        
        let moveBullet = SKAction.moveTo(y: self.size.height + bullet.size.height, duration: 1)         //setting moveTo action to moveBullet with a duration of 1. Moves the height of the view + bullet height.
        let deleteBullet = SKAction.removeFromParent()                                                  //assigning removeFromParent action to deleteBullet (for use in sequence)
        
        let bulletSequence = SKAction.sequence([bulletSound, moveBullet, deleteBullet])                 //creating bulletSequence which plays bullet sound, moves the bullet and then deletes it
        bullet.run(bulletSequence)                                                                      //runs bulletSequence
        
        
    }
    
    
    func spawnEnemy(){                                                                                  //function to spawn an enemy
            
        let randomXStart = random(min: gameArea.minX, max: gameArea.maxX)                               //creates a random start location within the gameArea
        let randomXEnd = random(min: gameArea.minX, max: gameArea.maxX)                                 //creates a random end locaton ithin the gameArea
        
        let startPoint = CGPoint(x: randomXStart, y: self.size.height * 1.2)                            //sets the enemy start point using the random start location
        let endPoint = CGPoint(x: randomXEnd, y: -self.size.height * 0.2)                               //sets the enemy end point using the random end location
        
        let enemy = SKSpriteNode(imageNamed: "enemyShip")                                               //creating enemyShip Sprite Node
        enemy.name = "Enemy"                                                                            //assigning name of Enemy
        enemy.setScale(1)                                                                               //setting the default scale
        enemy.position = startPoint                                                                     //setting to position to randomly generated startPoint
        enemy.zPosition = 2                                                                             //setting zPosition of 2 so its on the
        enemy.physicsBody = SKPhysicsBody(rectangleOf: enemy.size)                                      //creating a physicsBody rectangle around enemy (which will be used for collision)
        enemy.physicsBody!.affectedByGravity = false                                                    //enemy physicsBody not affected by gravity
        enemy.physicsBody!.categoryBitMask = PhysicsCategories.Enemy                                    //assigned physicsBody of enemy into the category of Enemy
        enemy.physicsBody!.collisionBitMask = PhysicsCategories.None                                    //set physicsBody of enemy to collide with None (to stop bouncing/moving in different direction)
        enemy.physicsBody!.contactTestBitMask = PhysicsCategories.Player | PhysicsCategories.Bullet     //sets physicsBody of enemy to make contact with Player and Bullet (when contact happens, we will run code)
        self.addChild(enemy)                                                                            //adds enemy
        
        let moveEnemy = SKAction.move(to: endPoint, duration: 2)                                        //setting moveTo action to moveEnemy with a duration of 2. Moves to the randomly generated endPoint
        let deleteEnemy = SKAction.removeFromParent()                                                   //assigning removeFromParent to deleteEnemy (for use in sequence)
        let loseALifeAction = SKAction.run(loseALife)                                                   //assigning run loseALife action to loseALifeAction (for use in sequence)
        let enemySequence = SKAction.sequence([moveEnemy, deleteEnemy, loseALifeAction])                //creating enemySequence which moves the enemy, deletes it and runs the loseALife action
        
        
        if currentGameState == gameState.inGame{
        enemy.run(enemySequence)
        }
        
        let dx = endPoint.x - startPoint.x
        let dy = endPoint.y - startPoint.y
        let amountToRotate = atan2(dy, dx)
        enemy.zRotation = amountToRotate
    }
    
    
    
    func startNewLevel(){
        
        levelNumber += 1
        
        if self.action(forKey: "spawningEnemies") != nil{
            self.removeAction(forKey: "spawningEnemies")
        }
        
        var levelDuration = TimeInterval()
        
        switch levelNumber {
        case 1: levelDuration = 1.2
        case 2: levelDuration = 1
        case 3: levelDuration = 0.8
        case 4: levelDuration = 0.5
        default:
            levelDuration = 0.5
            print("Cannot find level info")
        }
        
        let spawn = SKAction.run(spawnEnemy)
        let waitToSpawn = SKAction.wait(forDuration: levelDuration)
        let spawnSequence = SKAction.sequence([waitToSpawn, spawn])
        let spawnForever = SKAction.repeatForever(spawnSequence)
        self.run(spawnForever, withKey: "spawningEnemies")
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {                             //runs if a touch on the screen began
        
        if currentGameState == gameState.inGame{                                                            //checks if we're inGame
        fireBullet()                                                                                        //if so, fire a bullet
        }
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch: AnyObject in touches{
            
            let pointOfTouch = touch.location(in: self)
            let previousPointOfTouch = touch.previousLocation(in: self)
            
            let amountDragged = pointOfTouch.x - previousPointOfTouch.x
            
            if currentGameState == gameState.inGame{
            player.position.x  += amountDragged
            }
                
                
            if player.position.x > gameArea.maxX - player.size.width/2 {
                player.position.x = gameArea.maxX - player.size.width/2
            }
            
            if player.position.x < gameArea.minX + player.size.width/2{
                player.position.x = gameArea.minX + player.size.width/2
            }
            
        }
    }
}
