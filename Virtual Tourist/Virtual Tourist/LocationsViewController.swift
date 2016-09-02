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

class LocationsViewController: UIViewController, MKMapViewDelegate, NSFetchedResultsControllerDelegate {
    
    
    var savedRegion: MKCoordinateRegion?
    var mapRegionSet = false
    
    @IBOutlet weak var mapView: MKMapView!

    var selectedPin: Pin?
    
    // shared context
    let stack = CoreDataStack.sharedInstance

    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
//        if savedRegion != nil {
//            mapView.region = savedRegion!
//            mapView.setCenterCoordinate(savedRegion!.center, animated: true)
//        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        
        // create the long gesture
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(LocationsViewController.dropPin(_:)))
        longPressRecognizer.minimumPressDuration = 1.0
        mapView.addGestureRecognizer(longPressRecognizer)
        
        // set up the map
        setUpMap()

    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if !mapRegionSet {
            setMapToLastPosition()
        }
        
    }
    

    
    func setMapToLastPosition() {
        if let savedRegion = savedRegion {
            mapView.region = savedRegion
            mapRegionSet = true
        }
    }
    
    func setUpMap() {
        getSavedInfoForMap()
        if savedRegion != nil && mapRegionSet {
            mapView.centerCoordinate = (savedRegion?.center)!
        }
    }

    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.animatesDrop = true
            // no need for a title
            pinView!.canShowCallout = false
            pinView!.pinTintColor = UIColor.redColor()
        } else {
            pinView!.annotation = annotation
            pinView?.animatesDrop = true
        }
        return pinView
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        guard let pin = view.annotation as? Pin else { return }
        mapView.deselectAnnotation(pin, animated: false)
        performSegueWithIdentifier("showPhotoAlbumVC", sender: pin)
    }
    
    // keep updating and store the map values for the region
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        // record the map region info
        let mapRegionCenterLatitude: CLLocationDegrees = mapView.region.center.latitude
        let mapRegionCenterLongitude: CLLocationDegrees = mapView.region.center.longitude
        let mapRegionSpanLatitudeDelta: CLLocationDegrees = mapView.region.span.latitudeDelta
        let mapRegionSpanLongitudeDelta: CLLocationDegrees = mapView.region.span.longitudeDelta
        
        // create a dictionary to store in the user defaults
        var mapDictionary = [ String : CLLocationDegrees ]()
        mapDictionary.updateValue( mapRegionCenterLatitude, forKey: "centerLatitude")
        mapDictionary.updateValue( mapRegionCenterLongitude, forKey: "centerLongitude")
        mapDictionary.updateValue( mapRegionSpanLatitudeDelta, forKey: "spanLatitudeDelta")
        mapDictionary.updateValue( mapRegionSpanLongitudeDelta, forKey: "spanLongitudeDelta")
        
        // save to NSUserDefaults
        NSUserDefaults.standardUserDefaults().setObject(mapDictionary, forKey: "mapInfo")
        NSUserDefaults.standardUserDefaults().synchronize()

    }
    
    
    func getSavedInfoForMap() {
        if let mapInfo = NSUserDefaults.standardUserDefaults().dictionaryForKey("mapInfo") as? [String: CLLocationDegrees] {
            let centerLatitude = mapInfo[ "centerLatitude" ]!
            let centerLongitude = mapInfo[ "centerLongitude" ]!
            let spanLatDelta = mapInfo[ "spanLatitudeDelta" ]!
            let spanLongDelta = mapInfo[ "spanLongitudeDelta" ]!
            
            let newMapRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: centerLatitude, longitude: centerLongitude),span: MKCoordinateSpan(latitudeDelta: spanLatDelta,longitudeDelta: spanLongDelta))
                savedRegion = newMapRegion
        }
    }
  // prepare to show the PhotoAlbumViewController
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showPhotoAlbumVC" {
            // the sender is the actual pin object
            let pin = sender as? Pin
            let PhotoAlbumVC = segue.destinationViewController as? PhotoAlbumViewController
            PhotoAlbumVC?.selectedPin = pin
        }
    }
    
    func dropPin(gestureRecognizer: UIGestureRecognizer) {
        if gestureRecognizer.state != .Began { return }
    
        let touchPoint = gestureRecognizer.locationInView(self.mapView)
        let touchMapCoordinate = mapView.convertPoint(touchPoint, toCoordinateFromView: mapView)
        let annotation = Pin(latitude: touchMapCoordinate.latitude, longitude: touchMapCoordinate.longitude, context: (stack?.context)!)
        // save
        do {
            try stack?.saveContext()
        } catch {
            print("couldn't save the pin")
        }
        mapView.addAnnotation(annotation)
    }

}

