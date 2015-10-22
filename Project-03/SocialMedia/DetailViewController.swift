//
//  DetailViewController.swift
//  SocialMedia
//
//  Created by Darren Hodges on 01/10/2015.
//  Copyright © 2015 Darren Hodges. All rights reserved.
//

import UIKit
import Social

class DetailViewController: UIViewController
{
    @IBOutlet weak var detailImageView: UIImageView!

    var detailItem: String?
	{
        didSet
		{
            // Update the view.
            configureView()
        }
    }
	
	override func viewDidLoad()
	{
		super.viewDidLoad()
		configureView()
		
		// Add share button to the navigation bar
		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Action, target: self, action: "shareTapped")
	}

    func configureView()
	{
        // Update the user interface for the detail item.
        if let detail = self.detailItem
		{
            if let imageView = self.detailImageView
			{
				imageView.image = UIImage(named: detail)
            }
        }
    }
	
	func shareTapped()
	{
		let actionSheet = UIAlertController(title: "Share", message: "Share this Storm!", preferredStyle: .ActionSheet)
		
		let tweetAction = getTweetAction()
		let moreAction = getMoreAction()
		let fbAction = getFacebookAction()
		
		actionSheet.addAction(tweetAction)
		actionSheet.addAction(fbAction)
		actionSheet.addAction(moreAction)
		
		presentViewController(actionSheet, animated: true, completion: nil)
	}
	
	func getFacebookAction() -> UIAlertAction
	{
		return UIAlertAction(title: "Share on Facebook", style: .Default, handler:
			{
				(action) -> Void in
				let fbComposerVC = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
				fbComposerVC.addImage(self.detailImageView.image!)
				self.presentViewController(fbComposerVC, animated: true, completion: nil)
		})
	}
	
	func getMoreAction() -> UIAlertAction
	{
		return UIAlertAction(title: "More", style: .Default, handler:
			{
				(action) -> Void in
				let vc = UIActivityViewController(activityItems: [self.detailImageView.image!], applicationActivities: [])
				vc.excludedActivityTypes = [UIActivityTypePostToFacebook, UIActivityTypePostToTwitter]
				self.presentViewController(vc, animated: true, completion: nil)
		})
		
	}
	
	func getTweetAction() -> UIAlertAction
	{
		return UIAlertAction(title: "Share on Twitter", style: .Default, handler:
			{
				(action) -> Void in
				let twitterComposerVC = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
				twitterComposerVC.addImage(self.detailImageView.image!)
				self.presentViewController(twitterComposerVC, animated: true, completion: nil)
		})
	}
}
