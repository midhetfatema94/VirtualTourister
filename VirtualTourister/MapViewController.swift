//
//  ViewController.swift
//  VirtualTourister
//
//  Created by Midhet Sulemani on 10/01/17.
//  Copyright © 2017 MCreations. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController, MKMapViewDelegate {
    
    var annotations: [MKPointAnnotation] = []
    
    @IBOutlet weak var map: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(addPin(sender:)))
        map.addGestureRecognizer(longPress)
        map.delegate = self
    }

    func addPin(sender: UILongPressGestureRecognizer) {
        
        let pointTapped = sender.location(in: map)
        let location = map.convert(pointTapped, toCoordinateFrom: map)
        let annotation = MKPointAnnotation()
        annotation.coordinate = location
        annotations.append(annotation)
        map.addAnnotations(annotations)
    }
    
    func savePin(node: MKAnnotation) {
        
        let newPin = NSEntityDescription.insertNewObject(forEntityName: "LocationPin", into: helper.context) as! LocationPin
        newPin.latitude = node.coordinate.latitude
        newPin.longitude = node.coordinate.longitude
        newPin.creationDate = Date()
        print("pin:", newPin)
        do {
            try helper.context.save()
            print("saved pins")
        }
        catch
        {
            print("error in saving context")
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        savePin(node: view.annotation!)
        performSegue(withIdentifier: "album", sender: view)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "album" {
            
            let vc = segue.destination as! PhotosViewController
            let selectedNode = sender as! MKAnnotationView
//            vc.lat = selectedNode.annotation!.coordinate.latitude
//            vc.long = selectedNode.annotation!.coordinate.longitude
            
            let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "LocationPin")
            
            let pred = NSPredicate(format: "latitude = %lf AND longitude = %lf", selectedNode.annotation!.coordinate.latitude, selectedNode.annotation!.coordinate.longitude)
            fr.predicate = pred
            
            do {
                let pin = try helper.context.fetch(fr) as! [LocationPin]
                print("pins are: \(pin)")
                vc.pinObject = pin
            } catch {
                print("Failed to fetch pin")
            }
        }
    }


}

