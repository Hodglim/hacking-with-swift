//
//  DetailViewController.swift
//  StormViewer
//
//  Created by Darren Hodges on 01/10/2015.
//  Copyright © 2015 Darren Hodges. All rights reserved.
//

import UIKit

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
}
