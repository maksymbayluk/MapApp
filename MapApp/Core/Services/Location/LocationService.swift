//
//  LocationService.swift
//  MapApp
//
//  Created by Максим Байлюк on 27.05.2025.
//
import CoreLocation


// MARK: - LocationService

final class LocationService: NSObject {
    private let locationManager = CLLocationManager()
    private var oneTimeRequests: [(CLLocation) -> Void] = []
    private var subscribers: [(CLLocation, Double) -> Void] = []
    var onError: ((Error) -> Void)?
    private(set) var totalDistance: CLLocationDistance = 0
    private var ignoreUpdatesAfterStopUntil: Date?
    private(set) var lastLocation: CLLocation?
    private var isTracking = false


    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.activityType = .fitness
    }

    func requestAuthorization() {
        let status = locationManager.authorizationStatus
        switch status {
        case .notDetermined:
            locationManager.requestAlwaysAuthorization()
        case .authorizedAlways,
             .authorizedWhenInUse:
            locationManager.allowsBackgroundLocationUpdates = true
            locationManager.startUpdatingLocation()
        default:
            break
        }
    }

    func start() {
        isTracking = true
        ignoreUpdatesAfterStopUntil = nil
        LocationTracker.shared.clearSpeedSamples()
        locationManager.startUpdatingLocation()

        if
            let cachedLocation = locationManager.location,
            abs(cachedLocation.timestamp.timeIntervalSinceNow) < 5
        {
            lastLocation = cachedLocation
            notifySubscribers(with: cachedLocation, speed: max(0, cachedLocation.speed))
        } else {
            locationManager.requestLocation()
        }
    }

    func stop() {
        isTracking = false
        LocationTracker.shared.clearSpeedSamples()
        ignoreUpdatesAfterStopUntil = Date().addingTimeInterval(5)
        locationManager.stopUpdatingLocation()
    }

    func subscribe(_ handler: @escaping (CLLocation, Double) -> Void) {
        subscribers.append(handler)
        if let last = lastLocation {
            let displayedSpeed = max(0, last.speed)
            handler(last, displayedSpeed)
        }
    }

    func requestCurrentLocation(completion: @escaping (CLLocation) -> Void) {
        if let cached = locationManager.location {
            completion(cached)
        }
        oneTimeRequests.append(completion)
        locationManager.requestLocation()
    }

    private func notifySubscribersWithZeroSpeed() {
        if let lastLoc = lastLocation {
            notifySubscribers(with: lastLoc, speed: 0.0)
        }
    }
}

// MARK: CLLocationManagerDelegate

extension LocationService: CLLocationManagerDelegate {
    func locationManager(_: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last else { return }
        guard let last = lastLocation else {
            lastLocation = newLocation
            return
        }
        let timeDiff = newLocation.timestamp.timeIntervalSince(last.timestamp)
        if timeDiff < 0.5 {
            return
        }

        if shouldIgnoreLocation(newLocation) {
            return
        }


        let distance = LocationTracker.shared.calculateDistance(from: lastLocation, to: newLocation)
        let rawSpeed = LocationTracker.shared.calculateSpeed(from: lastLocation, to: newLocation, distance: distance)
        let averagedSpeed = LocationTracker.shared.addSpeedSample(rawSpeed, distance: distance)

        let isSpeedValid = LocationTracker.shared.isSpeedAcceptable(averagedSpeed)
        let isDistanceValid = distance > 3 && distance < 20

        if isSpeedValid && isDistanceValid {
            updateDistanceIfNeeded(from: lastLocation, to: newLocation, distance: distance, speed: averagedSpeed)
            lastLocation = newLocation
            notifySubscribers(with: newLocation, speed: averagedSpeed)
        } else {
            lastLocation = newLocation
            notifySubscribersWithZeroSpeed()
        }
    }

    private func shouldIgnoreLocation(_ location: CLLocation) -> Bool {
        guard location.horizontalAccuracy >= 0 && location.horizontalAccuracy < 20 else {
            return true
        }

        let maxAge: TimeInterval = 10
        if abs(location.timestamp.timeIntervalSinceNow) > maxAge {
            return true
        }

        if !isTracking {
            if let until = ignoreUpdatesAfterStopUntil, Date() < until {
                return true
            }
            return true
        }

        return false
    }


    private func updateDistanceIfNeeded(from last: CLLocation?, to current: CLLocation, distance: CLLocationDistance, speed: Double) {
        guard let last = last else { return }

        let timeDiff = current.timestamp.timeIntervalSince(last.timestamp)
        guard timeDiff > 1.0 else { return }
        if distance < 3 && speed > 1.5 {
            notifySubscribersWithZeroSpeed()
            return
        }

        if distance > 3 && distance < 20 {
            totalDistance += distance
        }
    }

    private func notifySubscribers(with location: CLLocation, speed: Double) {
        let displayedSpeed = speed.isNaN || speed < 0.1 ? 0.0 : speed
        lastLocation = location
        subscribers.forEach { $0(location, displayedSpeed) }
        oneTimeRequests.forEach { $0(location) }
        oneTimeRequests.removeAll()
    }

    func locationManager(_: CLLocationManager, didFailWithError error: Error) {
        onError?(error)
    }
}
