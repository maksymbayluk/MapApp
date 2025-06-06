//
//  LocationTracker.swift
//  MapApp
//
//  Created by Максим Байлюк on 28.05.2025.
//
import CoreLocation
import Foundation

//Singleton class designed to handle location tracking calculations
class LocationTracker {
    static let shared = LocationTracker()
    var speedSamples: [Double] = []
    private let maxSamples = 2

    init() {}
    //Calculates distance between two locations using CoreLocation
    func calculateDistance(from last: CLLocation?, to current: CLLocation) -> CLLocationDistance {
        guard let last = last else { return 0 }
        return current.distance(from: last)
    }
    //Speed calculation with multiple validation checks
    func calculateSpeed(from last: CLLocation?, to current: CLLocation, distance: CLLocationDistance) -> Double {
        guard let last = last else {
            return max(0, current.speed)
        }
        if current.horizontalAccuracy > 20 {
            return 0
        }
        let timeDiff = current.timestamp.timeIntervalSince(last.timestamp)
        guard timeDiff > 0 else { return 0 }

        if distance < 3 && current.speed > 1.5 {
            return 0
        }

        return distance / timeDiff
    }
    //Defines valid speed range
    func isSpeedAcceptable(_ speed: Double) -> Bool {
        let minSpeed = 1.5
        return speed >= minSpeed && speed <= 100.0
    }
    //Checks for sudden speed changes (3x increase/decrease)
    func addSpeedSample(_ speed: Double, distance: CLLocationDistance) -> Double {
        let isShortDistance = distance < 5
        let isSpike = { [self] in
            guard let last = speedSamples.last, last > 0 else { return false }
            return speed > last * 3 || speed < last / 3
        }

        if isShortDistance && isSpike() {
            return averageSpeed()
        }

        speedSamples.append(speed)
        if speedSamples.count > maxSamples {
            speedSamples.removeFirst()
        }

        return averageSpeed()
    }
    //returning avarage speed
    private func averageSpeed() -> Double {
        guard !speedSamples.isEmpty else { return 0 }
        return speedSamples.reduce(0, +) / Double(speedSamples.count)
    }

    //cleaning speed samples
    func clearSpeedSamples() {
        speedSamples.removeAll()
    }
}
