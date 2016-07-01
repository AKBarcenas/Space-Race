//
//  GameScene.swift
//  Space Race
//
//  Created by Alex on 6/30/16.
//  Copyright (c) 2016 Alex Barcenas. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    // The starfield in the background.
    var starfield: SKEmitterNode!
    // The sprite representing the user.
    var player: SKSpriteNode!
    
    // Displays the user's score.
    var scoreLabel: SKLabelNode!
    // Keeps track of the user's score.
    var score: Int = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    // Names for all possible enemies.
    var possibleEnemies = ["ball", "hammer", "tv"]
    // A timer for the game.
    var gameTimer: NSTimer!
    // Keeps track of whether or not the game has ended.
    var gameOver = false
    
    /*
     * Function Name: didMoveToView
     * Parameters: view - the view that called this method.
     * Purpose: This method sets up the visual environment of the game and starts the enemy creation.
     * Return Value: None
     */
    
    override func didMoveToView(view: SKView) {
        backgroundColor = UIColor.blackColor()
        
        starfield = SKEmitterNode(fileNamed: "Starfield")!
        starfield.position = CGPoint(x: 1024, y: 384)
        starfield.advanceSimulationTime(10)
        addChild(starfield)
        starfield.zPosition = -1
        
        player = SKSpriteNode(imageNamed: "player")
        player.position = CGPoint(x: 100, y: 384)
        player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.size)
        player.physicsBody!.contactTestBitMask = 1
        addChild(player)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.position = CGPoint(x: 16, y: 16)
        scoreLabel.horizontalAlignmentMode = .Left
        addChild(scoreLabel)
        
        score = 0
        
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self
        
        gameTimer = NSTimer.scheduledTimerWithTimeInterval(0.35, target: self, selector: #selector(createEnemy), userInfo: nil, repeats: true)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    }
   
    /*
     * Function Name: update
     * Parameters: currentTime - the current system time.
     * Purpose: This method updates the score as long as the game is not over and removes enemies that
     *   are no longer needed.
     * Return Value: None
     */
    
    override func update(currentTime: CFTimeInterval) {
        for node in children {
            if node.position.x < -300 {
                node.removeFromParent()
            }
        }
        
        if !gameOver {
            score += 1
        }
    }
    
    /*
     * Function Name: createEnemy
     * Parameters: None
     * Purpose: This method randomly selects an enemy type and randomly places it on the right side
     *   of the screen. The enemy is also given a horizontal velocity and angular velocity.
     * Return Value: None
     */
    
    func createEnemy() {
        possibleEnemies = GKRandomSource.sharedRandom().arrayByShufflingObjectsInArray(possibleEnemies) as! [String]
        let randomDistribution = GKRandomDistribution(lowestValue: 50, highestValue: 736)
        
        let sprite = SKSpriteNode(imageNamed: possibleEnemies[0])
        sprite.position = CGPoint(x: 1200, y: randomDistribution.nextInt())
        addChild(sprite)
        
        sprite.physicsBody = SKPhysicsBody(texture: sprite.texture!, size: sprite.size)
        sprite.physicsBody?.categoryBitMask = 1
        sprite.physicsBody?.velocity = CGVector(dx: -500, dy: 0)
        sprite.physicsBody?.angularVelocity = 5
        sprite.physicsBody?.linearDamping = 0
        sprite.physicsBody?.angularDamping = 0
    }
    
    /*
     * Function Name: touchesMoved
     * Parameters: touches - the touches that occurred during the event.
     *   event - the event that describes the touches.
     * Purpose: This method moves the player as long as the movement is within the bounds of the game.
     * Return Value: None
     */
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        guard let touch = touches.first else { return }
        var location = touch.locationInNode(self)
        
        if location.y < 100 {
            location.y = 100
        } else if location.y > 668 {
            location.y = 668
        }
        
        player.position = location
    }
    
    /*
     * Function Name: didBeginContact
     * Parameters: contact - describes the contact that occurred.
     * Purpose: This method causes the player to explode when a collision with debris occurs and
     *   ends the game.
     * Return Value: None
     */
    
    func didBeginContact(contact: SKPhysicsContact) {
        let explosion = SKEmitterNode(fileNamed: "explosion")!
        explosion.position = player.position
        addChild(explosion)
        
        player.removeFromParent()
        
        gameOver = true
    }
    
}
