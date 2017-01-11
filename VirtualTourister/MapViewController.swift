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
import Foundation

class MapViewController: UIViewController, MKMapViewDelegate {
    
    var annotations: [MKPointAnnotation] = []
    
    @IBOutlet weak var map: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(addPin(sender:)))
        map.addGestureRecognizer(longPress)
        map.delegate = self
        
        if UserDefaults.standard.bool(forKey: "mapRegion") {
            
            let latDelta = UserDefaults.standard.value(forKey: "latDelta")
            let longDelta = UserDefaults.standard.value(forKey: "longDelta")
            let lat = UserDefaults.standard.value(forKey: "lat")
            let long = UserDefaults.standard.value(forKey: "long")
            let coordinate = CLLocationCoordinate2D(latitude: lat as! CLLocationDegrees, longitude: long as! CLLocationDegrees)
            let span = MKCoordinateSpanMake(latDelta as! CLLocationDegrees, longDelta as! CLLocationDegrees)
            let region = MKCoordinateRegionMake(coordinate, span)
            map.setRegion(region, animated: false)
        }
        
        fetchAllPins()
    }

    func addPin(sender: UILongPressGestureRecognizer) {
        
        let pointTapped = sender.location(in: map)
        let location = map.convert(pointTapped, toCoordinateFrom: map)
        let annotation = MKPointAnnotation()
        annotation.coordinate = location
        annotations.append(annotation)
        map.addAnnotations(annotations)
        
        let span = map.region.span
        let region = map.region
        print("delta is:", span.latitudeDelta, span.longitudeDelta)
        print("region is:", region)
        UserDefaults.standard.set(map.region.span.latitudeDelta, forKey: "latDelta")
        UserDefaults.standard.set(map.region.span.longitudeDelta, forKey: "longDelta")
        UserDefaults.standard.set(map.region.center.latitude, forKey: "lat")
        UserDefaults.standard.set(map.region.center.longitude, forKey: "long")
        UserDefaults.standard.set(true, forKey: "mapRegion")
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
    
    var mapChangedFromUserInteraction = false
    
    func mapViewRegionDidChangeFromUserInteraction() -> Bool {
        let view = map.subviews[0]
        //  Look through gesture recognizers to determine whether this region change is from user interaction
        if let gestureRecognizers = view.gestureRecognizers {
            for recognizer in gestureRecognizers {
                if( recognizer.state == .began || recognizer.state == .ended ) {
                    return true
                }
            }
        }
        return false
    }
    
    func fetchAllPins() {
        
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "LocationPin")
        
        let pins = try! helper.context.fetch(fr) as! [LocationPin]
        print("all pins:", pins)
        
        if pins.count > 0 {
            
            for pin in pins {
                
                let annotation = MKPointAnnotation()
                annotation.coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
                if !annotations.contains(annotation) {
                    annotations.append(annotation)
                }
            }
            
            map.addAnnotations(annotations)
        }
        
    }
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        mapChangedFromUserInteraction = mapViewRegionDidChangeFromUserInteraction()
        if (mapChangedFromUserInteraction) {
            // user will change map region
            print("user WILL change map.")
            
            // calculate the width of the map in miles.
            let mRect: MKMapRect = mapView.visibleMapRect
            let eastMapPoint = MKMapPointMake(MKMapRectGetMinX(mRect), MKMapRectGetMidY(mRect))
            let westMapPoint = MKMapPointMake(MKMapRectGetMaxX(mRect), MKMapRectGetMidY(mRect))
            let currentDistWideInMeters = MKMetersBetweenMapPoints(eastMapPoint, westMapPoint)
            let milesWide = currentDistWideInMeters / 1609.34  // number of meters in a mile
            print(milesWide)
            print("^miles wide")
            
            // check if user zoomed in too far and zoom them out.
            if milesWide < 2.0 {
                var region:MKCoordinateRegion = mapView.region
                var span:MKCoordinateSpan = mapView.region.span
                span.latitudeDelta = 0.04
                span.longitudeDelta = 0.04
                region.span = span;
                mapView.setRegion(region, animated: true)
                print("map zoomed back out")
            }
            
        }
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        if (mapChangedFromUserInteraction) {
            // user changed map region
            print("user CHANGED map.")
            print(mapView.region.span.latitudeDelta)
            print(mapView.region.span.longitudeDelta)
            
            // calculate the width of the map in miles.
            let mRect: MKMapRect = mapView.visibleMapRect
            let eastMapPoint = MKMapPointMake(MKMapRectGetMinX(mRect), MKMapRectGetMidY(mRect))
            let westMapPoint = MKMapPointMake(MKMapRectGetMaxX(mRect), MKMapRectGetMidY(mRect))
            let currentDistWideInMeters = MKMetersBetweenMapPoints(eastMapPoint, westMapPoint)
            let milesWide = currentDistWideInMeters / 1609.34  // number of meters in a mile
            print(milesWide)
            print("^miles wide")
            
            // check if user zoomed in too far and zoom them out.
            if milesWide < 2.0 {
                
                DispatchQueue.main.async {
                    
                    var region:MKCoordinateRegion = mapView.region
                    var span:MKCoordinateSpan = mapView.region.span
                    span.latitudeDelta = 0.04
                    span.longitudeDelta = 0.04
                    region.span = span;
                    mapView.setRegion(region, animated: true)
                    print("map zoomed back out")
                }
            }
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

