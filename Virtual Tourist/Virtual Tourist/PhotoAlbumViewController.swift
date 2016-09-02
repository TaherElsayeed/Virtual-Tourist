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

private let reuseIdentifier = "PhotosCollectionCell"

class PhotoAlbumViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var photosArray: [String]!
    var selectedPin: Pin!
    //photos array {
    //}//didset = call the function


    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
//        collectionView.delegate = self
//        collectionView.dataSource = self
        setUpMapView()

        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        print(selectedPin)
        collectionView.reloadData()
    }
    
    func setUpMapView() {
        let point = MKPointAnnotation()
        point.coordinate = CLLocationCoordinate2DMake(selectedPin.latitude, selectedPin.longitude)
        mapView.addAnnotation(point)
        
        let span = MKCoordinateSpanMake(2, 2)
        let region = MKCoordinateRegionMake(point.coordinate, span)
        mapView.setRegion(region, animated: true)
    }
    
//    //collection view
//    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
////        return photosArray.count
//    }
//    
//    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! PhotosCollectionViewCell
//            _ = FlickrClient.sharedInstance().downloadImages(photosArray[indexPath.item]) { (data, error) in
//            performUIUpdatesOnMain {
//                if error == nil {
//                    cell.imageView.image = UIImage(data: data!)
//                }
//            }
//        }
//        return cell
//    }
    
//    func loadCellWithImage(cell: PhotosCollectionViewCell, indexPath: NSIndexPath) {
//        
//        FlickrClient.sharedInstance().downloadImages(photosArray[indexPath]) { (data, error) in
//            guard (error == nil) else {
//                print("couldn't download the images")
//                return
//            }
//            
//        }
//    }
//    
    
    // data source = photos array // show some messgae
    // numberofitems = count of photos array
    
    //itemforcell //show some placeholder image
    //->          //http://flciker/1.kjpg -. Binary data // replace this placeholder with image data and stop activity indicator
    
    // photo -> imageURL property -> get the function -> response -> imageData
    //UIImage(data:)imageData
    
    //showing the activity indicator => in the collectionv view -> imageview + activity indicatoer
    
    
    // -----------
    //new collection button // we have to get the different set of data //collectionview.reloaddata
    

    

}
