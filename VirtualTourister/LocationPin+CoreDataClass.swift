//
//  LocationPin+CoreDataClass.swift
//  VirtualTourister
//
//  Created by Midhet Sulemani on 10/01/17.
//  Copyright © 2017 MCreations. All rights reserved.
//

import Foundation
import CoreData


public class LocationPin: NSManagedObject {
    
    convenience init(lat: Double, long: Double, context: NSManagedObjectContext) {
        
        // An EntityDescription is an object that has access to all
        // the information you provided in the Entity part of the model
        // you need it to create an instance of this class.
        if let ent = NSEntityDescription.entity(forEntityName: "LocationPin", in: context) {
            self.init(entity: ent, insertInto: context)
            self.latitude = lat
            self.longitude = long
            self.creationDate = Date()
        } else {
            fatalError("Unable to find Entity name!")
        }
    }
}
