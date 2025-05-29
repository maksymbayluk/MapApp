//
//  MainMapViewModel.swift
//  MapApp
//
//  Created by Максим Байлюк on 27.05.2025.
//
import CoreLocation
import MapKit

final class MainMapViewModel {
    private let locationService: LocationService
    var onUserLocationUpdated: ((CLLocationCoordinate2D) -> Void)?
    var onLocationError: ((String) -> Void)?
    var didTapMenu: (() -> Void)?
    var currentCoordinates: CLLocationCoordinate2D? {
        return locationService.lastLocation?.coordinate
    }

    var totalDistance: CLLocationDistance? {
        return locationService.totalDistance
    }

    init(locationService: LocationService) {
        self.locationService = locationService
        setupBindings()
    }

    private func setupBindings() {
        locationService.onError = { [weak self] error in
            self?.onLocationError?(error.localizedDescription)
        }
    }

    func centerUserLocation() {
        locationService.requestCurrentLocation { [weak self] location in
            self?.onUserLocationUpdated?(location.coordinate)
        }
    }
}
