//
//  Photo.swift
//  Virtual Tourist
//
//  Created by lily on 8/27/16.
//  Copyright © 2016 Seab Jackson. All rights reserved.
//

import Foundation
import CoreData


class Photo: NSManagedObject {
    convenience init(imageURL: String, location: Pin, context: NSManagedObjectContext) {
        if let ent = NSEntityDescription.entityForName("Photo", inManagedObjectContext: context) {
            self.init(entity: ent, insertIntoManagedObjectContext: context)
            self.imageURL = imageURL
            self.location = location
        } else {
            fatalError("Couldn't find entity name")
        }
    }

}
