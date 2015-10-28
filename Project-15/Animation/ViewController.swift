//
//  ViewController.swift
//  Animation
//
//  Created by Darren Hodges on 28/10/2015.
//  Copyright © 2015 Darren Hodges. All rights reserved.
//

import UIKit

class ViewController: UIViewController
{
	@IBOutlet weak var tap: UIButton!
	
	var imageView: UIImageView!
	var currentAnimation = 0
	
	override func viewDidLoad()
	{
		super.viewDidLoad()
		
		imageView = UIImageView(image: UIImage(named: "penguin"))
		imageView.center = CGPoint(x: 512, y: 384)
		view.addSubview(imageView)
	}

	@IBAction func tapped(sender: UIButton)
	{
		tap.hidden = true
		
		UIView.animateWithDuration(1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 5, options: [],
		animations:
		{
			[unowned self] in
			switch self.currentAnimation
			{
				case 0:
					self.imageView.transform = CGAffineTransformMakeScale(2, 2)
				
				case 1:
					self.imageView.transform = CGAffineTransformIdentity
				
				case 2:
					self.imageView.transform = CGAffineTransformMakeTranslation(-256, -256)
				
				case 3:
					self.imageView.transform = CGAffineTransformIdentity
				
				case 4:
					self.imageView.transform = CGAffineTransformMakeRotation(CGFloat(M_PI))
				
				case 5:
					self.imageView.transform = CGAffineTransformIdentity
				
				case 6:
					self.imageView.alpha = 0.1
					self.imageView.backgroundColor = UIColor.greenColor()
				
				case 7:
					self.imageView.alpha = 1
					self.imageView.backgroundColor = UIColor.clearColor()
				
				default:
					break
			}
		},
		completion:
		{
			(finished: Bool) in
			self.tap.hidden = false
		})
		
		if ++currentAnimation > 7
		{
			currentAnimation = 0
		}
	}
}

