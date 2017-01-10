//
//  Photo+CoreDataProperties.swift
//  VirtualTourister
//
//  Created by Midhet Sulemani on 10/01/17.
//  Copyright © 2017 MCreations. All rights reserved.
//

import Foundation
import CoreData


extension Photo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        return NSFetchRequest<Photo>(entityName: "Photo");
    }

    @NSManaged public var creationDate: NSDate?
    @NSManaged public var url: String?
    @NSManaged public var data: NSData?
    @NSManaged public var pin: LocationPin?

}
