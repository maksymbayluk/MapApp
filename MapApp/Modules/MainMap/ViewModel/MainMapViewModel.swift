//
//  MainMapViewModel.swift
//  MapApp
//
//  Created by Максим Байлюк on 27.05.2025.
//
import MapKit

final class MainMapViewModel {

    var onCenterMap: ((CLLocationCoordinate2D) -> Void)?
    var didTapMenu: (() -> Void)?
    private let locationService: LocationService

    init(locationService: LocationService = LocationService()) {
        self.locationService = locationService
    }

    func loadView() {
        locationService.requestLocationPermission()
    }

    func didTapMyLocation() {
        locationService.getCurrentLocation { [weak self] coordinate in
            self?.onCenterMap?(coordinate)
        }
    }
}
