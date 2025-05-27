//
//  LocationService.swift
//  MapApp
//
//  Created by Максим Байлюк on 27.05.2025.
//
import MapKit

class LocationService: NSObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    private var onLocationUpdate: ((CLLocationCoordinate2D) -> Void)?

    override init() {
        super.init()
        locationManager.delegate = self
    }

    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }

    func getCurrentLocation(completion: @escaping (CLLocationCoordinate2D) -> Void) {
        onLocationUpdate = completion
        locationManager.requestLocation()
    }

    func locationManager(_: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let coordinate = locations.first?.coordinate {
            onLocationUpdate?(coordinate)
        }
    }

    func locationManager(_: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error)")
    }
}
