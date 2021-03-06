//
//  PhotosViewController.swift
//  VirtualTourister
//
//  Created by Midhet Sulemani on 10/01/17.
//  Copyright © 2017 MCreations. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class PhotosViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, MKMapViewDelegate {
    
    var pinObject: [LocationPin] = []
    var localPhotos: [Photo] = []
    var flickrPhotos: [[String: Any]] = []
    var isLocalPhotos = false
    var pageNumber = 1
    
    @IBOutlet weak var photosFlickr: UICollectionView!
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var newCollection: UIBarButtonItem!
    @IBOutlet weak var loadingView: UIView!
    
    @IBAction func getNewCollection(_ sender: Any) {
        
        loadingView.isHidden = false
        for eachLocalPhoto in localPhotos {
            
            helper.context.delete(eachLocalPhoto)
        }
        print("deleted previous photos")
        pageNumber += 1
        isLocalPhotos = false
        getFlickrPhotos(pgNo: pageNumber)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController!.isNavigationBarHidden = false
        
        let coordinate = CLLocationCoordinate2D(latitude: pinObject[0].latitude, longitude: pinObject[0].longitude)
        let latDelta:CLLocationDegrees = 5.0
        let lonDelta:CLLocationDegrees = 5.0
        let span = MKCoordinateSpanMake(latDelta, lonDelta)
        let region = MKCoordinateRegionMake(coordinate, span)
        map.setRegion(region, animated: false)
        
        let newAnnotation = MKPointAnnotation()
        newAnnotation.coordinate = coordinate
        map.addAnnotation(newAnnotation)
        
        checkLocalOrServer()
    }

    func checkForPhotos() -> [Photo] {
        
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")
        let pred = NSPredicate(format: "pin = %@", argumentArray: pinObject)
        fr.predicate = pred
        
        let photos = try! helper.context.fetch(fr) as! [Photo]
        print("check for photo:", photos)
        return photos
    }
    
    func checkLocalOrServer() {
        
        DispatchQueue.main.async {
            
            if self.checkForPhotos().count > 0 {
                print("local photos available")
                self.localPhotos = self.checkForPhotos()
                self.isLocalPhotos = true
                self.photosFlickr.reloadData()
            }
            else {
                print("local photos not available")
                self.getFlickrPhotos(pgNo: self.pageNumber)
                self.isLocalPhotos = false
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if isLocalPhotos {
            return localPhotos.count
        }
        return flickrPhotos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! PhotosCollectionViewCell
        
        if isLocalPhotos {
            cell.photo.image = UIImage(data: localPhotos[indexPath.item].data!)
        }
        else {
            cell.photo.imageFromServerURL(urlString: makePhotoUrl(eachPhoto: flickrPhotos[indexPath.item]))
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if isLocalPhotos {
            
            DispatchQueue.main.async {
                
                let photoObject = self.localPhotos[indexPath.item]
                helper.context.delete(photoObject)
                print("deleted object")
                self.checkLocalOrServer()
            }
        }
    }
    
    func getFlickrPhotos(pgNo: Int) {
        
        request.getPhotosFlickr(latitude: pinObject[0].latitude, longitude: pinObject[0].longitude, pageNumber: pgNo, completion: { response in
            
            DispatchQueue.main.async {
                
                if response["stat"] as! String == "ok" {
                    
                    print("response arrived!")
                    let photoSet = response["photos"] as! [String: Any]
                    self.flickrPhotos = photoSet["photo"] as! [[String: Any]]
                    print("count is:", self.flickrPhotos.count)
                    self.loadingView.isHidden = true
                    if self.flickrPhotos.count == 0 {
                        let alert = UIAlertController(title: "No photos found!", message: nil, preferredStyle: .alert)
                        
                        let saveAction = UIAlertAction(title: "Okay", style: .default, handler: { (action: UIAlertAction) -> Void in
                            
                            self.navigationController!.popViewController(animated: true)
                        })
                        
                        alert.addAction(saveAction)
                        
                        self.present(alert, animated: true, completion: nil)
                        
                    }
                    else {
                        self.newCollection.isEnabled = false
                        self.photosFlickr.reloadData()
                        self.savePhotos()
                    }
                }
                else {
                    print("response error")
                }
            }
        })
    }
    
    func savePhotos() {
        
        DispatchQueue.init(label: "newQueue").async {
            
            for photo in self.flickrPhotos {
                
                let url = self.makePhotoUrl(eachPhoto: photo)
                let data = try! Data(contentsOf: URL(string: url)!)
                let newPhoto = NSEntityDescription.insertNewObject(forEntityName: "Photo", into: helper.context) as! Photo
                newPhoto.data = data
                newPhoto.url = url
                newPhoto.creationDate = Date()
                newPhoto.pin = self.pinObject[0]
                print(newPhoto)
            }
            
            do {
                try helper.stack.saveContext()
                self.checkLocalOrServer()
                print("saved photos")
                self.newCollection.isEnabled = true
            } catch {
                print("Error while saving.")
            }
        }
    }
    
    func makePhotoUrl(eachPhoto: [String: Any]) -> String {
        
        let photoURL = "https://farm\(eachPhoto["farm"]!).staticflickr.com/\(eachPhoto["server"]!)/\(eachPhoto["id"]!)_\(eachPhoto["secret"]!).jpg"
        return photoURL
    }
}

extension UIImageView {
    public func imageFromServerURL(urlString: String) {
        
        URLSession.shared.dataTask(with: NSURL(string: urlString)! as URL, completionHandler: { (data, response, error) -> Void in
            
            if error != nil {
                print(error as Any)
                return
            }
            DispatchQueue.main.async(execute: {
                let image = UIImage(data: data!)
                self.image = image
            })
        }).resume()
    }
}
