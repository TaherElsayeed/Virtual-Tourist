//
//  Pin.swift
//  Virtual Tourist
//
//  Created by lily on 8/27/16.
//  Copyright © 2016 Seab Jackson. All rights reserved.
//

import Foundation
import CoreData
import MapKit


class Pin: NSManagedObject {
    
    init(latitude: Double, longitude: Double, context: NSManagedObjectContext) {
        if let pin = NSEntityDescription.entityForName("Pin", inManagedObjectContext: context) {
            super.init(entity: pin, insertIntoManagedObjectContext: context)
            
            self.latitude = latitude
            self.longitude = longitude
        } else {
            fatalError("Error")
        }
    }
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: (self.latitude as? Double)!, longitude: (self.longitude as? Double)!)
    }

}
