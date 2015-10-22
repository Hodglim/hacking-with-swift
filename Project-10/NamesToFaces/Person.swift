//
//  Person.swift
//  NamesToFaces
//
//  Created by Darren Hodges on 20/10/2015.
//  Copyright © 2015 Darren Hodges. All rights reserved.
//

import UIKit

class Person: NSObject
{
	var name: String
	var image: String
	
	init(name: String, image: String)
	{
		self.name = name
		self.image = image
	}
}
