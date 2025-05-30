//
//  NavigationService.swift
//  MapApp
//
//  Created by Максим Байлюк on 30.05.2025.
//

import CoreLocation
import UIKit

final class NavigationService {
    static let shared = NavigationService()

    init() {}

    func openNavigationToCityCenter(preferGoogleMaps: Bool = true) {
        guard let currentLocation = LocationService.shared.lastLocation else {
            AlertService.showAlert(title: "Location Error", message: "Can't get current location.")
            return
        }

        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(currentLocation) { placemarks, _ in
            if let city = placemarks?.first?.locality {

                geocoder.geocodeAddressString(city) { placemarks, _ in
                    if let placemark = placemarks?.first, let cityCenter = placemark.location?.coordinate {

                        let origin = "\(currentLocation.coordinate.latitude),\(currentLocation.coordinate.longitude)"
                        let destination = "\(cityCenter.latitude),\(cityCenter.longitude)"

                        var urlString: String?

                        if
                            preferGoogleMaps,
                            UIApplication.shared.canOpenURL(URL(string: "comgooglemaps://")!)
                        {
                            urlString = "comgooglemaps://?saddr=\(origin)&daddr=\(destination)&directionsmode=driving"
                        } else if UIApplication.shared.canOpenURL(URL(string: "waze://")!) {
                            urlString = "waze://?ll=\(destination)&navigate=yes"
                        } else {
                            urlString = "https://www.google.com/maps/dir/?api=1&origin=\(origin)&destination=\(destination)&travelmode=driving"
                        }

                        if let urlString, let url = URL(string: urlString) {
                            UIApplication.shared.open(url)
                        }

                    } else {
                        AlertService.showAlert(title: "Error", message: "Unable to locate city center.")
                    }
                }
            } else {
                AlertService.showAlert(title: "Error", message: "City not found from current location.")
            }
        }
    }
}
