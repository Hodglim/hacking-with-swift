//
//  ViewController.swift
//  NamesToFaces
//
//  Created by Darren Hodges on 19/10/2015.
//  Copyright © 2015 Darren Hodges. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
	@IBOutlet weak var collectionView: UICollectionView!
	
	var people = [Person]()
	
	override func viewDidLoad()
	{
		super.viewDidLoad()
		
		// Add new person button
		navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "addNewPerson")
		
		// Load saved data
		let defaults = NSUserDefaults.standardUserDefaults()
		if let savedPeople = defaults.objectForKey("people") as? NSData
		{
			people = NSKeyedUnarchiver.unarchiveObjectWithData(savedPeople) as! [Person]
		}
	}
	
	func addNewPerson()
	{
		let picker = UIImagePickerController()
		picker.allowsEditing = true
		picker.delegate = self
		presentViewController(picker, animated: true, completion: nil)
	}
	
	func getDocumentsDirectory() -> NSString
	{
		let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
		let documentsDirectory = paths[0]
		//print(documentsDirectory)
		return documentsDirectory
	}
	
	func renamePerson(person: Person, indexPath: NSIndexPath)
	{
		let ac = UIAlertController(title: "Rename person", message: nil, preferredStyle: .Alert)
		ac.addTextFieldWithConfigurationHandler
			{
				field in
				if(person.name != "Unknown")
				{
					field.text = person.name
				}
		}
		ac.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
		ac.addAction(UIAlertAction(title: "OK", style: .Default)
			{
				[unowned self, ac] _ in
				let newName = ac.textFields![0]
				person.name = newName.text!
				self.collectionView.reloadItemsAtIndexPaths([indexPath])
				self.save()
			})
		
		self.presentViewController(ac, animated: true, completion: nil)
	}
	
	func deletePerson(person: Person, indexPath: NSIndexPath)
	{
		let ac = UIAlertController(title: "Delete person", message: "Are you sure you want to delete this person?", preferredStyle: .Alert)
		ac.addAction(UIAlertAction(title: "No", style: .Cancel, handler: nil))
		ac.addAction(UIAlertAction(title: "Yes", style: .Default)
		{
			[unowned self] _ in
			self.people.removeAtIndex(indexPath.item)
			
			// Delete image
			let imagePath = self.getDocumentsDirectory().stringByAppendingPathComponent(person.image)
			let fileMgr = NSFileManager.defaultManager()
			
			do
			{
				try fileMgr.removeItemAtPath(imagePath)
			}
			catch
			{
				print("Failed to delete image file")
			}
			
			self.collectionView.reloadData()
			self.save()
		})
		
		self.presentViewController(ac, animated: true, completion: nil)
	}
	
	func save()
	{
		let savedData = NSKeyedArchiver.archivedDataWithRootObject(people)
		let defaults = NSUserDefaults.standardUserDefaults()
		defaults.setObject(savedData, forKey: "people")
	}
	
	// MARK: UICollectionViewDataSource
	
	func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
	{
		return people.count
	}
	
	func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
	{
		let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Person", forIndexPath: indexPath) as! PersonCell
		let person = people[indexPath.row]
		
		cell.name.text = person.name
		let path = getDocumentsDirectory().stringByAppendingPathComponent(person.image)
		cell.imageView.image = UIImage(contentsOfFile: path)
		
		cell.imageView.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3).CGColor
		cell.imageView.layer.borderWidth = 2
		cell.imageView.layer.cornerRadius = 3
		cell.layer.cornerRadius = 7
		
		return cell
	}
	
	// MARK: UINavigationControllerDelegate
	
	func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)
	{
		let person = people[indexPath.item]
		
		let actionSheet = UIAlertController(title: "Update this person", message: nil, preferredStyle: .ActionSheet)
		
		let renameAction = UIAlertAction(title: "Rename person", style: .Default)
		{
			[unowned self] _ in
			self.renamePerson(person, indexPath: indexPath)
		}
		
		let deleteAction = UIAlertAction(title: "Delete person", style: .Destructive)
		{
			[unowned self] _ in
			self.deletePerson(person, indexPath: indexPath)
		}
		
		let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
		
		actionSheet.addAction(renameAction)
		actionSheet.addAction(deleteAction)
		actionSheet.addAction(cancelAction)
		
		presentViewController(actionSheet, animated: true, completion: nil)
	}
	
	// MARK: UIImagePickerControllerDelegate
	
	func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject])
	{
		var newImage: UIImage
		
		if let possibleImage = info["UIImagePickerControllerEditedImage"] as? UIImage
		{
			newImage = possibleImage
		}
		else if let possibleImage = info["UIImagePickerControllerOriginalImage"] as? UIImage
		{
			newImage = possibleImage
		}
		else
		{
			return
		}
		
		let imageName = NSUUID().UUIDString
		let imagePath = getDocumentsDirectory().stringByAppendingPathComponent(imageName)
		
		if let jpegData = UIImageJPEGRepresentation(newImage, 80)
		{
			jpegData.writeToFile(imagePath, atomically: true)
		}
		
		// Create Person object
		let person = Person(name: "Unknown", image: imageName)
		people.append(person)
		collectionView.reloadData()
		self.save()
		
		dismissViewControllerAnimated(true, completion: nil)
	}
	
	func imagePickerControllerDidCancel(picker: UIImagePickerController)
	{
		dismissViewControllerAnimated(true, completion: nil)
	}
}

