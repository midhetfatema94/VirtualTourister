//
//  LocationPin+CoreDataProperties.swift
//  VirtualTourister
//
//  Created by Midhet Sulemani on 10/01/17.
//  Copyright © 2017 MCreations. All rights reserved.
//

import Foundation
import CoreData


extension LocationPin {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LocationPin> {
        return NSFetchRequest<LocationPin>(entityName: "LocationPin");
    }

    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var creationDate: NSDate?
    @NSManaged public var name: String?
    @NSManaged public var photo: NSSet?

}

// MARK: Generated accessors for photo
extension LocationPin {

    @objc(addPhotoObject:)
    @NSManaged public func addToPhoto(_ value: Photo)

    @objc(removePhotoObject:)
    @NSManaged public func removeFromPhoto(_ value: Photo)

    @objc(addPhoto:)
    @NSManaged public func addToPhoto(_ values: NSSet)

    @objc(removePhoto:)
    @NSManaged public func removeFromPhoto(_ values: NSSet)

}
