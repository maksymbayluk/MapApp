//
//  LocationService.swift
//  MapApp
//
//  Created by Максим Байлюк on 27.05.2025.
//
import CoreLocation


//Singleton class responsible for managing location updates. It handles authorization, starts and stops location tracking, processes location updates, calculates distance, and notifies subscribers(map and info) about location and speed changes.
final class LocationService: NSObject {
    private let locationManager = CLLocationManager()
    //A list of closures to call once when updated (map)
    private var oneTimeRequests: [(CLLocation) -> Void] = []
    //A list of closures that get notified continuously
    private var subscribers: [(CLLocation, Double) -> Void] = []
    //The last route coordinates loaded from Core Data
    private(set) var recentCoordinates: [CLLocationCoordinate2D] = []
    //Optional error handler closure
    var onError: ((Error) -> Void)?
    private(set) var totalDistance: CLLocationDistance = 0
    //A date used to ignore updates immediately after stopping tracking, to avoid spikes
    private var ignoreUpdatesAfterStopUntil: Date?
    //The most recent location received
    private(set) var lastLocation: CLLocation?
    //Flag indicating if tracking is currently active
    private var isTracking = false
    //Current authorization status for location services
    private(set) var authorizationStatus: CLAuthorizationStatus = .notDetermined {
        didSet {
            onAuthorizationChanged?(authorizationStatus)
        }
    }
    //Singleton
    static let shared = LocationService()
    //Closure to notify observers when location authorization changes
    var onAuthorizationChanged: ((CLAuthorizationStatus) -> Void)?


    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.activityType = .fitness
    }
    //requesting authorization
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
    //Start of service
    func start() {
        isTracking = true
        ignoreUpdatesAfterStopUntil = nil
        LocationTracker.shared.clearSpeedSamples()
        loadRecentRouteFromCoreData()
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
    //Stop of service
    func stop() {
        isTracking = false
        LocationTracker.shared.clearSpeedSamples()
        ignoreUpdatesAfterStopUntil = Date().addingTimeInterval(5)
        locationManager.stopUpdatingLocation()
    }
    //Allows continuous subscribers to receive updates
    func subscribe(_ handler: @escaping (CLLocation, Double) -> Void) {
        subscribers.append(handler)
        if let last = lastLocation {
            let displayedSpeed = max(0, last.speed)
            handler(last, displayedSpeed)
        }
    }
    //requesting location(map)
    func requestCurrentLocation(completion: @escaping (CLLocation) -> Void) {
        if let cached = locationManager.location {
            completion(cached)
        }
        oneTimeRequests.append(completion)
        locationManager.requestLocation()
    }
    //notifying subscribers about stop(speed 0)
    private func notifySubscribersWithZeroSpeed() {
        if let lastLoc = lastLocation {
            notifySubscribers(with: lastLoc, speed: 0.0)
        }
    }
    //saving recent coordinated to CD and updating recentCoordinates
    private func updateRecentCoordinates(with newLocation: CLLocation) {
        CoreDataManager.shared.saveRoutePoint(from: newLocation)
        loadRecentRouteFromCoreData()
    }
    //updating recentCoordinates for last 1 km
    func loadRecentRouteFromCoreData() {
        recentCoordinates = CoreDataManager.shared.fetchRoutePointsForLast(distance: 1000)
    }
}

// MARK: CLLocationManagerDelegate

extension LocationService: CLLocationManagerDelegate {
    //Main handler for location updates, processes new locations with several validation checks
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
            updateRecentCoordinates(with: newLocation)
            CoreDataManager.shared.saveRoutePoint(from: newLocation)
            notifySubscribers(with: newLocation, speed: averagedSpeed)
        } else {
            lastLocation = newLocation
            notifySubscribersWithZeroSpeed()
        }
    }
    //Validates location accuracy and timestamp
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

    //Updates total distance traveled
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
            if Int(totalDistance) % 100 < Int(distance) {
                NotificationService.shared.sendDistanceNotification(distance: totalDistance)
            }
        }
    }
    //Notifies registered subscribers about location/speed updates
    private func notifySubscribers(with location: CLLocation, speed: Double) {
        let displayedSpeed = speed.isNaN || speed < 0.1 ? 0.0 : speed
        lastLocation = location
        subscribers.forEach { $0(location, displayedSpeed) }
        oneTimeRequests.forEach { $0(location) }
        oneTimeRequests.removeAll()
    }
    //Handles location tracking errors
    func locationManager(_: CLLocationManager, didFailWithError error: Error) {
        onError?(error)
    }
    //Responds to authorization status changes
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        authorizationStatus = status
        switch manager.authorizationStatus {
        case .authorizedAlways,
             .authorizedWhenInUse:
            locationManager.allowsBackgroundLocationUpdates = true
            locationManager.startUpdatingLocation()
        case .denied,
             .restricted:
            AlertService.showAlert(title: "Location Access Denied", message: "Please enable location access in your device settings.")
        default:
            break
        }
    }
}



