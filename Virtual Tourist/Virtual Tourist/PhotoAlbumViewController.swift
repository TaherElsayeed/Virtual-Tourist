//
//  PhotoAlbumViewController.swift
//  Virtual Tourist
//
//  Created by lily on 8/27/16.
//  Copyright © 2016 Seab Jackson. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var selectedPin: Pin!

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        setUpMapView()
        FlickrClient.sharedInstance().searchPhotoByLocation(selectedPin.coordinate.latitude, longitude: selectedPin.coordinate.longitude) { (result, error) in
            if error == nil {
                print("result \(result)")
            } else {
                print("error occured")
            }
        }
        

        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        print(selectedPin)
    }
    
    func setUpMapView() {
        let point = MKPointAnnotation()
        point.coordinate = CLLocationCoordinate2DMake((selectedPin.latitude as? Double)!, (selectedPin.longitude as? Double)!)
        mapView.addAnnotation(point)
        
        let span = MKCoordinateSpanMake(2, 2)
        let region = MKCoordinateRegionMake(point.coordinate, span)
        mapView.setRegion(region, animated: true)
    }
    

}
