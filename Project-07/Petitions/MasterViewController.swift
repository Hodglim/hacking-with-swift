//
//  MasterViewController.swift
//  Petitions
//
//  Created by Darren Hodges on 13/10/2015.
//  Copyright © 2015 Darren Hodges. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController
{
    var detailViewController: DetailViewController? = nil
    var objects = [[String: String]]()

    override func viewDidLoad()
    {
        super.viewDidLoad()
		
		let urlString: String
		
		if navigationController?.tabBarItem.tag == 0
		{
			urlString = "https://api.whitehouse.gov/v1/petitions.json?limit=100"
		}
		else
		{
			urlString = "https://api.whitehouse.gov/v1/petitions.json?signatureCountFloor=10000&limit=100"
		}
            
		if let url = NSURL(string: urlString)
		{
			if let data = try? NSData(contentsOfURL: url, options: [])
			{
				let json = JSON(data: data)
				
				if json["metadata"]["responseInfo"]["status"].intValue == 200
				{
					self.parseJSON(json)
				}
				else
				{
					self.showError()
				}
			}
			else
			{
				self.showError()
			}
		}
		else
		{
			self.showError()
		}
    }
    
    func parseJSON(json: JSON)
    {
        for result in json["results"].arrayValue
        {
            let title = result["title"].stringValue
            let body = result["body"].stringValue
            let sigs = result["signatureCount"].stringValue
            let obj = ["title": title, "body": body, "sigs": sigs]
            objects.append(obj)
        }
		
		self.tableView.reloadData()
    }

    override func viewWillAppear(animated: Bool)
    {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
        super.viewWillAppear(animated)
    }
	
	func showError()
	{
		let ac = UIAlertController(title: "Loading error", message: "There was a problem loading the feed; please check your connection and try again.", preferredStyle: .Alert)
		ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
		self.presentViewController(ac, animated: true, completion: nil)
	}

    // MARK: - UITableViewDataSource

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return objects.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)

        let object = objects[indexPath.row]
        cell.textLabel!.text = object["title"]
        cell.detailTextLabel!.text = object["body"]
        return cell
    }
	
	// MARK: - Segues
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
	{
		if segue.identifier == "showDetail"
		{
			if let indexPath = self.tableView.indexPathForSelectedRow
			{
				let object = objects[indexPath.row]
				let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
				controller.detailItem = object
				controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
				controller.navigationItem.leftItemsSupplementBackButton = true
			}
		}
	}
}
