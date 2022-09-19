//
//  LocationManager.swift
//  SearchLocationApp
//
//  Created by Константин Малков on 30.08.2022.
//

//This main class consist of location func, which collect user data of location, and also there is function for showing user result of searching city

import Foundation
import CoreLocation

struct Location {
    let title: String
    let coordinates: CLLocationCoordinate2D?
}

class LocationManager: NSObject, CLLocationManagerDelegate {
    static let shared = LocationManager()
    
    var completion: ((CLLocation) -> Void)?
    let manager = CLLocationManager()
    //func for searching city and show result in table view cell
    public func findLocations(with query: String, completion: @escaping (([Location]) -> Void)) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(query) { places, error in
            guard let places = places, error == nil else {
                completion([])
                return
            }
            let models: [Location] = places.compactMap({ place in
                var name = ""
                if let locationName  = place.name {
                    name += locationName
                }
                if let adminRegion  = place.administrativeArea {
                    name += ", \(adminRegion)"
                }
                if let locality  = place.locality {
                    name += ", \(locality)"
                }
                
                if let country  = place.country {
                    name += ", \(country)"
                }
                print("\n\(place)\n\n")
                
                let result = Location(title: name, coordinates: place.location?.coordinate)
                return result
            })
            completion(models)
            self.manager.stopUpdatingLocation()
        }
    }
    //func for setup user location. Turn on and off monitoring user location and etc
    public func currentLocation(completion: @escaping ((CLLocation)-> Void)) {
        manager.stopUpdatingLocation()
        self.completion = completion
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locations = locations.first else {
        return
        }
        completion?(locations)
        manager.stopUpdatingHeading()
    }
}


