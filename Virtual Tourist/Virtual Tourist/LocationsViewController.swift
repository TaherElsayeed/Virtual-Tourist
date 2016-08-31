//
//  ViewController.swift
//  Virtual Tourist
//
//  Created by lily on 8/27/16.
//  Copyright © 2016 Seab Jackson. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class LocationsViewController: UIViewController, MKMapViewDelegate {
    
    // MARK: Model
    
    var managedObjectContext: NSManagedObjectContext? = (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext
    
    
    @IBOutlet weak var mapView: MKMapView!
    var pins = [Pin]()
    var selectedPin: Pin?
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        
        // create the long gesture
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(LocationsViewController.dropPin(_:)))
        longPressRecognizer.minimumPressDuration = 1.0
        mapView.addGestureRecognizer(longPressRecognizer)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = UIColor.redColor()
        } else {
            pinView!.annotation = annotation
        }
        return pinView
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        mapView.deselectAnnotation(view.annotation, animated: true)
        guard let annotation = view.annotation else { return }
        for pin in pins {
            if annotation.coordinate.latitude == pin.latitude {
                selectedPin = pin
            }
        }
        print("deselect")
        let PhotoAlbumVC = self.storyboard?.instantiateViewControllerWithIdentifier("PhotoAlbumVC") as! PhotoAlbumViewController
        PhotoAlbumVC.selectedPin = selectedPin
        print("storyboard created")
        navigationController?.pushViewController(PhotoAlbumVC, animated: true)
    }
    
    func dropPin(gestureRecognizer: UIGestureRecognizer) {
        if gestureRecognizer.state != .Began { return }
    
        let touchPoint = gestureRecognizer.locationInView(self.mapView)
        let touchMapCoordinate = mapView.convertPoint(touchPoint, toCoordinateFromView: mapView)
        let annotation = MKPointAnnotation()
        annotation.title = "pin"
        annotation.coordinate = touchMapCoordinate
        
        let newPin = Pin(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude, context: managedObjectContext!)
        mapView.addAnnotation(annotation)
        pins.append(newPin)
    }

}

