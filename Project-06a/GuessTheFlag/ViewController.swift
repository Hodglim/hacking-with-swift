//
//  ViewController.swift
//  GuessTheFlag
//
//  Created by Darren Hodges on 02/10/2015.
//  Copyright © 2015 Darren Hodges. All rights reserved.
//

import UIKit
import GameplayKit

class ViewController: UIViewController
{
	@IBOutlet weak var button1: UIButton!
	@IBOutlet weak var button2: UIButton!
	@IBOutlet weak var button3: UIButton!
	@IBOutlet weak var scoreLabel: UILabel!
	
	var countries = [String]()
	var score = 0
	var correctAnswer = 0

	override func viewDidLoad()
	{
		super.viewDidLoad()
		
		// Set up countries
		countries += ["estonia", "france", "germany", "ireland", "italy", "monaco", "nigeria", "poland", "russia", "spain", "uk", "us"]
		
		// Add a border to the buttons
		button1.layer.borderWidth = 1
		button2.layer.borderWidth = 1
		button3.layer.borderWidth = 1
		
		// Set border colour
		button1.layer.borderColor = UIColor.lightGrayColor().CGColor
		button2.layer.borderColor = UIColor.lightGrayColor().CGColor
		button3.layer.borderColor = UIColor.lightGrayColor().CGColor
		
		// Ask question
		askQuestion()
	}
	
	func askQuestion(action: UIAlertAction! = nil)
	{
		// Randomise countries array
		countries = GKRandomSource.sharedRandom().arrayByShufflingObjectsInArray(countries) as! [String]
		
		// Set flag buttons
		button1.setImage(UIImage(named: countries[0]), forState: .Normal)
		button2.setImage(UIImage(named: countries[1]), forState: .Normal)
		button3.setImage(UIImage(named: countries[2]), forState: .Normal)
		
		// Random correct answer (0, 1 or 2)
		correctAnswer = GKRandomSource.sharedRandom().nextIntWithUpperBound(3)
		
		// Set title
		title = countries[correctAnswer].uppercaseString
		
	}
	
	@IBAction func buttonTapped(sender: UIButton)
	{
		var title: String
		var message: String
		
		if sender.tag == correctAnswer
		{
			title = "Correct"
			message = "Well done! Tap Continue to try another."
			++score
		}
		else
		{
			title = "Wrong"
			message = "Unlucky! Tap Continue to try another."
			--score
		}
		
		// Update score label
		scoreLabel.text = "Score: \(score)"
		
		// Show alert
		let ac = UIAlertController(title: title, message: message, preferredStyle: .Alert)
		ac.addAction(UIAlertAction(title: "Continue", style: .Default, handler: askQuestion))
		presentViewController(ac, animated: true, completion: nil)
	}
}

