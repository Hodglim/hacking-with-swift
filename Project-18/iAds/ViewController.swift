//
//  ViewController.swift
//  iAds
//
//  Created by Darren Hodges on 24/06/2016.
//  Copyright © 2016 Darren Hodges. All rights reserved.
//

import UIKit
import iAd

class ViewController: UIViewController, ADBannerViewDelegate
{
	var bannerView: ADBannerView!

	override func viewDidLoad()
	{
		super.viewDidLoad()
		
		bannerView = ADBannerView(adType: .Banner)
		bannerView.translatesAutoresizingMaskIntoConstraints = false
		bannerView.delegate = self
		bannerView.hidden = true
		view.addSubview(bannerView)
		
		let viewsDictionary = ["bannerView": bannerView]
		view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[bannerView]|", options: [], metrics: nil, views: viewsDictionary))
		view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[bannerView]|", options: [], metrics: nil, views: viewsDictionary))
	}

	override func didReceiveMemoryWarning()
	{
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	func bannerViewDidLoadAd(banner: ADBannerView!)
	{
		bannerView.hidden = false
	}
	
	func bannerView(banner: ADBannerView!, didFailToReceiveAdWithError error: NSError!)
	{
		bannerView.hidden = true
	}
}

