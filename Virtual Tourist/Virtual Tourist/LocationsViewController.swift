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
    var savedRegion: MKCoordinateRegion?
    
    @IBOutlet weak var mapView: MKMapView!
    var pins = [Pin]()
    var selectedPin: Pin?
    var imageURLs: [String]?
    
    //viewWillDisappear
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSUserDefaults.standardUserDefaults().setDouble((selectedPin?.coordinate.latitude)!, forKey: "LatitudeValue")
        NSUserDefaults.standardUserDefaults().setDouble((selectedPin?.coordinate.longitude)!, forKey: "LongitudeValue")
    }
    // NSUSerdefaults ->
    // dictioanry -> key = "lastZomedpoint" .> value
    // ["lat":23 ,"lon" :34 , delat:dsf, ]

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        
        // create the long gesture
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(LocationsViewController.dropPin(_:)))
        longPressRecognizer.minimumPressDuration = 1.0
        mapView.addGestureRecognizer(longPressRecognizer)
        
        // check for saved map information
        if let mapInfo = NSUserDefaults.standardUserDefaults().dictionaryForKey("mapInfo") as? [String: CLLocationDegrees] {
            let centerLatitude = mapInfo[ "centerLatitude" ]!
            let centerLongitude = mapInfo[ "centerLongitude" ]!
            let spanLatDelta = mapInfo[ "spanLatitudeDelta" ]!
            let spanLongDelta = mapInfo[ "spanLongitudeDelta" ]!
            
            let newMapRegion = MKCoordinateRegion(
                center: CLLocationCoordinate2D(
                    latitude: centerLatitude,
                    longitude: centerLongitude
                ),
                span: MKCoordinateSpan(
                    latitudeDelta: spanLatDelta,
                    longitudeDelta: spanLongDelta
                )
            )
            
            savedRegion = newMapRegion
        }
        
        // retireve the value NSUSerdefaults
        // dictionaty => dictioanry
        //        if let dict = values from NSUserdfaults "lastZomedpoint"{
        //            dict[lat]
        //        }
        //mpaview -> values
        

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if savedRegion != nil {
            mapView.region = savedRegion!
            mapView.setCenterCoordinate(savedRegion!.center, animated: true)
        }
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
        
        // first get the list of images
        print("deselect")
        //get the images = not the actual image data
        //flickr.photos.search => response =>
        // tag, imageURL
        
        // get the response => create the photo Objects (NSManagedObject)
        FlickrClient.sharedInstance().searchPhotoByLocation((selectedPin?.coordinate.latitude)!, longitude: selectedPin!.coordinate.longitude) { (result, error) in
            performUIUpdatesOnMain() {
                if error == nil {
                    let photosArray = result
                    //create the photos entites here
                    // on the main ->
                    let PhotoAlbumVC = self.storyboard?.instantiateViewControllerWithIdentifier("PhotoAlbumVC") as! PhotoAlbumViewController
                    PhotoAlbumVC.selectedPin = self.selectedPin
                    PhotoAlbumVC.numOfPhotos = photosArray?.count
                    print(photosArray?.count)

                    print("storyboard created")
                    self.navigationController?.pushViewController(PhotoAlbumVC, animated: true)
                } else {
                    print("error occured")
                }

            }
       }
//        let PhotoAlbumVC = self.storyboard?.instantiateViewControllerWithIdentifier("PhotoAlbumVC") as! PhotoAlbumViewController
//        PhotoAlbumVC.selectedPin = selectedPin
//        print("storyboard created")
//        navigationController?.pushViewController(PhotoAlbumVC, animated: true)
    }
    
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
        
        //save
        // mamnagedObjectContext
    }

}

