//
//  ViewController.swift
//  SwiftyWords
//
//  Created by Darren Hodges on 15/10/2015.
//  Copyright © 2015 Darren Hodges. All rights reserved.
//

import UIKit
import GameplayKit

class ViewController: UIViewController
{
    @IBOutlet weak var cluesLabel: UILabel!
    @IBOutlet weak var answersLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var currentAnswer: UITextField!
    
    var letterButtons = [UIButton]()
    var activatedButtons = [UIButton]()
    var solutions = [String]()
    var level = 1
    var score: Int = 0
    {
        didSet
        {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Add action to each button
        for subview in view.subviews where subview.tag == 1001
        {
            let btn = subview as! UIButton
            letterButtons.append(btn)
            btn.addTarget(self, action: "letterTapped:", forControlEvents: .TouchUpInside)
        }
        
        // Load level
        loadLevel()
    }
    
    func loadLevel()
    {
        var clueString = ""
        var solutionString = ""
        var letterBits = [String]()
        
        if let levelFilePath = NSBundle.mainBundle().pathForResource("level\(level)", ofType: "txt")
        {
            if let levelContents = try? String(contentsOfFile: levelFilePath, usedEncoding: nil)
            {
                var lines = levelContents.componentsSeparatedByString("\n")
                lines = GKRandomSource.sharedRandom().arrayByShufflingObjectsInArray(lines) as! [String]
                
                for (index, line) in lines.enumerate()
                {
                    let parts = line.componentsSeparatedByString(": ")
                    let answer = parts[0]
                    let clue = parts[1]
                    
                    clueString += "\(index + 1). \(clue)\n"
                    
                    let solutionWord = answer.stringByReplacingOccurrencesOfString("|", withString: "")
                    solutionString += "\(solutionWord.characters.count) letters\n"
                    solutions.append(solutionWord)
                    
                    let bits = answer.componentsSeparatedByString("|")
                    letterBits += bits
                }
            }
        }
        
        cluesLabel.text = clueString.stringByTrimmingCharactersInSet(.whitespaceAndNewlineCharacterSet())
        answersLabel.text = solutionString.stringByTrimmingCharactersInSet(.whitespaceAndNewlineCharacterSet())
        
        letterBits = GKRandomSource.sharedRandom().arrayByShufflingObjectsInArray(letterBits) as! [String]
        letterButtons = GKRandomSource.sharedRandom().arrayByShufflingObjectsInArray(letterButtons) as! [UIButton]
        
        if letterBits.count == letterButtons.count
        {
            for i in 0 ..< letterBits.count
            {
                letterButtons[i].setTitle(letterBits[i], forState: .Normal)
            }
        }
    }
    
    func levelUp(action: UIAlertAction!)
    {
        ++level
        solutions.removeAll(keepCapacity: true)
        
        // We only have 2 levels at the moment
        if level > 2 { level = 1 }
        
        loadLevel()
        
        for btn in letterButtons
        {
            btn.hidden = false
        }
    }
    
    func letterTapped(btn: UIButton)
    {
        currentAnswer.text = currentAnswer.text! + btn.titleLabel!.text!
        activatedButtons.append(btn)
        btn.hidden = true
    }

    @IBAction func submitTapped(sender: UIButton)
    {
        if let solutionPosition = solutions.indexOf(currentAnswer.text!)
        {
            activatedButtons.removeAll()
            
            var splitClues = answersLabel.text!.componentsSeparatedByString("\n")
            splitClues[solutionPosition] = currentAnswer.text!
            answersLabel.text = splitClues.joinWithSeparator("\n")
            
            currentAnswer.text = ""
            ++score
            
            if score % 7 == 0
            {
                let ac = UIAlertController(title: "Well done!", message: "Are you ready for the next level?", preferredStyle: .Alert)
                ac.addAction(UIAlertAction(title: "Let's go!", style: .Default, handler: levelUp))
                presentViewController(ac, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func clearTapped(sender: UIButton)
    {
        currentAnswer.text = ""
        
        for btn in activatedButtons
        {
            btn.hidden = false
        }
        
        activatedButtons.removeAll()
    }
}

