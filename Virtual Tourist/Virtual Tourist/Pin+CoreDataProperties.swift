//
//  Pin+CoreDataProperties.swift
//  Virtual Tourist
//
//  Created by Seab on 9/4/16.
//  Copyright © 2016 Seab Jackson. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Pin {

    @NSManaged var latitude: Double
    @NSManaged var longitude: Double
    @NSManaged var photos: NSSet?

}
