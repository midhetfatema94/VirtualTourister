//
//  Navigation.swift
//  VirtualTourister
//
//  Created by Midhet Sulemani on 10/01/17.
//  Copyright © 2017 MCreations. All rights reserved.
//

import Foundation

class Navigation {
    
    var flickrAPIKey = "2f44335522199e7284bf8bd5d846102e"
    
    func getPhotosFlickr(latitude: Double, longitude: Double, pageNumber: Int, completion: @escaping (([String: Any]) -> Void)) {
        
        let request = NSMutableURLRequest(url: URL(string: "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(flickrAPIKey)&lat=\(latitude)&lon=\(longitude)&per_page=25&page=\(pageNumber)&format=json&nojsoncallback=1")!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            
            if error != nil {
                
                print("Error: \(error)")
                //                helper.giveErrorAlerts(errorString: "Request failed", errorMessage: error!.localizedDescription, vc: controller)
                return
            }
            print("starts here")
            print(NSString(data: data!, encoding: String.Encoding.utf8.rawValue)!)
            do {
                let result = try JSONSerialization.jsonObject(with: data!, options: []) as! [String:AnyObject]
                print("response: \(result)")
                completion(result)
                
            } catch {
                print("Error: \(error)")
            }
        }
        task.resume()
    }
    
}
