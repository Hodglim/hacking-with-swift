//
//  GameScene.swift
//  SwiftyNinja
//
//  Created by Darren Hodges on 24/06/2016.
//  Copyright (c) 2016 Darren Hodges. All rights reserved.
//

import SpriteKit
import AVFoundation

enum SequenceType: Int
{
	case OneNoBomb, One, TwoWithOneBomb, Two, Three, Four, Chain, FastChain
}

enum ForceBomb
{
	case Never, Always, Default
}

class GameScene: SKScene
{
	var gameScore: SKLabelNode!
	var score: Int = 0 {
		didSet {
			gameScore.text = "Score: \(score)"
		}
	}
	
	var livesImages = [SKSpriteNode]()
	var lives = 3
	
	var activeSliceBG: SKShapeNode!
	var activeSliceFG: SKShapeNode!
	var activeSlicePoints = [CGPoint]()
	
	var swooshSoundActive = false
	var bombSoundEffect: AVAudioPlayer!
	
	var activeEnemies = [SKSpriteNode]()
	
	var popupTime = 0.9
	var sequence: [SequenceType]!
	var sequencePosition = 0
	var chainDelay = 3.0
	var nextSequenceQueued = true
	
	var gameEnded = false
	
    override func didMoveToView(view: SKView)
	{
		let background = SKSpriteNode(imageNamed: "sliceBackground")
		background.position = CGPoint(x: 512, y: 384)
		background.blendMode = .Replace
		background.zPosition = -1
		addChild(background)
		
		physicsWorld.gravity = CGVector(dx: 0, dy: -6)
		physicsWorld.speed = 0.85
		
		createScore()
		createLives()
		createSlices()
		
		sequence = [.OneNoBomb, .OneNoBomb, .TwoWithOneBomb, .TwoWithOneBomb, .Three, .One, .Chain]
		
		for _ in 0 ... 1000
		{
			let nextSequence = SequenceType(rawValue: RandomInt(min: 2, max: 7))!
			sequence.append(nextSequence)
		}
		
		RunAfterDelay(2)
		{
			[unowned self] in
			self.tossEnemies()
		}
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?)
	{
		super.touchesBegan(touches, withEvent: event)
		
		// Remove all existing points in the activeSlicePoints array, because we're starting fresh
		activeSlicePoints.removeAll(keepCapacity: true)
		
		// Get the touch location and add it to the activeSlicePoints array
		if let touch = touches.first
		{
			let location = touch.locationInNode(self)
			activeSlicePoints.append(location)
			
			// Call the redrawActiveSlice() method to clear the slice shapes
			redrawActiveSlice()
			
			// Remove any actions that are currently attached to the slice shapes. This will be important if they are in the middle of a fadeOutWithDuration() action
			activeSliceBG.removeAllActions()
			activeSliceFG.removeAllActions()
			
			// Set both slice shapes to have an alpha value of 1 so they are fully visible
			activeSliceBG.alpha = 1
			activeSliceFG.alpha = 1
		}
    }
	
	override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?)
	{
		if gameEnded { return }
		
		guard let touch = touches.first else { return }
		
		let location = touch.locationInNode(self)
		
		activeSlicePoints.append(location)
		redrawActiveSlice()
		
		if !swooshSoundActive
		{
			playSwooshSound()
		}
		
		let nodes = nodesAtPoint(location)
		
		for node in nodes
		{
			if node.name == "enemy"
			{
				// Create a particle effect over the penguin
				let emitter = SKEmitterNode(fileNamed: "sliceHitEnemy")!
				emitter.position = node.position
				addChild(emitter)
				
				// Clear its node name so that it can't be swiped repeatedly
				node.name = ""
				
				// Disable the dynamic of its physics body so that it doesn't carry on falling
				node.physicsBody!.dynamic = false
				
				// Make the penguin scale out and fade out at the same time
				let scaleOut = SKAction.scaleTo(0.001, duration:0.2)
				let fadeOut = SKAction.fadeOutWithDuration(0.2)
				let group = SKAction.group([scaleOut, fadeOut])
				
				// After making the penguin scale out and fade out, we should remove it from the scene
				let seq = SKAction.sequence([group, SKAction.removeFromParent()])
				node.runAction(seq)
				
				// Add one to the player's score
				score += 1
				
				// Remove the enemy from our activeEnemies array.
				let index = activeEnemies.indexOf(node as! SKSpriteNode)!
				activeEnemies.removeAtIndex(index)
				
				// Play a sound so the player knows they hit the penguin
				runAction(SKAction.playSoundFileNamed("whack.caf", waitForCompletion: false))
			}
			else if node.name == "bomb"
			{
				let emitter = SKEmitterNode(fileNamed: "sliceHitBomb")!
				emitter.position = node.parent!.position
				addChild(emitter)
				
				node.name = ""
				node.parent!.physicsBody!.dynamic = false
				
				let scaleOut = SKAction.scaleTo(0.001, duration:0.2)
				let fadeOut = SKAction.fadeOutWithDuration(0.2)
				let group = SKAction.group([scaleOut, fadeOut])
				
				let seq = SKAction.sequence([group, SKAction.removeFromParent()])
				
				node.parent!.runAction(seq)
				
				let index = activeEnemies.indexOf(node.parent as! SKSpriteNode)!
				activeEnemies.removeAtIndex(index)
				
				runAction(SKAction.playSoundFileNamed("explosion.caf", waitForCompletion: false))
				endGame(triggeredByBomb: true)
			}
		}
	}
	
	override func touchesEnded(touches: Set<UITouch>?, withEvent event: UIEvent?)
	{
		activeSliceBG.runAction(SKAction.fadeOutWithDuration(0.25))
		activeSliceFG.runAction(SKAction.fadeOutWithDuration(0.25))
	}
	
	override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?)
	{
		if let touches = touches
		{
			touchesEnded(touches, withEvent: event)
		}
	}
	
	func redrawActiveSlice()
	{
		// If we have fewer than two points in our array, we don't have enough data to draw a line so it needs to clear the shapes and exit the method
		if activeSlicePoints.count < 2
		{
			activeSliceBG.path = nil
			activeSliceFG.path = nil
			return
		}
		
		// If we have more than 12 slice points in our array, we need to remove the oldest ones until we have at most 12 – this stops the swipe shapes from becoming too long
		while activeSlicePoints.count > 12
		{
			activeSlicePoints.removeAtIndex(0)
		}
		
		// It needs to start its line at the position of the first swipe point, then go through each of the others drawing lines to each point
		let path = UIBezierPath()
		path.moveToPoint(activeSlicePoints[0])
		
		for i in 1 ..< activeSlicePoints.count
		{
			path.addLineToPoint(activeSlicePoints[i])
		}
		
		// Finally, it needs to update the slice shape paths so they get drawn using their designs – i.e., line width and color
		activeSliceBG.path = path.CGPath
		activeSliceFG.path = path.CGPath
	}
	
	func playSwooshSound()
	{
		swooshSoundActive = true
		
		let randomNumber = RandomInt(min: 1, max: 3)
		let soundName = "swoosh\(randomNumber).caf"
		
		let swooshSound = SKAction.playSoundFileNamed(soundName, waitForCompletion: true)
		
		runAction(swooshSound)
		{
			[unowned self] in
			self.swooshSoundActive = false
		}
	}
	
	func createScore()
	{
		gameScore = SKLabelNode(fontNamed: "Chalkduster")
		gameScore.text = "Score: 0"
		gameScore.horizontalAlignmentMode = .Left
		gameScore.fontSize = 48
		
		addChild(gameScore)
		
		gameScore.position = CGPoint(x: 8, y: 8)
	}
	
	func createLives()
	{
		for i in 0 ..< 3
		{
			let spriteNode = SKSpriteNode(imageNamed: "sliceLife")
			spriteNode.position = CGPoint(x: CGFloat(834 + (i * 70)), y: 720)
			addChild(spriteNode)
			
			livesImages.append(spriteNode)
		}
	}
	
	func createSlices()
	{
		activeSliceBG = SKShapeNode()
		activeSliceBG.zPosition = 2
		
		activeSliceFG = SKShapeNode()
		activeSliceFG.zPosition = 2
		
		activeSliceBG.strokeColor = UIColor(red: 1, green: 0.9, blue: 0, alpha: 1)
		activeSliceBG.lineWidth = 9
		
		activeSliceFG.strokeColor = UIColor.whiteColor()
		activeSliceFG.lineWidth = 5
		
		addChild(activeSliceBG)
		addChild(activeSliceFG)
	}
	
	func createEnemy(forceBomb forceBomb: ForceBomb = .Default)
	{
		var enemy: SKSpriteNode
		
		var enemyType = RandomInt(min: 0, max: 6)
		
		if forceBomb == .Never
		{
			enemyType = 1
		}
		else if forceBomb == .Always
		{
			enemyType = 0
		}
		
		if enemyType == 0
		{
			// Create a new SKSpriteNode that will hold the fuse and the bomb image as children, setting its Z position to be 1
			enemy = SKSpriteNode()
			enemy.zPosition = 1
			enemy.name = "bombContainer"
			
			// Create the bomb image, name it "bomb", and add it to the container
			let bombImage = SKSpriteNode(imageNamed: "sliceBomb")
			bombImage.name = "bomb"
			enemy.addChild(bombImage)
			
			// If the bomb fuse sound effect is playing, stop it and destroy it
			if bombSoundEffect != nil
			{
				bombSoundEffect.stop()
				bombSoundEffect = nil
			}
			
			// Create a new bomb fuse sound effect, then play it
			let path = NSBundle.mainBundle().pathForResource("sliceBombFuse.caf", ofType:nil)!
			let url = NSURL(fileURLWithPath: path)
			let sound = try! AVAudioPlayer(contentsOfURL: url)
			bombSoundEffect = sound
			sound.play()
			
			// Create a particle emitter node, position it so that it's at the end of the bomb image's fuse, and add it to the container
			let emitter = SKEmitterNode(fileNamed: "sliceFuse")!
			emitter.position = CGPoint(x: 76, y: 64)
			enemy.addChild(emitter)
		}
		else
		{
			enemy = SKSpriteNode(imageNamed: "penguin")
			runAction(SKAction.playSoundFileNamed("launch.caf", waitForCompletion: false))
			enemy.name = "enemy"
		}
		
		// Give the enemy a random position off the bottom edge of the screen
		let randomPosition = CGPoint(x: RandomInt(min: 64, max: 960), y: -128)
		enemy.position = randomPosition
		
		// Create a random angular velocity, which is how fast something should spin
		let randomAngularVelocity = CGFloat(RandomInt(min: -6, max: 6)) / 2.0
		var randomXVelocity = 0
		
		// Create a random X velocity (how far to move horizontally) that takes into account the enemy's position
		if randomPosition.x < 256
		{
			randomXVelocity = RandomInt(min: 8, max: 15)
		}
		else if randomPosition.x < 512
		{
			randomXVelocity = RandomInt(min: 3, max: 5)
		}
		else if randomPosition.x < 768
		{
			randomXVelocity = -RandomInt(min: 3, max: 5)
		}
		else
		{
			randomXVelocity = -RandomInt(min: 8, max: 15)
		}
		
		// Create a random Y velocity just to make things fly at different speeds
		let randomYVelocity = RandomInt(min: 24, max: 32)
		
		// Give all enemies a circular physics body where the collisionBitMask is set to 0 so they don't collide
		enemy.physicsBody = SKPhysicsBody(circleOfRadius: 64)
		enemy.physicsBody!.velocity = CGVector(dx: randomXVelocity * 40, dy: randomYVelocity * 40)
		enemy.physicsBody!.angularVelocity = randomAngularVelocity
		enemy.physicsBody!.collisionBitMask = 0
		
		addChild(enemy)
		activeEnemies.append(enemy)
	}
	
	func tossEnemies()
	{
		if gameEnded { return }
		
		popupTime *= 0.991
		chainDelay *= 0.99
		physicsWorld.speed *= 1.02
		
		let sequenceType = sequence[sequencePosition]
		
		switch sequenceType
		{
			case .OneNoBomb:
				createEnemy(forceBomb: .Never)
				
			case .One:
				createEnemy()
				
			case .TwoWithOneBomb:
				createEnemy(forceBomb: .Never)
				createEnemy(forceBomb: .Always)
				
			case .Two:
				createEnemy()
				createEnemy()
				
			case .Three:
				createEnemy()
				createEnemy()
				createEnemy()
				
			case .Four:
				createEnemy()
				createEnemy()
				createEnemy()
				createEnemy()
				
			case .Chain:
				createEnemy()
				
				RunAfterDelay(chainDelay / 5.0) { [unowned self] in self.createEnemy() }
				RunAfterDelay(chainDelay / 5.0 * 2) { [unowned self] in self.createEnemy() }
				RunAfterDelay(chainDelay / 5.0 * 3) { [unowned self] in self.createEnemy() }
				RunAfterDelay(chainDelay / 5.0 * 4) { [unowned self] in self.createEnemy() }
				
			case .FastChain:
				createEnemy()
				
				RunAfterDelay(chainDelay / 10.0) { [unowned self] in self.createEnemy() }
				RunAfterDelay(chainDelay / 10.0 * 2) { [unowned self] in self.createEnemy() }
				RunAfterDelay(chainDelay / 10.0 * 3) { [unowned self] in self.createEnemy() }
				RunAfterDelay(chainDelay / 10.0 * 4) { [unowned self] in self.createEnemy() }
		}
		
		sequencePosition += 1
		
		nextSequenceQueued = false
	}
	
	func subtractLife()
	{
		lives -= 1
		
		runAction(SKAction.playSoundFileNamed("wrong.caf", waitForCompletion: false))
		
		var life: SKSpriteNode
		
		if lives == 2
		{
			life = livesImages[0]
		}
		else if lives == 1
		{
			life = livesImages[1]
		}
		else
		{
			life = livesImages[2]
			endGame(triggeredByBomb: false)
		}
		
		life.texture = SKTexture(imageNamed: "sliceLifeGone")
		
		life.xScale = 1.3
		life.yScale = 1.3
		life.runAction(SKAction.scaleTo(1, duration:0.1))
	}
	
	func endGame(triggeredByBomb triggeredByBomb: Bool)
	{
		if gameEnded
		{
			return
		}
		
		gameEnded = true
		physicsWorld.speed = 0
		userInteractionEnabled = false
		
		if bombSoundEffect != nil
		{
			bombSoundEffect.stop()
			bombSoundEffect = nil
		}
		
		if triggeredByBomb
		{
			livesImages[0].texture = SKTexture(imageNamed: "sliceLifeGone")
			livesImages[1].texture = SKTexture(imageNamed: "sliceLifeGone")
			livesImages[2].texture = SKTexture(imageNamed: "sliceLifeGone")
		}
	}
	
	override func update(currentTime: CFTimeInterval)
	{
		if activeEnemies.count > 0
		{
			for node in activeEnemies
			{
				if node.position.y < -140
				{
					node.removeAllActions()
					
					if node.name == "enemy"
					{
						node.name = ""
						subtractLife()
						
						node.removeFromParent()
						
						if let index = activeEnemies.indexOf(node)
						{
							activeEnemies.removeAtIndex(index)
						}
					}
					else if node.name == "bombContainer"
					{
						node.name = ""
						node.removeFromParent()
						
						if let index = activeEnemies.indexOf(node)
						{
							activeEnemies.removeAtIndex(index)
						}
					}
				}
			}
		}
		else
		{
			if !nextSequenceQueued
			{
				RunAfterDelay(popupTime)
				{
					[unowned self] in
					self.tossEnemies()
				}
				
				nextSequenceQueued = true
			}
		}
		
		var bombCount = 0
		
		for node in activeEnemies
		{
			if node.name == "bombContainer"
			{
				bombCount += 1
				break
			}
		}
		
		if bombCount == 0
		{
			// no bombs – stop the fuse sound!
			if bombSoundEffect != nil
			{
				bombSoundEffect.stop()
				bombSoundEffect = nil
			}
		}
	}
}
