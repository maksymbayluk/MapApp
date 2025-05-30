//
//  InfoViewModel.swift
//  MapApp
//
//  Created by Максим Байлюк on 28.05.2025.
//
import CoreLocation
import MapKit

//view model class that manages the business logic for location tracking information display and show route
final class InfoViewModel {
    //service for real-time updates
    private let locationService: LocationService
    //closure for updated on info(speed, etc.)
    var onInfoUpdate: ((String, String, String) -> Void)?
    //closure for route show
    var onRequestShowMapRoute: ((MKPolyline) -> Void)?
    //Last CLLocation
    private var lastLocation: CLLocation?
    //Most recent speed and steps
    private var lastSpeed: Double = 0
    private var currentSteps: Int = 0
    //Array of recent coordinates(computed property)
    var coordinates: CLLocationCoordinate2D? {
        return locationService.lastLocation?.coordinate
    }
    
    init(locationService: LocationService) {
        self.locationService = locationService
        self.locationService.start()
    }
    
    //becoming subscriber for location updates
    func bindLocationUpdates() {
        locationService.subscribe { [weak self] location, speed in
            self?.updateInfo(location: location, speed: speed)
        }
    }
    //getting updates from Location Service
    private func updateInfo(location: CLLocation? = nil, speed: Double? = nil) {
        if let location = location {
            lastLocation = location
        }
        if let speed = speed {
            lastSpeed = speed
        }

        guard let location = lastLocation else { return }

        let lat = String(format: "%.6f", location.coordinate.latitude)
        let lon = String(format: "%.6f", location.coordinate.longitude)

        let speedKmh = max(0, lastSpeed) * 3.6
        let speedString = String(format: "%.0f km/h", speedKmh)

        let distance = CoreDataManager.shared.calculateTotalDistance()
        let distanceString: String
        if distance < 1000 {
            distanceString = String(format: "%.0f m", distance)
        } else {
            distanceString = String(format: "%.2f km", distance / 1000)
        }

        onInfoUpdate?("\(lat), \(lon)", speedString, distanceString)
    }
    //showing map with coordinates
    func showMapWithRoute() {
        let coords = locationService.recentCoordinates
        guard coords.count > 1 else { return }
        let polyline = MKPolyline(coordinates: coords, count: coords.count)
        onRequestShowMapRoute?(polyline)
    }
}
