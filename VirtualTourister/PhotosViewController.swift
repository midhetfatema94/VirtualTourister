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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if checkForPhotos().count > 0 {
            print("local photos available")
            localPhotos = checkForPhotos()
            isLocalPhotos = true
            photosFlickr.reloadData()
        }
        else {
            print("local photos not available")
            getFlickrPhotos(pgNo: pageNumber)
            isLocalPhotos = false
        }
    }

    func checkForPhotos() -> [Photo] {
        
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")
        let pred = NSPredicate(format: "pin = %@", argumentArray: pinObject)
        fr.predicate = pred
        
        let photos = try! helper.context.fetch(fr) as! [Photo]
        print("check for photo:", photos)
        return photos
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
    
    func getFlickrPhotos(pgNo: Int) {
        
        request.getPhotosFlickr(latitude: pinObject[0].latitude, longitude: pinObject[0].longitude, pageNumber: pgNo, completion: { response in
            
            DispatchQueue.main.async {
                
                if response["stat"] as! String == "ok" {
                    
                    print("response arrived!")
                    let photoSet = response["photos"] as! [String: Any]
                    self.flickrPhotos = photoSet["photo"] as! [[String: Any]]
                    print("count is:", self.flickrPhotos.count)
                    if self.flickrPhotos.count == 0 {
                        let alert = UIAlertController(title: "No photos found!", message: nil, preferredStyle: .alert)
                        
                        let saveAction = UIAlertAction(title: "Okay", style: .default, handler: { (action: UIAlertAction) -> Void in
                            
                            self.navigationController!.popViewController(animated: true)
                        })
                        
                        alert.addAction(saveAction)
                        
                        self.present(alert, animated: true, completion: nil)
                        
                    }
                    else {
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
                self.photosFlickr.reloadData()
                print("saved photos")
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
