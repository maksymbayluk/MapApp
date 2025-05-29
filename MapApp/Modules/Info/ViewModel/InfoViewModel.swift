//
//  InfoViewModel.swift
//  MapApp
//
//  Created by Максим Байлюк on 28.05.2025.
//
import CoreLocation


final class InfoViewModel {
    private let locationService: LocationService
    var onInfoUpdate: ((String, String, String) -> Void)?

    private var lastLocation: CLLocation?
    private var lastSpeed: Double = 0
    private var currentSteps: Int = 0
    private var pedometerDistance: Double = 0
    var coordinates: CLLocationCoordinate2D? {
        return locationService.lastLocation?.coordinate
    }

    init(locationService: LocationService) {
        self.locationService = locationService
        self.locationService.start()
    }

    func bindLocationUpdates() {
        locationService.subscribe { [weak self] location, speed in
            self?.updateInfo(location: location, speed: speed)
        }
    }

    private func updateInfo(location: CLLocation? = nil, speed: Double? = nil) {
        if let location = location { lastLocation = location }
        if let speed = speed { lastSpeed = speed }

        guard let location = lastLocation else { return }

        let lat = String(format: "%.6f", location.coordinate.latitude)
        let lon = String(format: "%.6f", location.coordinate.longitude)
        let speedKmh = max(0, lastSpeed) * 3.6
        let speedString = String(format: "%.2f km/h", speedKmh)
        let distanceString = String(format: "%.2f m", locationService.totalDistance)
        onInfoUpdate?("\(lat), \(lon)", speedString, distanceString)
    }
}
