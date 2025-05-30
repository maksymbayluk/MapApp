//
//  MainMapViewModel.swift
//  MapApp
//
//  Created by Максим Байлюк on 27.05.2025.
//
import CoreLocation
import MapKit

final class MainMapViewModel {
    //service for real-time location
    private let locationService: LocationService
    //closure that informs the view when the user's location is updated
    var onUserLocationUpdated: ((CLLocationCoordinate2D) -> Void)?
    //closure that informs about error
    var onLocationError: ((String) -> Void)?
    //closure to notify the view when the side menu action is triggered
    var didTapMenu: (() -> Void)?
    //computed property returning the user's last known coordinates
    var currentCoordinates: CLLocationCoordinate2D? {
        return locationService.lastLocation?.coordinate
    }
    //Computed property returning the total distance
    var totalDistance: CLLocationDistance? {
        return locationService.totalDistance
    }

    init(locationService: LocationService) {
        self.locationService = locationService
        setupBindings()
    }
    //connecting on error closure to view model on location error
    private func setupBindings() {
        locationService.onError = { [weak self] error in
            self?.onLocationError?(error.localizedDescription)
        }
    }
    //request the current position
    func centerUserLocation() {
        locationService.requestCurrentLocation { [weak self] location in
            self?.onUserLocationUpdated?(location.coordinate)
        }
    }
}
