//
//  ViewController.swift
//  Instafilter
//
//  Created by Darren Hodges on 24/10/2015.
//  Copyright © 2015 Darren Hodges. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
	@IBOutlet weak var imageView: UIImageView!
	@IBOutlet weak var intensity: UISlider!
	
	var currentImage: UIImage!
	var context: CIContext!
	var currentFilter: CIFilter!
	
	override func viewDidLoad()
	{
		super.viewDidLoad()
		
		// Title
		title = "Instafilter"
		
		// Import photo button
		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "importPicture")
		
		// Create context and filter
		context = CIContext(options: nil)
		currentFilter = CIFilter(name: "CISepiaTone")
	}
	
	func importPicture()
	{
		let picker = UIImagePickerController()
		picker.allowsEditing = true
		picker.delegate = self
		presentViewController(picker, animated: true, completion: nil)
	}
	
	func applyProcessing()
	{
		// Return if no image has been selected yet.
		guard let _ = currentImage else { return }
		
		let inputKeys = currentFilter.inputKeys
		
		if inputKeys.contains(kCIInputIntensityKey)
		{
			currentFilter.setValue(intensity.value, forKey: kCIInputIntensityKey)
		}
		if inputKeys.contains(kCIInputRadiusKey)
		{
			currentFilter.setValue(intensity.value * 200, forKey: kCIInputRadiusKey)
		}
		if inputKeys.contains(kCIInputScaleKey)
		{
			currentFilter.setValue(intensity.value * 10, forKey: kCIInputScaleKey)
		}
		if inputKeys.contains(kCIInputCenterKey) {
			currentFilter.setValue(CIVector(x: currentImage.size.width / 2, y: currentImage.size.height / 2), forKey: kCIInputCenterKey)
		}
		
		let cgimg = context.createCGImage(currentFilter.outputImage!, fromRect: currentFilter.outputImage!.extent)
		let processedImage = UIImage(CGImage: cgimg)
		
		imageView.image = processedImage
	}
	
	func setFilter(action: UIAlertAction!)
	{
		currentFilter = CIFilter(name: action.title!)
		
		// Return if no image has been selected yet.
		guard let _ = currentImage else { return }
		
		let beginImage = CIImage(image: currentImage)
		currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
		
		applyProcessing()
	}
	
	func image(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo:UnsafePointer<Void>)
	{
		if error == nil
		{
			let ac = UIAlertController(title: "Saved!", message: "Your altered image has been saved to your photos.", preferredStyle: .Alert)
			ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
			presentViewController(ac, animated: true, completion: nil)
		}
		else
		{
			let ac = UIAlertController(title: "Save error", message: error?.localizedDescription, preferredStyle: .Alert)
			ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
			presentViewController(ac, animated: true, completion: nil)
		}
	}

	@IBAction func intensityChanged(sender: UISlider)
	{
		applyProcessing()
	}
	
	@IBAction func changeFilter(sender: UIButton)
	{
		let ac = UIAlertController(title: "Choose filter", message: nil, preferredStyle: .ActionSheet)
		ac.addAction(UIAlertAction(title: "CIBumpDistortion", style: .Default, handler: setFilter))
		ac.addAction(UIAlertAction(title: "CIGaussianBlur", style: .Default, handler: setFilter))
		ac.addAction(UIAlertAction(title: "CIPixellate", style: .Default, handler: setFilter))
		ac.addAction(UIAlertAction(title: "CISepiaTone", style: .Default, handler: setFilter))
		ac.addAction(UIAlertAction(title: "CITwirlDistortion", style: .Default, handler: setFilter))
		ac.addAction(UIAlertAction(title: "CIUnsharpMask", style: .Default, handler: setFilter))
		ac.addAction(UIAlertAction(title: "CIVignette", style: .Default, handler: setFilter))
		ac.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
		presentViewController(ac, animated: true, completion: nil)
	}
	
	@IBAction func save(sender: UIButton)
	{
		UIImageWriteToSavedPhotosAlbum(imageView.image!, self, "image:didFinishSavingWithError:contextInfo:", nil)
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
		
		dismissViewControllerAnimated(true, completion: nil)
		
		currentImage = newImage
		
		let beginImage = CIImage(image: currentImage)
		currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
		
		applyProcessing()
	}
	
	func imagePickerControllerDidCancel(picker: UIImagePickerController)
	{
		dismissViewControllerAnimated(true, completion: nil)
	}
}

