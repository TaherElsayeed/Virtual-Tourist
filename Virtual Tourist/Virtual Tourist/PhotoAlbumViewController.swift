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

class PhotoAlbumViewController: UIViewController, MKMapViewDelegate, NSFetchedResultsControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate {

    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var toolBarButtonItem: UIBarButtonItem!
    

    
    // initialize for use with NSFetchedResultsControllerDelegate Integration With CollectionView
    var blockOperations: [NSBlockOperation] = []
    var fetchedResultsController: NSFetchedResultsController!
    var selectedPin: Pin!
    let stack = CoreDataStack.sharedInstance
    var selectedPhotos: [NSIndexPath] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
        setUpMapView()
        toolBarButtonItem.title = "Download Images"
        
        // set up UI for collection view
        let spacing = CGFloat(5.0)
        let dimension = (view.frame.size.width - 10.0) / 3
        flowLayout.minimumInteritemSpacing = spacing
        flowLayout.minimumLineSpacing = CGFloat(5.0)
        flowLayout.itemSize = CGSize(width: dimension, height: dimension)
   
        // first look in the database to retrieve photos and download them if it is empty
        if retrievePhotos().isEmpty {
            getThePhotoLinks()
        }
    }
   
    @IBAction func deleteOrDownloadNewPhoto(sender: UIBarButtonItem) {
        if sender.title == "Download Images" {
            selectedPhotos.removeAll()
            let photos = fetchedResultsController.fetchedObjects as! [Photo]
            for photo in photos {
                fetchedResultsController.managedObjectContext.deleteObject(photo)
            }
            getThePhotoLinks()
        } else if sender.title == "Delete" {
            for photo in selectedPhotos {
                if let photo = fetchedResultsController.objectAtIndexPath(photo) as? Photo {
                    fetchedResultsController.managedObjectContext.deleteObject(photo)
                }
                continue
            }
            selectedPhotos.removeAll()
            sender.title = "Download Images"
            do {
                try stack?.saveContext()
            } catch {
                print("Couldn't update for deleted images")
            }
        }
    }
    func setUpMapView() {
        let point = MKPointAnnotation()
        point.coordinate = CLLocationCoordinate2DMake(selectedPin.latitude, selectedPin.longitude)
        mapView.addAnnotation(point)
        
        let span = MKCoordinateSpanMake(2, 2)
        let region = MKCoordinateRegionMake(point.coordinate, span)
        mapView.setRegion(region, animated: true)
    }
    
    func getThePhotoLinks() {
        FlickrClient.sharedInstance().searchPhotoByLocation(selectedPin.latitude, longitude: selectedPin
            .longitude) { (result, error) in
                guard (error == nil) else {
                    print("couldn't get the photo links")
                    return
                }
                guard let photoLinks = result else {
                    print("couldn't find the links")
                    return
                }
                performUIUpdatesOnMain() {
                    for photoLink in photoLinks {
                        let imageURL = photoLink
                        // results of initializers are unused
                        _ = Photo(imageURL: imageURL, location: self.selectedPin, context: (self.stack?.context)!)
                    }
                    
                    do {
                        try self.stack?.saveContext()
                    } catch {
                        print("couldn't save the photos")
                    }

                }
        }
    }
    
    // fetch the photos
    func retrievePhotos() -> [Photo] {
        let request = NSFetchRequest(entityName: "Photo")
        let sortDescriptor = NSSortDescriptor(key: "imageURL", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        
        // set up the predicate
        let predicate = NSPredicate(format: "location = %@", argumentArray: [selectedPin])
        request.predicate = predicate
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: (stack?.context)!, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        var photos = [Photo]()
        do {
            try fetchedResultsController.performFetch()
            photos = fetchedResultsController.fetchedObjects as! [Photo]
        } catch {
            print("couldn't retrieve photos")
        }
        return photos
    }
    
    // MARK: CollectionView
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let fetchedItems = fetchedResultsController.fetchedObjects?.count else {
            return 0
        }
        return fetchedItems
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! PhotosCollectionViewCell
            let photo = fetchedResultsController.objectAtIndexPath(indexPath) as! Photo
        if let imageData = photo.image {
            cell.imageView.image = UIImage(data: imageData)
        } else {
            loadCellWithImage(cell, photo: photo)
            do {
                try stack?.saveContext()
            } catch {
                print("couldnt save the photo")
            }
        }
        return cell
    }
//
    func loadCellWithImage(cell: PhotosCollectionViewCell, photo: Photo) {
        cell.imageView.image = UIImage(named: "placeholder")
        let url = NSURL(string: photo.imageURL!)!
        FlickrClient.sharedInstance().downloadImages(url) { (data, error) in
            guard (error == nil) else {
                print("couldn't get imageData")
                return
            }
            
            performUIUpdatesOnMain {
                photo.image = data!
                let actualPhoto = UIImage(data: data!)
                cell.imageView.image = actualPhoto
            }
        }
        
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        toolBarButtonItem.title = "Delete"
        selectedPhotos.append(indexPath)
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! PhotosCollectionViewCell
        cell.imageView.alpha = 0.5
        
    }

// The Code below was adopted from the link below and prove helpful in using the CoreDataStack with CollectionView
// First initialise an array of NSBlockOperations:
   
    // https://gist.github.com/AppsTitude/ce072627c61ea3999b8d
    // UICollectionView and NSFetchedResultsControllerDelegate integration in Swift was leveraged heavily for making this app
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        if type == NSFetchedResultsChangeType.Insert {
//            print("Insert Object: \(newIndexPath)")
            
            blockOperations.append(
                NSBlockOperation(block: { [weak self] in
                    if let this = self {
                        this.collectionView!.insertItemsAtIndexPaths([newIndexPath!])
                    }
                    })
            )
        }
        else if type == NSFetchedResultsChangeType.Update {
//            print("Update Object: \(indexPath)")
            blockOperations.append(
                NSBlockOperation(block: { [weak self] in
                    if let this = self {
                        this.collectionView!.reloadItemsAtIndexPaths([indexPath!])
                    }
                    })
            )
        }
        else if type == NSFetchedResultsChangeType.Move {
//            print("Move Object: \(indexPath)")
            
            blockOperations.append(
                NSBlockOperation(block: { [weak self] in
                    if let this = self {
                        this.collectionView!.moveItemAtIndexPath(indexPath!, toIndexPath: newIndexPath!)
                    }
                    })
            )
        }
        else if type == NSFetchedResultsChangeType.Delete {
//            print("Delete Object: \(indexPath)")
            
            blockOperations.append(
                NSBlockOperation(block: { [weak self] in
                    if let this = self {
                        this.collectionView!.deleteItemsAtIndexPaths([indexPath!])
                    }
                    })
            )
        }
    }
    
    // In the did change section method:
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        
        if type == NSFetchedResultsChangeType.Insert {
//            print("Insert Section: \(sectionIndex)")
            
            blockOperations.append(
                NSBlockOperation(block: { [weak self] in
                    if let this = self {
                        this.collectionView!.insertSections(NSIndexSet(index: sectionIndex))
                    }
                    })
            )
        }
        else if type == NSFetchedResultsChangeType.Update {
//            print("Update Section: \(sectionIndex)")
            blockOperations.append(
                NSBlockOperation(block: { [weak self] in
                    if let this = self {
                        this.collectionView!.reloadSections(NSIndexSet(index: sectionIndex))
                    }
                    })
            )
        }
        else if type == NSFetchedResultsChangeType.Delete {
//            print("Delete Section: \(sectionIndex)")
            
            blockOperations.append(
                NSBlockOperation(block: { [weak self] in
                    if let this = self {
                        this.collectionView!.deleteSections(NSIndexSet(index: sectionIndex))
                    }
                    })
            )
        }
    }
    
    // And finally, in the did controller did change content method:
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        collectionView!.performBatchUpdates({ () -> Void in
            for operation: NSBlockOperation in self.blockOperations {
                operation.start()
            }
            }, completion: { (finished) -> Void in
                self.blockOperations.removeAll(keepCapacity: false)
        })
    }
    
    // I personally added some code in the deinit method as well, in order to cancel the operations when the ViewController is about to get deallocated:
    deinit {
        // Cancel all block operations when VC deallocates
        for operation: NSBlockOperation in blockOperations {
            operation.cancel()
        }
        
        blockOperations.removeAll(keepCapacity: false)
    }
    

}
